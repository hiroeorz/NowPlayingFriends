//
//  SendTweetViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "NowPlayingFriendsAppDelegate.h"
#import "SendTweetViewController.h"
#import "YouTubeClient.h"


@interface SendTweetViewController (Local)
- (void)startIndicator;
- (void)stopIndicator;
- (void)stopIndicatoWithThread;
@end


@implementation SendTweetViewController

@dynamic appDelegate;
@synthesize defaultTweetString;
@synthesize editView;
@synthesize inReplyToStatusId;
@synthesize indicator;
@synthesize indicatorBase;
@synthesize letterCountLabel;
@synthesize musicPlayer;
@synthesize twitterClient;

- (void)dealloc {

  [editView release];
  [inReplyToStatusId release];
  [indicator release];
  [indicatorBase release];
  [letterCountLabel release];
  [musicPlayer release];
  [twitterClient release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.editView = nil;
  self.inReplyToStatusId = nil;
  self.indicator = nil;
  self.indicatorBase = nil;
  self.letterCountLabel = nil;
  self.musicPlayer = nil;
  self.twitterClient = nil;
  [super viewDidUnload];
}


- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}
  
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    twitterClient = [[TwitterClient alloc] init];
    editView = [[UITextView alloc] init];
    defaultTweetString = nil;
    inReplyToStatusId = nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  sending = NO;

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate cancelButton:@selector(closeEditView) target:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate sendButton:@selector(sendTweet) target:self];
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];

  setTweetEditField(editView, 5.0f, 310.0f, 140.0f);

  if (defaultTweetString != nil) { /* 通常のツイート*/
    editView.text = defaultTweetString;
  } else {                         /* 楽曲ツイート */
    editView.text = [self.appDelegate tweetString];

    if ([self.appDelegate hasYouTubeLink]) {
      YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];

      [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	       artist:[self.appDelegate nowPlayingArtistName]
	       delegate:self
	       action:@selector(addYouTubeLink:)];
    } else {
      NSString *tweet = 
	[editView.text stringByReplacingOccurrencesOfString:@"[yt]" 
		 withString:@""]; 
      editView.text = tweet;
    }
  }

  editView.delegate = self;
  [self.view addSubview:editView];
}

- (void)addYouTubeLink:(NSString *)linkUrl {

  NSString *tweet = nil;

  if (linkUrl != nil) {
    tweet = [editView.text stringByReplacingOccurrencesOfString:@"[yt]"
		     withString:linkUrl];
  } else {
    tweet = [editView.text stringByReplacingOccurrencesOfString:@"[yt]"
		     withString:@""]; 
  }

  editView.text = tweet;
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  [editView becomeFirstResponder];
  [self countAndWriteTweetLength:[editView.text length]];
}

#pragma mark

- (void)closeEditView {

  sending = NO;
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendTweet {

  if (kMaxTweetLength < [editView.text length]) {
        UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Can't send tweet"
			   message:@"Over 140 characters."
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  }

  if (sending == NO && kMaxTweetLength >= [editView.text length]) {
    sending = YES;
    musicPlayer.sending = YES;
    editView.backgroundColor = [UIColor colorWithRed: 0.6f green:0.6f blue:0.6f
					alpha:0.9];
    editView.editable = NO;
    [self startIndicator];
    [twitterClient updateStatus:editView.text 
		   inReplyToStatusId:inReplyToStatusId delegate:self];
  }
}

- (IBAction)clearText:(id)sender {
  editView.text = @"";
}

#pragma mark -
#pragma mark UITextView Delegate Methods

- (void)countAndWriteTweetLength:(NSInteger)textcount {

  if (textcount > kMaxTweetLength) {
    letterCountLabel.textColor=[UIColor redColor];
  }else{
    letterCountLabel.textColor=[UIColor whiteColor];
  }

  letterCountLabel.text = [NSString stringWithFormat:@"%d",textcount];
}

- (BOOL)textView:(UITextView *)textView 
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

  NSInteger textcount = [textView.text length] + [text length] - range.length;
  [self countAndWriteTweetLength:textcount];

  return YES;
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  sending = NO;
  musicPlayer.sending = NO;
  musicPlayer.sent = YES;

  [self performSelectorInBackground:@selector(stopIndicatoWithThread)
  	withObject:nil];

  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSLog(@"data: %@", dataString);
  [dataString release];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError");
  sending = NO;
  musicPlayer.sending = NO;
  musicPlayer.sent = YES;

  [self performSelectorInBackground:@selector(stopIndicatoWithThread)
  	withObject:nil];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Local Methods

- (void)stopIndicatoWithThread {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self stopIndicator];
  [pool release];
}

- (void)startIndicator {

  UIView *baseView = [[UIView alloc] 
		       initWithFrame:CGRectMake(0.0, 0.0, 320, 367)];
  self.indicatorBase = baseView;
  [baseView release];

  UIColor *baseColor = [[UIColor alloc] initWithRed:0.0
					green:0.0
					blue:0.0
					alpha:0.4];
  indicatorBase.backgroundColor = baseColor;
  [baseColor release];

  UIActivityIndicatorView *indicatorView = 
    [[UIActivityIndicatorView alloc] 
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  indicatorView.frame = CGRectMake(135.0, 135.0, 50.0, 50.0);

  self.indicator = indicatorView;
  [indicatorView release];
    

  [indicatorBase addSubview:indicator];
  [self.view addSubview:indicatorBase];
  [indicator startAnimating];
}

- (void)stopIndicator {
  [indicator stopAnimating];
  [indicator removeFromSuperview];
  [indicatorBase removeFromSuperview];

  self.indicator = nil;
  self.indicatorBase = nil;
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

//
//  SendTweetViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SendTweetViewController.h"


@interface SendTweetViewController (Local)
- (void)startIndicator;
- (void)stopIndicator;
- (void)stopIndicatoWithThread;
@end


@implementation SendTweetViewController

@dynamic appDelegate;
@synthesize indicator;
@synthesize indicatorBase;
@synthesize twitterClient;
@synthesize editView;
@synthesize letterCountLabel;

- (void)dealloc {

  [indicator release];
  [indicatorBase release];
  [twitterClient release];
  [editView release];
  [letterCountLabel release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.indicator = nil;
  self.indicatorBase = nil;
  self.twitterClient = nil;
  self.editView = nil;
  self.letterCountLabel = nil;
  [super viewDidUnload];
}


- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}
  
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    twitterClient = [[TwitterClient alloc] init];

    editView = [[UITextView alloc] init];
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
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];

  setTweetEditField(editView, 5.0f, 310.0f, 140.0f);
  editView.text = [self.appDelegate tweetString];

  editView.delegate = self;
  [self.view addSubview:editView];
  [self countAndWriteTweetLength:[editView.text length]];

  [editView becomeFirstResponder];
}

#pragma mark

- (void)closeEditView {

  sending = NO;
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendTweet {

  if (sending == NO) {
    sending = YES;
    editView.backgroundColor = [UIColor colorWithRed: 0.6f green:0.6f blue:0.6f
					alpha:0.9];
    editView.editable = NO;
    [self startIndicator];
  
    [twitterClient updateStatus:editView.text delegate:self];
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

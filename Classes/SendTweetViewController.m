//
//  SendTweetViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SendTweetViewController.h"


@implementation SendTweetViewController

@dynamic appDelegate;
@synthesize twitterClient;
@synthesize editView;
@synthesize letterCountLabel;

- (void)dealloc {

  [twitterClient release];
  [editView release];
  [letterCountLabel release];
  [super dealloc];
}

- (void)viewDidUnload {

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

  CGRect frame;
  frame.origin.x = 5;
  frame.origin.y = 5;
  frame.size.width = 310;
  frame.size.height = 140;
  editView.backgroundColor = [UIColor whiteColor];
  editView.textColor = [UIColor blackColor];
  editView.font = [UIFont systemFontOfSize:15];
  editView.text = [self.appDelegate tweetString];
  editView.frame = frame;

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

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSLog(@"data: %@", dataString);
  [dataString release];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError");
  sending = NO;

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

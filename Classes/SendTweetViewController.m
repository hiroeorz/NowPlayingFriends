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

- (void)dealloc {

  [twitterClient release];
  [editView release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.twitterClient = nil;
  self.editView = nil;
  [super viewDidUnload];
}


- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}
  
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    twitterClient = [[TwitterClient alloc] init];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate cancelButton:@selector(closeEditView) target:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate completeButton:@selector(sendTweet) target:self];
}

- (void)viewWillAppear:(BOOL)animated {

  editView.text = [self.appDelegate tweetString];
  [super viewWillAppear:animated];
}

#pragma mark

- (void)closeEditView {

  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendTweet {
  
  [twitterClient updateStatus:editView.text delegate:self];
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSLog(@"data: %@", dataString);
  [dataString release];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError");
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

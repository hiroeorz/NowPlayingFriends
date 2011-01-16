//
//  YoutubeTypeSelectViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "NowPlayingFriendsAppDelegate.h"
#import "SendTweetViewController.h"
#import "YouTubeClient.h"
#import "YoutubeTypeSelectViewController.h"
#import "YouTubeListViewController.h"


@interface YoutubeTypeSelectViewController (Local)
-(void)openSelectViewAfterClose;
@end


@implementation YoutubeTypeSelectViewController

@dynamic appDelegate;
@synthesize tweetViewController;

- (void)dealloc {

  [tweetViewController release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.tweetViewController = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {
    openSelectViewFlag = NO;
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated {
  
  NSLog(@"closed!");

  if (openSelectViewFlag == YES) {
    openSelectViewFlag = NO;
    [self openSelectViewAfterClose];
  }
}

#pragma mark -
#pragma IBAction Methods

- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectTopOfRanking:(id)sender {

  YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
  [self dismissModalViewControllerAnimated:YES];
  [tweetViewController startIndicator];

  [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	   artist:[self.appDelegate nowPlayingArtistName]
	   delegate:tweetViewController
	   action:@selector(addYouTubeLink:)
	   count: 1];
}

- (IBAction)openSelectView:(id)sender {

  openSelectViewFlag = YES;
  [self dismissModalViewControllerAnimated:YES];
}

- (void)openSelectViewAfterClose {
  
  YouTubeListViewController *viewController = 
  [[YouTubeListViewController alloc] 
    initWithNibName:@"YouTubeListViewController" bundle:nil];
  viewController.typeSelectViewController = self;
  viewController.tweetViewController = tweetViewController;

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:nil  imageName:nil];
  [viewController release];
  [tweetViewController presentModalViewController:navController animated:YES];
}

#pragma mark -
#pragma Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

//
//  UserTimelineViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserTimelineViewController.h"
#import "TwitterClient.h"


@implementation UserTimelineViewController

@synthesize username;

- (id)initWithUserName:(NSString *)newUserName {

  self = [super initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  if (self != nil) {
    self.username = newUserName;
  }

  return self;
}

- (NSInteger)refreshTimeline {

  NSLog(@"updating user timeline data...");

  NSNumber *lastId = [super lastTweetId];
  TwitterClient *client = [[TwitterClient alloc] init];
  NSArray *newTimeline = [client getUserTimeLine:username sinceId:lastId];
  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"user timeline data updated.");

  return addCount;
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.navigationController.title = [self.appDelegate nowPlayingTitle];
  self.navigationController.tabBarItem.title = @"Song";
}

@end

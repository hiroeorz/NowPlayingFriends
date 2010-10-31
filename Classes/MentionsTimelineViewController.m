//
//  UserTimelineViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MentionsTimelineViewController.h"
#import "TwitterClient.h"


@implementation MentionsTimelineViewController

- (NSInteger)refreshTimeline {

  NSLog(@"updating user timeline data...");

  if (firstFlag) {
    firstFlag = NO;
    self.timeline = nil;
    self.beforeTimeline = nil;
  }

  NSNumber *lastId = [super lastTweetId];
  TwitterClient *client = [[TwitterClient alloc] init];
  NSArray *newTimeline = [client getMentionsTimeLineSince:lastId];
  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"user timeline data updated.");

  return addCount;
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.navigationController.title = @"Mentions";
  self.navigationController.tabBarItem.title = @"Mentions";

  self.navigationController.tabBarItem.badgeValue = nil;
}

@end

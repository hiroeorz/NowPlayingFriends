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

  TwitterClient *client = [[TwitterClient alloc] init];
  NSArray *newTimeline = [client getMentionsTimeLine];
  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"user timeline data updated.");

  return addCount;
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.navigationController.title = @"Mentions";
  self.navigationController.tabBarItem.title = @"Mentions";
}

@end

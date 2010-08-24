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

  self = [super init];

  if (self != nil) {
    self.username = newUserName;
  }

  return self;
}

- (void)refreshTimeline {

  NSLog(@"updating user timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSArray *newTimeline = [client getHomeTimeLine: @"hiroe_orz17"];

  @synchronized(timeline) {
    self.timeline = newTimeline;
  }

  [client release];

  NSLog(@"user timeline data updated.");
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.navigationController.title = [self.appDelegate nowPlayingTitle];
  self.navigationController.tabBarItem.title = @"Song";
}

@end

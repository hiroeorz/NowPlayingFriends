//
//  HomeTimelineViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HomeTimelineViewController.h"
#import "TwitterClient.h"


@implementation HomeTimelineViewController

- (NSInteger)refreshTimeline {

  NSLog(@"updating user timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *username = [client username];
  NSArray *newTimeline = [client getHomeTimeLine:username];
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

/**
 * @brief 特別な色のセルにするかどうかを判断する。
 */
- (BOOL)checkSpecialCell:(NSDictionary *)data {

  BOOL result = NO;
  NSString *text = [data objectForKey:@"text"];

  if ([text rangeOfString:myUserName].location != NSNotFound) {
    result = YES;
  }

  return result;
}

@end

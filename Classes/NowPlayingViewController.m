//
//  NowPlayingViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "TwitterClient.h"


@implementation NowPlayingViewController

- (NSInteger)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSArray *newTimeline = [client getSearchTimeLine:@"#nowplaying", nil];
  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"timeline data updated.");

  return addCount;
}

@end

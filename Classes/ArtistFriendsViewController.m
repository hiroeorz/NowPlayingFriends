//
//  ArtistFriendsViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ArtistFriendsViewController.h"
#import "TwitterClient.h"


@implementation ArtistFriendsViewController

- (void)viewDidLoad {

  [self.appDelegate addMusicPlayerNotification:self];
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  self.title = [self.appDelegate nowPlayingArtistName];
  self.navigationController.tabBarItem.title = @"Artist";
}

- (void)handle_NowPlayingItemChanged:(id)notification {

  self.title = [self.appDelegate nowPlayingArtistName];
  self.navigationController.tabBarItem.title = @"Artist";
  [super handle_NowPlayingItemChanged:notification];
}

- (NSInteger)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];
  NSString *tags = [self.appDelegate nowPlayingTagsString];

  NSArray *newTimeline = [client getSearchTimeLine:artistName, tags, nil];

  [client release];
  NSInteger addCount = [super createNewTimeline:newTimeline];

  NSLog(@"timeline data updated.");

  return addCount;
}

/**
 * @brief 特別な色のセルにするかどうかを判断する。このメソッドは継承先でオーバーライドされます。
 */
- (BOOL)checkSpecialCell:(NSDictionary *)data {

  NSInteger intervalSec = [self.appDelegate secondSinceNow:data];
  return (intervalSec < kArtistDefaultNowInterval);
}

@end

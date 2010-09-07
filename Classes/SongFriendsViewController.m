//
//  SongFriendsViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SongFriendsViewController.h"
#import "TwitterClient.h"


@implementation SongFriendsViewController

- (void)viewDidLoad {

  [self.appDelegate addMusicPlayerNotification:self];
  [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  self.title = [self.appDelegate nowPlayingTitle];
  self.navigationController.tabBarItem.title = @"Song";
}

- (void)handle_NowPlayingItemChanged:(id)notification {

  self.title = [self.appDelegate nowPlayingTitle];
  self.navigationController.tabBarItem.title = @"Song";
  [super handle_NowPlayingItemChanged:notification];
}

- (NSInteger)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSString *tags = [self.appDelegate nowPlayingTagsString];

  NSArray *newTimeline = [client getSearchTimeLine: songTitle, 
				 artistName, tags, nil];

  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"timeline data updated.");

  return addCount;
}

/**
 * @brief 特別な色のセルにするかどうかを判断する。
 */
- (BOOL)checkSpecialCell:(NSDictionary *)data {

  NSInteger intervalSec = [self.appDelegate secondSinceNow:data];
  return (intervalSec < kSongDefaultNowInterval);
}

@end

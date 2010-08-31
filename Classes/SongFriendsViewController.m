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

- (NSInteger)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSArray *newTimeline = [client getSearchTimeLine: songTitle, 
				 artistName, nil];
  [client release];

  NSInteger addCount = [super createNewTimeline:newTimeline];
  NSLog(@"timeline data updated.");

  return addCount;
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.navigationController.title = [self.appDelegate nowPlayingTitle];
  self.navigationController.tabBarItem.title = @"Song";
}

@end

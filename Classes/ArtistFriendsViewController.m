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

- (void)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSArray *newTimeline = [client getSearchTimeLine:artistName, nil];

  @synchronized(timeline) {
    self.timeline = newTimeline;
  }

  [client release];

  NSLog(@"timeline data updated.");
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  self.title = [self.appDelegate nowPlayingArtistName];
}

@end

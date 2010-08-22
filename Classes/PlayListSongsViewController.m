//
//  PlayListSongsViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlayListSongsViewController.h"
#import "NowPlayingFriendsAppDelegate.h"

@implementation PlayListSongsViewController

@synthesize playlist;
@synthesize musicPlayer;
@synthesize musicPlayerViewController;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  
  [playlist release];
  [musicPlayer release];
  [musicPlayerViewController release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.playlist = nil;
  self.musicPlayer = nil;
  self.musicPlayerViewController = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Initializer

- (id)initWithPlaylist:(MPMediaItemCollection *)newPlaylist {

  self = [super init];

  if (self != nil) {
    self.playlist = newPlaylist;
  }

  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {

  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {

  [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {

  return [playlist count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *SongOfPlaylistCellIdentifier = @"SongOfPlaylistCellIdentifier";
    
  UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:SongOfPlaylistCellIdentifier];

  if (cell == nil) {
    cell = [[[UITableViewCell alloc] 
	      initWithStyle:UITableViewCellStyleDefault 
	      reuseIdentifier:SongOfPlaylistCellIdentifier] autorelease];
  }

  NSArray *songs = [playlist items];
  MPMediaItem *song = [songs objectAtIndex:[indexPath row]];

  cell.textLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
        
  return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSInteger row = [indexPath row];

  [musicPlayer endGeneratingPlaybackNotifications];

  [musicPlayer stop];
  [musicPlayer setQueueWithItemCollection:playlist];
  [musicPlayer play]; [musicPlayer pause];

  for (int i = 0; i < row; i++) {
    [musicPlayer skipToNextItem];
  }

  [musicPlayer play];
  [musicPlayer beginGeneratingPlaybackNotifications];
}


@end

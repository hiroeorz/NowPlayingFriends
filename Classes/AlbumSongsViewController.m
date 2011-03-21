//
//  AlbumSongsViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlbumSongsViewController.h"
#import "NowPlayingFriendsAppDelegate.h"


@implementation AlbumSongsViewController

#pragma mark -
                                                                                                                        #pragma mark Memory management

- (void)dealloc {

  [super dealloc];
}

- (void)viewDidUnload {

  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Initializer

- (id)initWithAlbum:(MPMediaItemCollection *)newAlbum {
  
  self = [super init];

  if (self != nil) {
    self.playlist = newAlbum;
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

  return [[playlist items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *SongOfAlbumCellIdentifier = @"SongOfAlbumCellIdentifier";
    
  UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:SongOfAlbumCellIdentifier];

  if (cell == nil) {
    cell = [[[UITableViewCell alloc] 
	      initWithStyle:UITableViewCellStyleDefault 
	      reuseIdentifier:SongOfAlbumCellIdentifier] autorelease];
  }

  NSArray *songs = [playlist items];
  MPMediaItem *song = [songs objectAtIndex:[indexPath row]];

  cell.textLabel.text = [song valueForProperty:MPMediaItemPropertyTitle];
        
  return cell;
}

#pragma mark -

- (NSInteger)playListType {
  return kAlbumListType;
}


@end


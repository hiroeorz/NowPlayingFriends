//
//  MusicPlayerViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "TwitterClient.h"
#import "AlbumSongsViewController.h"
#import "PlayListSongsViewController.h"

@implementation MusicPlayerViewController

@synthesize timeline;
@synthesize beforeTimeline;
@synthesize albumImageView;
@synthesize volumeSlider;
@synthesize playButton;
@synthesize button;
@synthesize profileImageButtons;
@dynamic appDelegate;
@synthesize musicPlayer;
@synthesize songView;
@synthesize listView;
@synthesize playLists;
@synthesize albumLists;
@synthesize setFriendImageViewMutex;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [beforeTimeline release];
  [albumImageView release];
  [volumeSlider release];
  [profileImageButtons release];
  [songView release];
  [listView release];
  [playLists release];
  [albumLists release];
  [setFriendImageViewMutex release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.beforeTimeline = nil;
  self.albumImageView = nil;
  self.volumeSlider = nil;
  self.profileImageButtons = nil;
  self.songView = nil;
  self.listView = nil;
  self.playLists = nil;
  self.albumLists = nil;
  self.setFriendImageViewMutex = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  self.setFriendImageViewMutex = @"setFriendImageViewMutex";

  self.albumLists = [self.appDelegate albums];
  self.playLists = [self.appDelegate playLists];
  listmode = kListModeAlbum;

  [self setMusicPlayer:[MPMusicPlayerController iPodMusicPlayer]];
  [self.appDelegate addMusicPlayerNotification:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToListview) target:self];

  NSMutableArray *newProfileImageButtons = [[NSMutableArray alloc] init];
  self.profileImageButtons = newProfileImageButtons;
  [newProfileImageButtons release];

  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  volumeSlider.value = musicPlayer.volume;
  [self setMusicArtwork];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)changeVolume:(id)sender {
  musicPlayer.volume = volumeSlider.value;
}

/*
   MPMusicPlaybackStateStopped,
   MPMusicPlaybackStatePlaying,
   MPMusicPlaybackStatePaused,
   MPMusicPlaybackStateInterrupted,
   MPMusicPlaybackStateSeekingForward,
   MPMusicPlaybackStateSeekingBackward
 */
- (IBAction)togglePlayStop:(id)sender {

  NSLog(@"come toggle");
  if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
    [musicPlayer pause];
  } else {
    [musicPlayer play];
  }
}

- (IBAction)skipToNextItem:(id)sender {

  [musicPlayer skipToNextItem];
}

- (IBAction)skipToBeginningOrPreviousItem:(id)sender {

  [musicPlayer skipToBeginning];
}

- (IBAction)skipToPreviousItem:(id)sender {

  [musicPlayer skipToPreviousItem];
}

#pragma mark -
#pragma mark Timeline Refresh Methods

/**
 * @brief 再生中の曲が変わったときに呼ばれる。
 */
- (void)handle_NowPlayingItemChanged:(id)notification {

  NSLog(@"music changed!");
  self.title = [self.appDelegate nowPlayingTitle];
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];


  if (currentItem != nil) {
    [self setMusicArtwork];
    NSString *nowPlayingTitle = 
      [currentItem valueForProperty:MPMediaItemPropertyTitle];
    
    self.navigationController.title = nowPlayingTitle;
    self.navigationController.tabBarItem.title = @"Player";
    
    NSLog(@"title: %@", nowPlayingTitle);
    
    [self performSelectorInBackground:@selector(refreshProfileImages)
	  withObject:nil];
  }
}

/**
 * @brief 再生中の曲のイメージをUIImageViewにセットする。
 */
- (void)setMusicArtwork {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem != nil) {
    MPMediaItemArtwork *artwork = 
      [currentItem valueForProperty:MPMediaItemPropertyArtwork];
    
    UIImage *artworkImage; // = noArtworkImage;

    if (artwork) {
      artworkImage = 
	[artwork imageWithSize:CGSizeMake(albumImageView.frame.size.height, 
					  albumImageView.frame.size.height)];
    }

    self.albumImageView.image = artworkImage;
  }
}

- (void)refreshProfileImages {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  self.beforeTimeline = timeline;
  [self refreshTimeline];
  
  if (![timeline isEqualToArray:beforeTimeline]) {
    [self setFriendImageView];
    NSLog(@"refreshed.");
  }

  [pool release];
}

- (void)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSArray *newTimeline = [client getSearchTimeLine:songTitle, artistName, nil];

  @synchronized(timeline) {
    self.timeline = newTimeline;
  }

  [client release];

  NSLog(@"timeline data updated.");
}

- (void)setFriendImageView {

  @synchronized(setFriendImageViewMutex) {

    NSInteger i = 0;
    NSInteger x = 0;
    NSInteger y = albumImageView.frame.size.height - kProfileImageSize;
    NSInteger xRange = kProfileImageSize;
    
    for (NSDictionary *data in timeline) {
      UIButton *profileImageButton = nil;
      BOOL newButtonFlag = NO;
      
      if ([profileImageButtons count] >= (i + 1)) {
	newButtonFlag = NO;
	profileImageButton = [profileImageButtons objectAtIndex:i];
      }
      
      if (profileImageButton == nil) {
	newButtonFlag = YES;
	profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
      }
      
      profileImageButton.frame = CGRectMake(x, y, 
					    kProfileImageSize, 
					    kProfileImageSize);
      
      NSData *imageData = [self.appDelegate profileImage:data
			       getRemote:YES];
      
      NSDictionary *objects = 
	[[NSDictionary alloc] initWithObjectsAndKeys:
				profileImageButton, @"profileImageButton",
			      imageData, @"newImage", nil];
      
      if (newButtonFlag == YES) {
	[self performSelectorOnMainThread:@selector(addProfileImageButton:)
	      withObject:objects
	      waitUntilDone:YES];
      } else {
	[self performSelectorOnMainThread:@selector(setBackgroundImage:)
	      withObject:objects
	      waitUntilDone:YES];
      }
      
      x = x + xRange;
      
      if (((i + 1) % 5) == 0) {
	y = y - kProfileImageSize;
	x = 0;
      }
      i++;
    }
    
    if ([timeline count] < [profileImageButtons count]) {
      for (i; i < [profileImageButtons count]; i++) {
	UIButton *profileImageButton = [profileImageButtons objectAtIndex:i];
	[profileImageButton removeFromSuperview];
      }
    }
  }
}

- (void)addProfileImageButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  NSData *imageData = [objects objectForKey:@"newImage"];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];

  [self.albumImageView addSubview:profileImageButton];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];

  @synchronized(profileImageButtons) {
    [profileImageButtons addObject:profileImageButton];
    NSLog(@"buttons count:%d", [profileImageButtons count]);
  }
   
  profileImageButton.alpha = kProfileImageButtonAlpha;
}

- (void)setBackgroundImage:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  NSData *imageData = [objects objectForKey:@"newImage"];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];


  [self.appDelegate setAnimationWithView:profileImageButton
       animationType:UIViewAnimationTransitionFlipFromLeft];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];

  [UIView commitAnimations];
}

#pragma mark -
#pragma mark PlayList Methods

- (void)changeToListview {

  [self.appDelegate setAnimationWithView:self.view
       animationType:UIViewAnimationTransitionFlipFromLeft];

  if (songView.superview != nil) {
    [songView removeFromSuperview];
  }
  

  [self.view addSubview:listView];
  [UIView commitAnimations];


  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate playerButton:@selector(changeToSongview) target:self];
    
}

- (void)changeToSongview {

  [self.appDelegate setAnimationWithView:self.view
       animationType:UIViewAnimationTransitionFlipFromRight];

  if (listView.superview != nil) {
    [listView removeFromSuperview];
  }

  
  [self.view addSubview:songView];
  [UIView commitAnimations];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToListview) target:self];
}

/**
 * @brief リストモード変更処理を行うメソッド。
 */
- (void)listModeChanged:(id)sender {

  listmode = [sender selectedSegmentIndex];
  [listView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  
  if (listmode == kListModePlayList) {
    return [playLists count] + 1;
  } else {
    return [albumLists count] + 1;
  }
}

/**
 * @brief リスト画面先頭のアルバム／プレリスト切り替えボタン用のセルを返す。
 */

- (UITableViewCell *)cellForModeButtonWithTableView:(UITableView *)tableView {
    
  static NSString *PlayListModeButtonCellIdentifier = 
    @"PlayListModeButtonCellIdentifier";

  UITableViewCell *cell = 
    [tableView 
      dequeueReusableCellWithIdentifier:PlayListModeButtonCellIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
			     reuseIdentifier:PlayListModeButtonCellIdentifier];
    [cell autorelease];
    
    NSArray *modeArray = [[NSArray alloc] initWithObjects:@"Album",
					  @"Play list", nil];

    UISegmentedControl *segmentedControl = 
      [[UISegmentedControl alloc] initWithItems:modeArray];
    [modeArray release];

    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.frame = CGRectMake(5, 5, 310, 
					kModeSelectTableRowHeight - 10);
    segmentedControl.momentary = NO;
    segmentedControl.selectedSegmentIndex = kListModeAlbum;

    [segmentedControl addTarget:self action:@selector(listModeChanged:)
		      forControlEvents:UIControlEventValueChanged];

    [cell addSubview:segmentedControl];
    [segmentedControl release];
  }

  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  if ([indexPath row] == 0) {
    return [self cellForModeButtonWithTableView:tableView];
  }

  static NSString *PlayListCellIdentifier = @"PlayListCellIdentifier";

  UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:PlayListCellIdentifier];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				    reuseIdentifier:PlayListCellIdentifier];
    [cell autorelease];
  }

  NSInteger listRow = [indexPath row] - 1;

  if (listmode == kListModePlayList) {
    MPMediaPlaylist *playlist = [playLists objectAtIndex:listRow];
    cell.textLabel.text = 
      [playlist valueForProperty:MPMediaPlaylistPropertyName];
    cell.imageView.image = nil;

  } else {
    MPMediaItemCollection *album = [albumLists objectAtIndex:listRow];
    MPMediaItem *representativeItem = [album representativeItem];
    cell.textLabel.text = 
      [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];

    cell.textLabel.text = 
      [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    cell.detailTextLabel.text = 
      [representativeItem valueForProperty:MPMediaItemPropertyArtist];

    MPMediaItemArtwork *artwork = 
      [representativeItem valueForProperty:MPMediaItemPropertyArtwork];

    if (artwork) {
      cell.imageView.image = [artwork imageWithSize:CGSizeMake(50, 50)];
    }
  }

  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  if ([indexPath row] == 0) {
    return kModeSelectTableRowHeight;
  } else {
    return kPlayListTableRowHeight;
  }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSInteger listRow = [indexPath row] - 1;
  
  if (listmode == kListModePlayList) {
    MPMediaPlaylist *playlist = [playLists objectAtIndex:listRow];
    [musicPlayer setQueueWithItemCollection:playlist];
  } else {
    MPMediaItemCollection *album = [albumLists objectAtIndex:listRow];
    [musicPlayer setQueueWithItemCollection:album];
  }

  [musicPlayer play];
  [self changeToSongview];
}


- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

  NSInteger listRow = [indexPath row] - 1;
  id viewController;

  if (listmode == kListModeAlbum) {
    MPMediaItemCollection *album = [albumLists objectAtIndex:listRow];

     viewController = 
       (AlbumSongsViewController *)[[AlbumSongsViewController alloc] 
				     initWithAlbum:album];
  } else {
    MPMediaItemCollection *playlist = [playLists objectAtIndex:listRow];

     viewController = 
       (PlayListSongsViewController *)[[PlayListSongsViewController alloc] 
					initWithPlaylist:playlist];
  }

  [viewController setMusicPlayer:musicPlayer];
  [viewController setMusicPlayerViewController:self];
  [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

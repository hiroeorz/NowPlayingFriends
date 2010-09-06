//
//  MusicPlayerViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "AlbumSongsViewController.h"
#import "PlayListSongsViewController.h"
#import "UserInformationViewController.h"
#import "UserAuthenticationViewController.h"
#import "SendTweetViewController.h"

@implementation MusicPlayerViewController

@synthesize timeline;
@synthesize beforeTimeline;
@synthesize albumImageView;
@synthesize volumeSlider;
@synthesize playButton;
@synthesize button;
@synthesize profileImageButtons;
@synthesize nowButtons;
@dynamic appDelegate;
@synthesize musicPlayer;
@synthesize songView;
@synthesize listView;
@synthesize playLists;
@synthesize albumLists;
@synthesize refreshProfileImagesMutex;
@synthesize songListController;
@synthesize settingView;
@synthesize repeatModeControll;
@synthesize autoTweetSwitch;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [beforeTimeline release];
  [albumImageView release];
  [volumeSlider release];
  [profileImageButtons release];
  [nowButtons release];
  [songView release];
  [listView release];
  [playLists release];
  [albumLists release];
  [refreshProfileImagesMutex release];
  [songListController release];
  [settingView release];
  [repeatModeControll release];
  [autoTweetSwitch release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.timeline = nil;
  self.beforeTimeline = nil;
  self.albumImageView = nil;
  self.volumeSlider = nil;
  self.profileImageButtons = nil;
  self.nowButtons = nil;
  self.songView = nil;
  self.listView = nil;
  self.playLists = nil;
  self.albumLists = nil;
  self.refreshProfileImagesMutex = nil;
  self.songListController = nil;
  self.settingView = nil;
  self.repeatModeControll = nil;
  self.autoTweetSwitch = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    autoTweetMode = NO;
    autoTweetModeDefault = NO;
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  self.refreshProfileImagesMutex = @"refreshProfileImagesMutex";

  listmode = kListModeAlbum;

  [self setMusicPlayer:[MPMusicPlayerController iPodMusicPlayer]];
  [self.appDelegate addMusicPlayerNotification:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToListview) target:self];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate editButton:@selector(openEditView) target:self];

  NSMutableArray *newProfileImageButtons = [[NSMutableArray alloc] init];
  self.profileImageButtons = newProfileImageButtons;
  [newProfileImageButtons release];

  [self.appDelegate checkAuthenticateWithController:self];
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {

  self.albumLists = [self.appDelegate albums];
  self.playLists = [self.appDelegate playLists];
  [autoTweetSwitch setOn:autoTweetModeDefault animated:NO];
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

- (void)openUserInformationView:(id)sender {

  NSInteger tagIndex = [sender tag];
  NSDictionary *timelineData = [timeline objectAtIndex:tagIndex];
  NSString *username = [self.appDelegate username:timelineData];
  NSLog(@"tupped user:%@", username);

  UserInformationViewController *viewController = 
    [[UserInformationViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)changeAutoTweetMode:(id)sender {

  autoTweetMode = [sender isOn];
  autoTweetModeDefault = [sender isOn];
}

- (IBAction)changeVolume:(id)sender {

  if (musicPlayer.volume != volumeSlider.value) {
    musicPlayer.volume = volumeSlider.value;
  }
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
 * @brief プレイヤーの制御状況が変化したときに呼ばれる。
 */
- (void)handle_PlayBackStateDidChanged:(id)notification {
  
  UIImage *image;  

  if ([musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
    NSLog(@"playbackStateChanged:%@", @"stop");

    image = [UIImage imageNamed:@"Play.png"];
    [playButton setBackgroundImage:image 
		forState:UIControlStateNormal];
  }

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    NSLog(@"playbackStateChanged:%@", @"play");

    image = [UIImage imageNamed:@"Pause.png"];
    [playButton setBackgroundImage:image 
		forState:UIControlStateNormal];
  }

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    NSLog(@"playbackStateChanged:%@", @"pause");

    image = [UIImage imageNamed:@"Play.png"];
    [playButton setBackgroundImage:image 
		forState:UIControlStateNormal];    
  }

  if ([musicPlayer playbackState] == MPMusicPlaybackStateInterrupted) {
  }

  [self.appDelegate clearProfileImageCache];
}

/**
 * @brief プレイヤーの音量が変化したときに呼ばれる。
 */
- (void)handle_VolumeChanged:(id)notification {
  
  if (volumeSlider.value != musicPlayer.volume) {
    volumeSlider.value = musicPlayer.volume;
  }
}

/**
 * @brief 再生中の曲が変わったときに呼ばれる。
 */
- (void)handle_NowPlayingItemChanged:(id)notification {

  NSLog(@"music changed!");
  autoTweetMode = autoTweetModeDefault;

  self.title = [self.appDelegate nowPlayingTitle];
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil && listView.superview == nil) {
    self.title = @"Player";
    [self changeToListview];

  } else {

    [self setMusicArtwork];
    NSString *nowPlayingTitle = 
      [currentItem valueForProperty:MPMediaItemPropertyTitle];
    
    self.navigationController.title = nowPlayingTitle;
    self.navigationController.tabBarItem.title = @"Player";
    
    NSLog(@"title: %@", nowPlayingTitle);
    
    [self performSelectorInBackground:@selector(refreshProfileImages)
	  withObject:nil];

    if (autoTweetMode) {
      [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
	    withObject:nil];
    }
  }
}

/**
 * @brief 一定時間、再生曲が変わらなかったら自動ツイートする。
 */
- (void)sendAutoTweetAfterTimeLag {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
  NSInteger second = kAutoTweetTimeLag;

  NSString *title = [self.appDelegate nowPlayingTitle];
  NSDate *date = [[NSDate alloc] init];
  NSDate *nextStartDate = [[NSDate alloc] initWithTimeInterval:second 
					  sinceDate:date];

  [NSThread sleepUntilDate: nextStartDate];
  [date release];
  [nextStartDate release];

  NSString *nowSongTitle = [self.appDelegate nowPlayingTitle];

  if (autoTweetMode && [nowSongTitle isEqualToString:title]) {
    [self performSelectorOnMainThread:@selector(sendAutoTweet)
	  withObject:nil
	  waitUntilDone:YES];
  }

  [pool release];
}

/**
 * @brief 自動ツイートを実行する。
 */
- (void)sendAutoTweet {
  
  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *message = [self.appDelegate tweetString];
  [client updateStatus:message delegate:self];
  [client release];
}

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSLog(@"tweet sended. result:: %@", dataString);
  [dataString release];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

/**
 * @brief 再生中の曲のイメージをUIImageViewにセットする。
 */
- (void)setMusicArtwork {

  UIImage *artworkImage = 
    [self.appDelegate 
	 currentMusicArtWorkWithWidth:albumImageView.frame.size.height
	 height:albumImageView.frame.size.height
	 useDefault:YES];

  self.albumImageView.image = artworkImage;

}


- (void)refreshProfileImages {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSLog(@"waiting for mutex...");

  @synchronized(refreshProfileImagesMutex) {
    NSLog(@"starting refresh timeline");

    self.beforeTimeline = timeline;
    [self refreshTimeline];
    
    if (![timeline isEqualToArray:beforeTimeline]) {
      [self setFriendImageView];
      NSLog(@"refreshed.");
    }
  }

  [self.appDelegate cleanupProfileImageFileCache];
  [pool release];
}

- (void)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSArray *newTimeline = [client getSearchTimeLine:songTitle, artistName, nil];

  NSMutableArray *uniqArray = [[NSMutableArray alloc] init];
  NSMutableArray *checkArray = [[NSMutableArray alloc] init];

  for (NSDictionary *data in newTimeline) {
    NSString *username = [self.appDelegate username:data];

    if ([checkArray indexOfObject:username] == NSNotFound) {
      [uniqArray addObject:data];
      [checkArray addObject:username];
    }
  }

  @synchronized(timeline) {
    self.timeline = uniqArray;
  }

  [client release];
  [uniqArray release];
  [checkArray release];

  NSLog(@"timeline data updated.");
}

/**
 * @brief nowButtonをプロフィール画像ボタンから外してリリースする。
 */
- (void)releaseNowButtons {

  for (UIButton *nowButton in nowButtons) {
    if (nowButton.superview != nil) { [nowButton removeFromSuperview]; }
  }

  [nowButtons release];
  nowButtons = [[NSMutableArray alloc] init];
}

- (void)setFriendImageView {

  [self releaseNowButtons];

  NSInteger i = 0;
  NSInteger x = 0;
  NSInteger xRange = kProfileImageSize;
  NSInteger y = albumImageView.frame.size.height - xRange + 32;
  
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

      [profileImageButton addTarget:self 
			  action:@selector(openUserInformationView:)
			  forControlEvents:UIControlEventTouchUpInside];
    }

    profileImageButton.tag = i;

    profileImageButton.frame = CGRectMake(x, y, 
					  kProfileImageSize, 
					  kProfileImageSize);
    
    UIImage *newImage = [self.appDelegate profileImage:data
			     getRemote:YES];

    BOOL nowPlayer = [self checkNowPlayingUser:data];
    float alpha = kProfileImageButtonAlpha;
      
    if (nowPlayer) { alpha = 1.0f; }

    NSNumber *alphaNumber = [NSNumber numberWithFloat:alpha];
    
    NSDictionary *objects = 
      [[NSDictionary alloc] initWithObjectsAndKeys:
			      profileImageButton, @"profileImageButton",
			    newImage, @"newImage", 
			    alphaNumber, @"alpha",
			    nil];
    
    if (newButtonFlag == YES) {

      @synchronized(profileImageButtons) {
	[profileImageButtons addObject:profileImageButton];
      }

      [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	    withObject:objects
	    waitUntilDone:YES];

    }else if (newButtonFlag == NO && profileImageButton.superview == nil) {

      [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	    withObject:objects
	    waitUntilDone:YES];

    } else {

      [self performSelectorOnMainThread:@selector(setBackgroundImage:)
	    withObject:objects
	    waitUntilDone:NO];
    }

    [self performSelectorOnMainThread:@selector(setBackgroundApha:)
	  withObject:objects
	  waitUntilDone:NO];

    if (nowPlayer) {
      [self performSelectorOnMainThread:@selector(addNowButton:)
	    withObject:objects
	    waitUntilDone:NO];
    }

    x = x + xRange;
    
    if (((i + 1) % 5) == 0) {
      y = y - kProfileImageSize;
      x = 0;
    }
    i++;

    [objects release];
  }
  
  if ([timeline count] < [profileImageButtons count]) {
    for (int x = i; x < [profileImageButtons count]; x++) {
      UIButton *profileImageButton = [profileImageButtons objectAtIndex:x];
      [profileImageButton removeFromSuperview];
    }
  }
}

- (void)addProfileImageButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [self.songView addSubview:profileImageButton];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
}

- (void)setBackgroundImage:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [self.appDelegate setAnimationWithView:profileImageButton
       animationType:UIViewAnimationTransitionFlipFromLeft];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
    
  [UIView commitAnimations];
}

- (void)setBackgroundApha:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  float alpha = [[objects objectForKey:@"alpha"] floatValue];
  profileImageButton.alpha = alpha;
}

- (void)addNowButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIButton *nowButton = [self nowButton:@selector(openUserInformationView:) 
			      frame:kNowButtonFrame];

  nowButton.tag = profileImageButton.tag;
  [profileImageButton addSubview:nowButton];
  [nowButtons addObject:nowButton];
}

/**
 * @brief 一定時間内のポストデータかどうかを判断する。
 */
- (BOOL)checkNowPlayingUser:(NSDictionary *)data {

  NSInteger intervalSec = [self.appDelegate secondSinceNow:data];
  return (intervalSec < kMusicPlayerDefaultNowInterval);
}

- (UIButton *)nowButton:(SEL)selector
		  frame:(CGRect)frame{

  UIButton *nowButton = [UIButton buttonWithType:111];
  nowButton.frame = frame;
  
  [nowButton setTitle:@"♬" 
	     forState:UIControlStateNormal];
  
  [nowButton setTintColor:[UIColor redColor]];
  
  [nowButton addTarget:self action:selector
	     forControlEvents:UIControlEventTouchUpInside];
  
  nowButton.font = [UIFont boldSystemFontOfSize:16];
  nowButton.alpha = kNowButtonAlpha;
  
  return nowButton;
}

#pragma mark -
#pragma mark PlayList Methods

- (IBAction)changeRepeatMode:(id)sender {

  NSLog(@"changeRepeatMode:%d", [sender selectedSegmentIndex]);

 switch ([sender selectedSegmentIndex]) {
 case kRepeatModeNone:
   musicPlayer.repeatMode = MPMusicRepeatModeNone;
   break;
 case kRepeatModeOne:
   musicPlayer.repeatMode = MPMusicRepeatModeOne;
   break;
 case kRepeatModeAll:
   musicPlayer.repeatMode = MPMusicRepeatModeAll;
   break;
 }
}

- (IBAction)openSettingView:(id)sender {

  if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeNone;    
  }

  if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeOne;
  }

  if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeAll;
  }

  [self.appDelegate setHalfCurlAnimationWithController:self
       frontView:songView
       curlUp:YES];
  
  if (songView.superview != nil) {
    [songView removeFromSuperview];
  }

  [self.view addSubview:settingView];
  [UIView commitAnimations];
}

- (IBAction)closeSettingView:(id)sender {

  [self closeSettingView];
}

- (void)closeSettingView {

  [self.appDelegate setHalfCurlAnimationWithController:self
       frontView:songView
       curlUp:NO];
  
  if (settingView.superview != nil) {
    [settingView removeFromSuperview];
  }
  
  [self.view addSubview:songView];
  [UIView commitAnimations];
}

- (void)openEditView {

  autoTweetMode = NO;
  SendTweetViewController *viewController = 
    [[SendTweetViewController alloc] initWithNibName:@"SendTweetViewController"
				     bundle:nil];

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Tweet"  imageName:nil];

  [self presentModalViewController:navController animated:YES];
}

- (void)changeToListview {

  [self.appDelegate setAnimationWithView:self.view
       animationType:UIViewAnimationTransitionFlipFromLeft];

  if (songView.superview != nil) {
    [songView removeFromSuperview];
  }

  [self.view addSubview:listView];
  [UIView commitAnimations];


  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate playerButton:@selector(changeToSongview) 
	 target:self];    
}

- (void)changeToSongsListview {

  [self.appDelegate setAnimationWithView:songListController.view
       animationType:UIViewAnimationTransitionFlipFromLeft];

  if (songView.superview != nil) {
    [songView removeFromSuperview];
  }

  [self.view addSubview:listView];
  [UIView commitAnimations];


  songListController.navigationItem.rightBarButtonItem = 
    [self.appDelegate playerButton:@selector(changeToSongview) 
	 target:songListController];

  songListController.navigationItem.leftBarButtonItem = nil;
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

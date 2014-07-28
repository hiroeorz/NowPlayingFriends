//
//  MusicPlayerViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController+Local.h"
#import "MusicPlayerViewController+Settings.m"
#import "MusicPlayerViewController+Notification.m"
#import "MusicPlayerViewController+AutoTweet.m"
#import "MusicPlayerViewController+FriendsIcon.m"


@implementation MusicPlayerViewController

@dynamic appDelegate;
@synthesize addLinkArray;
@synthesize albumImageView;
@synthesize albumLists;
@synthesize animationOperator;
@synthesize autoTweetMode;
@synthesize autoTweetSwitch;
@synthesize baseView;
@synthesize beforeTimeline;
@synthesize button;
@synthesize friendGetModeControl;
@synthesize itemCollectionTitle;
@synthesize listView;
@synthesize musicControllerView;
@synthesize musicPlayer;
@synthesize musicSegmentedControl;
@synthesize nowButtons;
@synthesize playButton;
@synthesize playLists;
@synthesize profileImageButtons;
@synthesize recentSongTitle;
@synthesize refreshProfileImagesMutex;
@synthesize refreshTypeSegmentedControl;
@synthesize repeatModeControll;
@synthesize sending;
@synthesize sent;
@synthesize settingView;
@synthesize shuffleModeControll;
@synthesize songListController;
@synthesize songSearchBar;
@synthesize songView;
@synthesize subControlDisplayButton;
@synthesize subControlView;
@synthesize timeline;
@synthesize twitterClient;
@synthesize volumeSlider;
@synthesize youTubeButton;


#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [addLinkArray release];
  [albumImageView release];
  [albumLists release];
  [animationOperator release];
  [autoTweetSwitch release];
  [baseView release];
  [beforeTimeline release];
  [friendGetModeControl release];
  [itemCollectionTitle release];
  [listView release];
  [musicControllerView release];
  [musicSegmentedControl release];
  [nowButtons release];
  [playLists release];
  [profileImageButtons release];
  [refreshProfileImagesMutex release];
  [refreshTypeSegmentedControl release];
  [repeatModeControll release];
  [songSearchBar release];
  [settingView release];
  [shuffleModeControll release];
  [songListController release];
  [songView release];
  [subControlDisplayButton release];
  [timeline release];
  [twitterClient release];
  [volumeSlider release];
  [youTubeButton release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.addLinkArray = nil;
  self.albumImageView = nil;
  self.animationOperator = nil;
  self.autoTweetSwitch = nil;
  self.baseView = nil;
  self.beforeTimeline = nil;
  self.friendGetModeControl = nil;
  self.listView = nil;
  self.musicControllerView = nil;
  self.musicSegmentedControl = nil;
  self.nowButtons = nil;
  self.profileImageButtons = nil;
  self.refreshProfileImagesMutex = nil;
  self.refreshTypeSegmentedControl = nil;
  self.repeatModeControll = nil;
  self.songSearchBar = nil;
  self.settingView = nil;
  self.shuffleModeControll = nil;
  self.songListController = nil;
  self.songView = nil;
  self.subControlDisplayButton = nil;
  self.timeline = nil;
  self.volumeSlider = nil;
  self.youTubeButton = nil;

  /* not release objects
  self.twitterClient = nil;
  self.albumLists = nil;
  self.playLists = nil;
  */

  [self.appDelegate removeMusicPlayerNotification:self];
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
    sent = NO;
    sending = NO;
    subControlTouchCount = 0;
    updatingFlag = NO;
    cancelFlag = NO;
    updateAfterSafetyTime = NO;
    twitterClient = nil;
    addLinkArray = [[NSMutableArray alloc] init];
    itemCollectionTitle = nil;
    recentSongTitle = nil;
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  [super viewDidLoad];

  /* iPhone5用に必要に応じて一を下にずらす */
  [self.appDelegate fixHeightForAfteriPhone5View:songView];

  [self addPlayButton];
  [self addYouTubeButton];
  [self.appDelegate checkAuthenticateWithController:self];
  self.profileImageButtons = [NSMutableArray array];

  listmode = kListModeAlbum;
  
  if (twitterClient == nil) {
    self.twitterClient = [[[TwitterClient alloc] init] autorelease];
  }

  self.baseView = self.view;
  self.refreshProfileImagesMutex = @"refreshProfileImagesMutex";
  self.musicPlayer = self.appDelegate.musicPlayer;
  [self.appDelegate removeMusicPlayerNotification:self];
  [self.appDelegate addMusicPlayerNotification:self];

  self.animationOperator = [[[MusicPlayerNowPlayingAnimation alloc] init] 
			     autorelease];
  [self.appDelegate addMusicPlayerNotification:animationOperator];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToListview) target:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate editButton:@selector(openEditView) target:self];

  if ([twitterClient oAuthTokenExist] &&
      [musicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
	  withObject:nil];
  }

  UIButton *nowButton = [self nowButton:nil frame:kNowButtonInfoFrame];
  NSDictionary *dic = [self dictionaryOfGraphLinesWithButton:nowButton];
  animationOperator.sampleNowButtonDic = dic;
  [musicControllerView addSubview:nowButton];

  /* 再生中, 一時停止中 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying ||
      [musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    refreshTypeSegmentedControl.selectedSegmentIndex = kRefreshTypeSong;
  } else { /* それ以外 */
    refreshTypeSegmentedControl.selectedSegmentIndex = kRefreshTypeAll;
  }
}

- (void)viewWillAppear:(BOOL)animated {

  NSLog(@"viewWillAppear");
  updateAfterSafetyTime = NO;
  
  if (albumLists == nil) { self.albumLists = [self.appDelegate albums];}
  if (playLists == nil) { self.playLists = [self.appDelegate playLists];}

  [autoTweetSwitch setOn:self.appDelegate.autotweet_preference animated:NO];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  [self setViewTitleAndMusicArtwork];

  if (!animationOperator.isRunning) {
    [animationOperator performSelectorInBackground:@selector(startAnimation)
					withObject:nil];
  }

  if (self.appDelegate.get_twitterusers_preference) {
    [self refreshProfileImagesIfChanged];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)touchSubControl:(id)sender {

  subControlTouchCount ++;
  [self performSelectorInBackground:@selector(removeDisplaySubviewAfterSecond)
	withObject:nil];
}

- (IBAction)touchSubControllerDisplayButton:(id)sender {

  if (subControlView.alpha > 0.0) {
    [self removeDisplaySubview];
  } else {
    [self displaySubview];
  }
}

- (void)displaySubview {

  NSLog(@"displaySubview called.");
  subControlTouchCount ++;
  [UIView animateWithDuration:0.3
		   animations:^{subControlView.alpha = 0.90;}];
}

/**
 * @brief ページ上部の表示対象切り替えコントロールのビューを消す処理。 
 */
- (void)removeDisplaySubviewAfterSecond {
  id pool = [[NSAutoreleasePool alloc] init];

  NSInteger counterBefore = subControlTouchCount;
  [self.appDelegate sleep:kSubControlRemoteTimeout];

  if (subControlTouchCount == counterBefore) {
    [self removeDisplaySubview];
  }

  [pool release];
}

- (void)removeDisplaySubview {

  [self performSelectorOnMainThread:@selector(removeDisplaySubviewOnMainThread)
	withObject:nil
	waitUntilDone:NO];
}

- (void)removeDisplaySubviewOnMainThread {

  [UIView animateWithDuration:0.5
	  animations:^{subControlView.alpha = 0.0;}
          completion:^(BOOL finished) {}];
}

/**
 * @brief 再生中の曲のイメージをUIImageViewにセットする。
 */
- (void)setMusicArtwork {

  UIImage *artworkImage = nil;

  if ([musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
    artworkImage = 
      [self.appDelegate 
	   noArtworkImageWithWidth:albumImageView.frame.size.height
	   height:albumImageView.frame.size.height];
  } else {
    artworkImage = 
      [self.appDelegate 
	   currentMusicArtWorkWithWidth:albumImageView.frame.size.width
	   height:albumImageView.frame.size.height
	   useDefault:YES];
  }

  self.albumImageView.image = artworkImage;
}

/*
 * @brief 曲タイトル表示の切り替えとアルバムアートワークの変更を行う。
 */
- (void)setViewTitleAndMusicArtwork {

  UIControl *titleView = [self songTitleViewControl];

  UITextField *songTitleField = [self songTitleField];
  [titleView addSubview:songTitleField];

  UITextField *artistNameField = [self artistNameField];
  [titleView addSubview:artistNameField];

  [titleView addTarget:self
		action:@selector(openSelectSongViewFromNowPlayingAlbum)
       forControlEvents:UIControlEventTouchUpInside];

  self.navigationItem.titleView = titleView;

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil && listView.superview == nil) { 
    NSLog(@"Play Item is NULL");
    self.title = @"Player";
  } else {
    [self setMusicArtwork];
    NSString *nowPlayingTitle = [currentItem 
				  valueForProperty:MPMediaItemPropertyTitle];
    
    self.navigationController.title = nowPlayingTitle;
    self.navigationController.tabBarItem.title = @"Player";
    
    NSLog(@"title: %@", nowPlayingTitle);
  }
}

/**
 * @brief ナビゲーションバーに曲名とアーティスト名を表示するコントロールを返す。
 */
- (UIControl *)songTitleViewControl {

  UIButton *newButton = [UIButton buttonWithType:110];
  newButton.frame = CGRectMake(0.0f, 4.0f, 200.0f, 36.0f);
  [newButton setTitle:@"" forState:UIControlStateNormal];
  [newButton setValue:[UIColor blackColor] forKey:@"tintColor"];
  return newButton;
}

/**
 * @brief ナビゲーションバーに曲名を表示するフィールドを生成して返す。
 */
- (UITextField *)songTitleField {

  //  UITextField *songTitleField = [[UITextField alloc] 
  //				initWithFrame:CGRectMake(0.0f, 3.0f,
  //							 200.0f, 30.0f)];

  UITextField *songTitleField = [[UITextField alloc] 
				initWithFrame:CGRectMake(0.0f, -4.0f,
							 200.0f, 30.0f)];
  songTitleField.backgroundColor = nil;
  songTitleField.textColor = [UIColor darkGrayColor];
  songTitleField.font = [UIFont boldSystemFontOfSize:14.0f];
  songTitleField.textAlignment = UITextAlignmentCenter;
  songTitleField.text = [self.appDelegate nowPlayingTitle];
  songTitleField.enabled = NO;
  return [songTitleField autorelease];
}

/**
 * @brief ナビゲーションバーにアーティスト名を表示するフィールドを生成して返す。
 */
- (UITextField *)artistNameField {

  UITextField *artistNameField = [[UITextField alloc] 
				initWithFrame:CGRectMake(0.0f, 13.0f,
							 200.0f, 30.0f)];
  artistNameField.backgroundColor = nil;
  artistNameField.textColor = [UIColor grayColor];
  artistNameField.font = [UIFont boldSystemFontOfSize:12.0f];
  artistNameField.textAlignment = UITextAlignmentCenter;
  artistNameField.text = [self.appDelegate nowPlayingArtistName];
  artistNameField.enabled = NO;
  return [artistNameField autorelease];
}

/**
 * @brief 現在再生中のアルバムまたはプレイリストの曲リストを表示する。
 *        とりあえずプレイリストからの生成でもアルバムを表示する。
 */
- (void)openSelectSongViewFromNowPlayingAlbum {

  NSLog(@"open select view.");

  AlbumSongsViewController *viewController = nil;
  NSString *listTitle = nil;
  MPMediaItemCollection *itemCollection = nil;
  NSArray *collection = nil;

  NSLog(@"itemCollectionTitle:%@", itemCollectionTitle);

  listTitle = [self.appDelegate nowPlayingAlbumTitle];
  collection = [self.appDelegate searchAlbums:listTitle];

  itemCollection = [collection objectAtIndex:0];
  viewController = [[AlbumSongsViewController alloc] 
		     initWithAlbum:itemCollection];

  [viewController setMusicPlayer:musicPlayer];
  [viewController setMusicPlayerViewController:self];
  [viewController setPlayListTitle:listTitle];

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:listTitle  imageName:nil];

  viewController.leftButtonItem = 
    [self.appDelegate cancelButton:@selector(close) target:viewController];

  [self presentModalViewController:navController animated:YES];
  [viewController release];
}

#pragma mark -

- (void)addPlayButton {

  self.playButton = [self playButton:kPlayButtonFrame];
  [musicControllerView addSubview:playButton];
}

- (void)addRefreshButton {

  UIButton *refreshButton = [self refreshButton:kRefreshButtonFrame];
  [subControlView addSubview:refreshButton];
}

- (void)addYouTubeButton {

  self.youTubeButton = [self youTubeButton:kYouTubeButtonFrame];
  [musicControllerView addSubview:youTubeButton];
}

/**
 * @brief 一定時間内のポストデータかどうかを判断する。
 */
- (BOOL)checkNowPlayingUser:(NSDictionary *)data {

  NSInteger intervalSec = [self.appDelegate secondSinceNow:data];
  return (intervalSec < kMusicPlayerDefaultNowInterval);
}

- (UIButton *)nowButton:(SEL)selector frame:(CGRect)frame{

  UIButton *nowButton = [UIButton buttonWithType:UIButtonTypeCustom];
  nowButton.frame = frame;
  
  [nowButton setTitle:@"" forState:UIControlStateNormal];
  [nowButton setBackgroundImage:[UIImage imageNamed:@"red_button.png"]
		       forState:UIControlStateNormal];

  [nowButton addTarget:self action:selector
	     forControlEvents:UIControlEventTouchUpInside];
  
  nowButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
  nowButton.alpha = kNowButtonAlpha;
  
  return nowButton;
}

- (UIButton *)playButton:(CGRect)frame {

  UIButton *aPlayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  aPlayButton.frame = frame;
  
  [aPlayButton setImage:[UIImage imageNamed:@"Play.png"]
	       forState:UIControlStateNormal];
  
  [aPlayButton addTarget:self action:@selector(togglePlayStop:)
	       forControlEvents:UIControlEventTouchUpInside];
  
  [aPlayButton setTitle:@"" forState:UIControlStateNormal];
  aPlayButton.alpha = kPlayButtonAlpha;

  return aPlayButton;
}

- (UIButton *)refreshButton:(CGRect)frame {

  UIButton *aButton = [UIButton buttonWithType:111];
  aButton.frame = frame;

  UIColor *buttonColor = [UIColor blackColor];
  [aButton setValue:buttonColor forKey:@"tintColor"];

  [aButton addTarget:self action:@selector(togglePlayStop:)
	   forControlEvents:UIControlEventTouchUpInside];
  
  [aButton setTitle:@"Refresh" forState:UIControlStateNormal];
  aButton.alpha = kRefreshButtonAlpha;

  return aButton;
}

- (UIButton *)youTubeButton:(CGRect)frame {

  UIButton *aYouTubeButton = [UIButton buttonWithType:100];
  aYouTubeButton.frame = frame;
  
  UIColor *playButtonColor = [UIColor orangeColor];
  [aYouTubeButton setValue:playButtonColor forKey:@"tintColor"];

  [aYouTubeButton addTarget:self action:@selector(openYouTubeList:)
	       forControlEvents:UIControlEventTouchUpInside];
  
  [aYouTubeButton setTitle:@"YouTube" forState:UIControlStateNormal];
  aYouTubeButton.alpha = kYouTubeButtonAlpha;
  aYouTubeButton.titleLabel.textColor = [UIColor whiteColor];
  aYouTubeButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];

  return aYouTubeButton;
}

- (IBAction)openYouTubeList:(id)sender {

  YouTubeListViewController *viewController = 
  [[YouTubeListViewController alloc] 
    initWithNibName:@"YouTubeListViewController" bundle:nil];
  [self.navigationController pushViewController:viewController animated:YES];

  [viewController release];
}

- (void)openEditView {

  autoTweetMode = NO;
  SendTweetViewController *viewController = 
    [[SendTweetViewController alloc] initWithNibName:@"SendTweetViewController"
				     bundle:nil];
  viewController.musicPlayer = self;

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Tweet"  imageName:nil];
  [viewController release];

  [self presentModalViewController:navController animated:YES];
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

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToSongview)
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


  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToSongview)
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

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToListview) target:self];
}

/**
 * @brief リストモード変更処理を行うメソッド。
 */
- (void)listModeChanged:(id)sender {

  listmode = [sender selectedSegmentIndex];
  NSString *searchTerm = [songSearchBar text];

  if (searchTerm != nil && ![searchTerm isEqualToString:@""]) {
    if (listmode == kListModeAlbum) {
      self.albumLists = [self.appDelegate searchAlbums:searchTerm];
    } else {
      self.playLists = [self.appDelegate searchPlaylists:searchTerm];
    }
  }

  [listView reloadData];
}

#pragma mark -
#pragma mark Accelerometer Methods

/**
 * @brief iPhoneがシェイクされたときの動作：表示されているツイッターアイコンを更新する。
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer
	didAccelerate:(UIAcceleration *)acceleration {

  if (updatingFlag == NO) {
    if (acceleration.x > kAccelerationThreshold ||
	acceleration.y > kAccelerationThreshold ||
	acceleration.z > kAccelerationThreshold) {

      [self displaySubview];
      [self performSelectorInBackground:@selector(refreshProfileImages)
	    withObject:nil];
    }
  }
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
    } else {
      cell.imageView.image = [UIImage imageNamed:@"no_artwork_mini.png"];
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

    NSString *listTitle = 
      [playlist valueForProperty:MPMediaPlaylistPropertyName];

    self.itemCollectionTitle = listTitle;
    [musicPlayer setQueueWithItemCollection:playlist];

  } else {
    MPMediaItemCollection *album = [albumLists objectAtIndex:listRow];
    MPMediaQuery *query = [[[MPMediaQuery alloc] init] autorelease];
    MPMediaItem *representativeItem = [album representativeItem];
    NSString *albumTitle = [representativeItem valueForProperty:
						 MPMediaItemPropertyAlbumTitle];
    [query addFilterPredicate:[MPMediaPropertyPredicate 
				predicateWithValue:albumTitle
				forProperty: MPMediaItemPropertyAlbumTitle]];

    [musicPlayer setQueueWithQuery:query];
  }

  [musicPlayer play];
  [self changeToSongview];
}


- (void)tableView:(UITableView *)tableView 
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

  NSInteger listRow = [indexPath row] - 1;
  id viewController = nil;
  NSString *listTitle = nil;

  if (listmode == kListModeAlbum) { 
    MPMediaItemCollection *album = [albumLists objectAtIndex:listRow];    
    viewController = 
      (AlbumSongsViewController *)[[AlbumSongsViewController alloc] 
				    initWithAlbum:album];

    MPMediaItem *representativeItem = [album representativeItem];
    listTitle = 
      [representativeItem valueForProperty:MPMediaItemPropertyAlbumTitle];    

  } else {
    MPMediaItemCollection *playlist = [playLists objectAtIndex:listRow];

    viewController = 
      (PlayListSongsViewController *)[[PlayListSongsViewController alloc] 
				       initWithPlaylist:playlist];

    listTitle = [[playlist representativeItem] 
		  valueForProperty:MPMediaPlaylistPropertyName];
    self.itemCollectionTitle = listTitle;
  }

  [viewController setMusicPlayer:musicPlayer];
  [viewController setMusicPlayerViewController:self];
  [viewController setPlayListTitle:listTitle];
  [self.navigationController pushViewController:viewController animated:YES];
  [viewController release];
}

#pragma mark -
#pragma mark Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

  NSString *searchTerm = [searchBar text];

  if (listmode == kListModeAlbum) {
    self.albumLists = [self.appDelegate searchAlbums:searchTerm];
  } else {
    self.playLists = [self.appDelegate searchPlaylists:searchTerm];
  }
  [listView reloadData];
  [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)saearchBar
    textDidChange:(NSString *)searchTerm {
  
  if ([searchTerm length] == 0) {
    self.albumLists = [self.appDelegate albums];
    self.playLists = [self.appDelegate playLists];
    [listView reloadData];    
  } else {
    if (listmode == kListModeAlbum) { 
      self.albumLists = [self.appDelegate searchAlbums:searchTerm];
    } else {
      self.playLists = [self.appDelegate searchPlaylists:searchTerm];
    }
    [listView reloadData];
  }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

  songSearchBar.text = @"";
  self.albumLists = [self.appDelegate albums];
  self.playLists = [self.appDelegate playLists];
  [listView reloadData];
  [searchBar resignFirstResponder];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

- (void)stateLog {

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    NSLog(@"state: play");
  }
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    NSLog(@"state: pause");
  }
  if ([musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
    NSLog(@"state: stop");
  }
}

#pragma mark -
#pragma AutoTweet Call back.

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

@end

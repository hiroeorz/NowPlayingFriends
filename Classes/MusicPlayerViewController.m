//
//  MusicPlayerViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AlbumSongsViewController.h"
#import "ITunesStore.h"
#import "MusicPlayerViewController.h"
#import "PlayListSongsViewController.h"
#import "SendTweetViewController.h"
#import "UserAuthenticationViewController.h"
#import "UserInformationViewController.h"
#import "YouTubeClient.h"
#import "YouTubeListViewController.h"


#define kRefreshTypeSong 0
#define kRefreshTypeArtist 1
#define kRefreshTypeAll 2
#define kSubControlRemoteTimeout 6
#define kUpdateAfterSafetyTime 10


@interface MusicPlayerViewController (Local)

- (void)openUserInformationView:(id)sender;
- (void)setMusicArtwork;
- (void)refreshTimeline;
- (void)setFriendImageView;

- (void)removeDisplaySubview;
- (void)removeDisplaySubviewAfterSecond;

- (void)releaseNowButtons;
- (void)releaseProfileImageButtons;
- (void)addProfileImageButton:(NSDictionary *)objects;
- (void)setBackgroundImage:(NSDictionary *)objects;
- (void)setBackgroundApha:(NSDictionary *)objects;
- (BOOL)checkNowPlayingUser:(NSDictionary *)data;
- (UIButton *)nowButton:(SEL)selector
		  frame:(CGRect)frame;
- (void)addNowButton:(NSDictionary *)objects;
- (UIButton *)playButton:(CGRect)frame;
- (UIButton *)refreshButton:(CGRect)frame;
- (void)closeSettingView;
- (void)addPlayButton;
- (void)addYouTubeButton;
- (void)addRefreshButton;
- (void)openEditView;
- (void)changeToListview;
- (void)changeToSongview;
- (void)continuousTweetStopper;
- (void)sendAutoTweetAfterTimeLag;
- (void)sendAutoTweet;
- (void)sendAutoTweetDetail:(NSString *)message;
- (NowPlayingFriendsAppDelegate *)appDelegate;

- (void)createMessageIncludeITunes:(NSString *)linkUrl;
- (void)createMessageIncludeYouTube:(NSArray *)linkUrlArray;

- (UIButton *)youTubeButton:(CGRect)frame;

@end


@implementation MusicPlayerViewController

@dynamic appDelegate;
@synthesize addLinkArray;
@synthesize albumImageView;
@synthesize albumLists;
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
@synthesize refreshProfileImagesMutex;
@synthesize refreshTypeSegmentedControl;
@synthesize repeatModeControll;
@synthesize sending;
@synthesize sent;
@synthesize songSearchBar;
@synthesize settingView;
@synthesize shuffleModeControll;
@synthesize songListController;
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
    self.twitterClient = nil;
    addLinkArray = [[NSMutableArray alloc] init];
    itemCollectionTitle = nil;
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  [super viewDidLoad];
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

  updateAfterSafetyTime = NO;
  
  if (albumLists == nil) { self.albumLists = [self.appDelegate albums];}
  if (playLists == nil) { self.playLists = [self.appDelegate playLists];}

  [autoTweetSwitch setOn:self.appDelegate.autotweet_preference animated:NO];

  UIAccelerometer *accel = [UIAccelerometer sharedAccelerometer];
  accel.delegate = self;
  accel.updateInterval = kAccelerationUpdateInterval;

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  NSLog(@"viewDidAppear");
  [super viewDidAppear:animated];
  [self playBackStateDidChanged];  
  [self setViewTitleAndMusicArtwork];
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
		   animations:^{subControlView.alpha = 0.8;}];
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
 * @brief 音楽プレイヤー制御のボタンがタップされたときに呼ばれる。
 */
- (IBAction)changeMusicSegmentedControl:(id)sender {

  switch ([sender selectedSegmentIndex]) {
  case 0:
    [self skipToBeginningOrPreviousItem:sender];
    break;
  case 1:
    [self togglePlayStop:sender];
    break;
  case 2:
    [self skipToNextItem:sender];
    break;
  }
}

- (IBAction)changeRefreshType:(id)sender {
  
  subControlTouchCount ++;

  [self performSelectorInBackground:@selector(refreshProfileImages)
	withObject:nil];
  //[self performSelectorInBackground:@selector(removeDisplaySubviewAfterSecond)
  //	withObject:nil];
}

- (void)openUserInformationView:(id)sender {

  NSInteger tagIndex = [sender tag];
  NSDictionary *timelineData = [timeline objectAtIndex:tagIndex];
  NSString *username = [self.appDelegate username:timelineData];
  NSLog(@"tupped user:%@", username);

  UserInformationViewController *viewController = 
    [[UserInformationViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
  [viewController release];
}

- (IBAction)changeAutoTweetMode:(id)sender {

  autoTweetMode = [sender isOn];
  self.appDelegate.autotweet_preference = [sender isOn];

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying &&
      sent == NO && sending == NO) {
    [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
	  withObject:nil];    
  }
}

- (IBAction)changeFriendGetMode:(id)sender {
  
  NSLog(@"before change value is %@", 
	[NSNumber numberWithBool:self.appDelegate.get_twitterusers_preference]);

 switch ([sender selectedSegmentIndex]) {
 case 0: { //OFF
   NSLog(@"selected segment 0");
   cancelFlag = YES;
   self.appDelegate.get_twitterusers_preference = NO;
   [self releaseNowButtons];
   [self releaseProfileImageButtons];
 };
   break;
 case 1: { //ON
   NSLog(@"selected segment 1");
   cancelFlag = NO;
   self.appDelegate.get_twitterusers_preference = YES;
   [self performSelectorInBackground:@selector(refreshProfileImages)
	 withObject:nil];
 };
   break;
 }
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

   if (musicPlayer.currentPlaybackTime < 3.0) {
     [musicPlayer skipToPreviousItem];
   } else {
     [musicPlayer skipToBeginning];
   }
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

  [self playBackStateDidChanged];
}

- (void)playBackStateDidChanged {
  
  UIImage *image = nil;  
  UIImage *miniImage = nil;

  updateAfterSafetyTime = NO;

  /* 停止 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
    NSLog(@"playbackStateChanged:%@", @"stop");
    image = [UIImage imageNamed:@"Play.png"];
    miniImage = [UIImage imageNamed:@"Play_mini.png"];
  }

  /* 再生中 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    NSLog(@"playbackStateChanged:%@", @"play");
    image = [UIImage imageNamed:@"Pause.png"];
    miniImage = [UIImage imageNamed:@"Pause_mini.png"];
    if (autoTweetMode) {
      [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
			     withObject:nil];
    }
  }

  /* 一時停止中 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    NSLog(@"playbackStateChanged:%@", @"pause");
    image = [UIImage imageNamed:@"Play.png"];
    miniImage = [UIImage imageNamed:@"Play_mini.png"];
  }

  [playButton setImage:image forState:UIControlStateNormal];
  [musicSegmentedControl setImage:miniImage forSegmentAtIndex:1];

  [self setMusicArtwork];

  if (self.appDelegate.get_twitterusers_preference) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
			   withObject:nil];
  }
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
 * @brief 自動ツイート処理が複数平行して走らない為の処置。
 */
- (void)continuousTweetStopper {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSDate *date = [[NSDate alloc] init];
  NSDate *nextStartDate = 
    [[NSDate alloc] initWithTimeInterval:kUpdateAfterSafetyTime
		    sinceDate:date];
  
  [NSThread sleepUntilDate: nextStartDate];
  [date release];
  [nextStartDate release];

  updateAfterSafetyTime = NO;

  [pool release];
}

/**
 * @brief 再生中の曲が変わったときに呼ばれる。
 */
- (void)handle_NowPlayingItemChanged:(id)notification {

  NSLog(@"music changed!");
  sent = NO;
  sending = NO;
  updateAfterSafetyTime = NO;

  [self setViewTitleAndMusicArtwork];

  autoTweetMode = self.appDelegate.autotweet_preference;
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil && listView.superview == nil) {
    [self changeToListview];
  }

  if (self.appDelegate.get_twitterusers_preference) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
			   withObject:nil];
  }

  if (autoTweetMode && 
      [musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
			   withObject:nil];
    sending = YES;
  }
}

/**
 * @brief 一定時間、再生曲が変わらなかったら自動ツイートする。
 */
- (void)sendAutoTweetAfterTimeLag {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
  NSInteger second = kAutoTweetTimeLag;

  NSString *title = [self.appDelegate nowPlayingTitle];
  [self.appDelegate sleep:second];

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

  if (sent) {return;}

  if (updateAfterSafetyTime) {
    NSLog(@"Canceled auto tweet because after tweeting safety time.");
    return;
  }

  updateAfterSafetyTime = YES;
  [self performSelectorInBackground:@selector(continuousTweetStopper)
	withObject:nil];

  NSMutableArray *newAddLinkArray = [[NSMutableArray alloc] init];
  self.addLinkArray = newAddLinkArray;
  [newAddLinkArray release];

  if ([self.appDelegate use_itunes_preference]) {

    ITunesStore *store = [[[ITunesStore alloc] init] autorelease];
    [store searchLinkUrlWithTitle:[self.appDelegate nowPlayingTitle] 
	   album:[self.appDelegate nowPlayingAlbumTitle]
	   artist:[self.appDelegate nowPlayingArtistName]
	   delegate:self 
	   action:@selector(createMessageIncludeITunes:)];
    return;

  } else if ([self.appDelegate use_youtube_preference]) {
    YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
    
    [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	     artist:[self.appDelegate nowPlayingArtistName]
	     delegate:self
	     action:@selector(createMessageIncludeYouTube:)
	     count:1];
    return;

  } else {
    NSString *message = [self.appDelegate tweetString];
    [self sendAutoTweetDetail:message];
  }
}

- (NSString *)tweetString:(NSString *)aTweetString
	   withLinksArray:(NSArray *)aLinksArray {

  if (aLinksArray == nil || [aLinksArray count] == 0) { return aTweetString; }

  NSString *newString = nil;
  NSString *resultString = [[[NSString alloc] initWithString:aTweetString]
			    autorelease];

  for (NSString *aLink in aLinksArray) {
    NSString *addedString = [[NSString alloc] 
			      initWithFormat:@"%@ %@", resultString, aLink];
    newString = [[NSString alloc] initWithString:addedString];
    [addedString release];

    if ([newString length] > kMaxTweetLength) {
      [newString release];
      continue;
    }
    
    resultString = [[[NSString alloc] initWithString:newString] autorelease];
    [newString release];
  }

  return resultString;
}

/**
 * @brief 受け取ったYouTubeリンクをメッセージに埋込む。YouTubeクライアントから呼ばれる。
 */
- (void)createMessageIncludeYouTube:(NSArray *)linkUrlArray {

  //NSString *message = [self.appDelegate tweetString];
  NSString *message = [self tweetString:[self.appDelegate tweetString]
			    withLinksArray:addLinkArray];
  NSString *linkedMessage = nil;
  
  if (linkUrlArray == nil || [linkUrlArray count] == 0) {
    linkedMessage = message;
  } else {
    NSDictionary *linkDic = [linkUrlArray objectAtIndex:0];
    NSString *linkUrl = [linkDic objectForKey: @"linkUrl"];

    linkedMessage = [[[NSString alloc] 
		       initWithFormat:@"%@ %@", message, linkUrl] autorelease];
    if ([linkedMessage length] > kMaxTweetLength) {linkedMessage = message;}
  }
  
  [self sendAutoTweetDetail: linkedMessage];
}

/**
 * @brief 受け取ったiTunes検索リンクをメッセージに埋込む。
          YouTubeクライアントから呼ばれる。
 */
- (void)createMessageIncludeITunes:(NSString *)linkUrl {

  if (linkUrl != nil) { [addLinkArray addObject:linkUrl]; }

  if ([self.appDelegate use_youtube_preference]) { /* call youtube if YES */
    YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
    
    [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	     artist:[self.appDelegate nowPlayingArtistName]
	     delegate:self
	     action:@selector(createMessageIncludeYouTube:)
	     count:1];
    return;
  }

  NSString *message = [self.appDelegate tweetString];
  NSString *linkedMessage = nil;

  if (linkUrl == nil) {
    linkedMessage = message;
  } else {
    linkedMessage = [[[NSString alloc] 
		       initWithFormat:@"%@ iTunes: %@", message, linkUrl] 
		      autorelease];
    if ([linkedMessage length] > kMaxTweetLength) {linkedMessage = message;}
  }

  [self sendAutoTweetDetail: linkedMessage];
}

/**
 * @brief 引数で受け取ったメッセージを送信する。
 */
- (void)sendAutoTweetDetail:(NSString *)message {

  if ([message length] >= kMaxTweetLength) {/* それでも長かったら切り捨て */
    message = [message substringToIndex:kMaxTweetLength];
  }

  [twitterClient updateStatus:message inReplyToStatusId:nil
		 withArtwork:[self.appDelegate auto_upload_picture_preference]
		 delegate:self];
  sending = NO;
  sent = YES;
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

  UIView *titleView = [[UIControl alloc] 
			initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 45.0f)];

  UITextField *songTitleField = [[UITextField alloc] 
				initWithFrame:CGRectMake(0.0f, 3.0f,
							 200.0f, 35.0f)];
  songTitleField.backgroundColor = nil;
  songTitleField.textColor = [UIColor whiteColor];
  songTitleField.font = [UIFont boldSystemFontOfSize:16.0f];
  songTitleField.textAlignment = UITextAlignmentCenter;
  songTitleField.text = [self.appDelegate nowPlayingTitle];
  songTitleField.enabled = NO;
  [titleView addSubview:songTitleField];

  UITextField *artistNameField = [[UITextField alloc] 
				initWithFrame:CGRectMake(0.0f, 25.0f,
							 200.0f, 30.0f)];
  artistNameField.backgroundColor = nil;
  artistNameField.textColor = [UIColor whiteColor];
  artistNameField.font = [UIFont boldSystemFontOfSize:12.0f];
  artistNameField.textAlignment = UITextAlignmentCenter;
  artistNameField.text = [self.appDelegate nowPlayingArtistName];
  artistNameField.enabled = NO;
  [titleView addSubview:artistNameField];

  [titleView addTarget:self
		action:@selector(openSelectSongViewFromNowPlayingAlbum)
       forControlEvents:UIControlEventTouchUpInside];

  self.navigationItem.titleView = titleView;
  [titleView release];
  [songTitleField release];
  [artistNameField release];

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil && listView.superview == nil) {
    NSLog(@"Play Item is NULL");
    self.title = @"Player";
  } else {
    [self setMusicArtwork];
    NSString *nowPlayingTitle = 
      [currentItem valueForProperty:MPMediaItemPropertyTitle];
    
    self.navigationController.title = nowPlayingTitle;
    self.navigationController.tabBarItem.title = @"Player";
    
    NSLog(@"title: %@", nowPlayingTitle);
  }
}

/**
 * @brief 現在再生中のアルバムまたはプレイリストの曲リストを表示する。
 */
- (void)openSelectSongViewFromNowPlayingAlbum {

  NSLog(@"open select view.");

  AlbumSongsViewController *viewController = nil;
  NSString *listTitle = nil;
  MPMediaItemCollection *itemCollection = nil;
  NSArray *collection = nil;

  NSLog(@"itemCollectionTitle:%@", itemCollectionTitle);

  if (listmode == kListModePlayList) {
    listTitle = itemCollectionTitle;
    collection = [self.appDelegate searchPlaylists:itemCollectionTitle];
  } else {
    listTitle = [self.appDelegate nowPlayingAlbumTitle];
    collection = [self.appDelegate searchAlbums:listTitle];
  }

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

- (void)refreshProfileImages {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  cancelFlag = YES;
  NSLog(@"waiting for mutex...");
  
  @synchronized(refreshProfileImagesMutex) {

    @try {
      if (self.appDelegate.get_twitterusers_preference == YES) {
	if (![twitterClient oAuthTokenExist]) {
	  NSLog(@"oAuth Token is not exist. refresh not executed.");
	  return;
	}
	
	cancelFlag = NO;
	updatingFlag = YES;
	NSLog(@"starting refresh timeline");
	
	self.beforeTimeline = timeline;
	[self refreshTimeline];
	[self setFriendImageView];
      }
    }
    @finally {
      updatingFlag = NO;
      
      if (cancelFlag) {
	[self releaseNowButtons];
	[self releaseProfileImageButtons];
      }
    }
  }

  [pool release];
}

- (void)refreshTimeline {

  NSLog(@"updating timeline data...");
  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];
  NSString *tags = [self.appDelegate nowPlayingTagsString];
  NSArray *newTimeline = nil;
  
  NSLog(@"INDEX: %d", refreshTypeSegmentedControl.selectedSegmentIndex);

  if (cancelFlag) {
    NSLog(@"Stopping refresh timeline because cacelFlag=YES");
    [client release];
    return;
  }

  switch (refreshTypeSegmentedControl.selectedSegmentIndex) {
  case kRefreshTypeSong:
    newTimeline = [client getSearchTimeLine: songTitle, artistName, tags, nil];
    break;
  case kRefreshTypeArtist:
    newTimeline = [client getSearchTimeLine: artistName, tags, nil];
    break;
  case kRefreshTypeAll:
    newTimeline = [client getSearchTimeLine: tags, nil];
    break;
  }

  NSMutableArray *uniqArray = [[NSMutableArray alloc] init];
  NSMutableArray *checkArray = [[NSMutableArray alloc] init];

  for (NSDictionary *data in newTimeline) {
    NSString *username = [self.appDelegate username:data];

    if ([checkArray indexOfObject:username] == NSNotFound) {
      [uniqArray addObject:data];
      [checkArray addObject:username];
    }
  }

  self.timeline = uniqArray;

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

- (void)releaseProfileImageButtons {

  for (UIButton *profileButton in profileImageButtons) {
    if (profileButton.superview != nil) { [profileButton removeFromSuperview]; }
  }
}

- (void)setFriendImageView {

  [self releaseNowButtons];

  NSInteger i = 0;
  NSInteger x = 0;
  NSInteger xRange = kProfileImageSize;
  NSInteger y = albumImageView.frame.size.height - xRange + 32;
  
  for (NSDictionary *data in timeline)  {
    if (cancelFlag || timeline == beforeTimeline) { break; }

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
      
      [profileImageButtons addObject:profileImageButton];

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

- (UIButton *)nowButton:(SEL)selector
		  frame:(CGRect)frame{

  UIButton *nowButton = [UIButton buttonWithType:111];
  nowButton.frame = frame;
  
  [nowButton setTitle:@"♬" 
	     forState:UIControlStateNormal];
  
  [nowButton setValue:[UIColor redColor] forKey:@"tintColor"];

  [nowButton addTarget:self action:selector
	     forControlEvents:UIControlEventTouchUpInside];
  
  nowButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
  nowButton.alpha = kNowButtonAlpha;
  
  return nowButton;
}

- (UIButton *)playButton:(CGRect)frame {

  UIButton *aPlayButton = [UIButton buttonWithType:111];
  aPlayButton.frame = frame;
  
  [aPlayButton setImage:[UIImage imageNamed:@"Play.png"]
	       forState:UIControlStateNormal];
  
  UIColor *playButtonColor = [UIColor blackColor];
  [aPlayButton setValue:playButtonColor forKey:@"tintColor"];

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

  UIButton *aYouTubeButton = [UIButton buttonWithType:111];
  aYouTubeButton.frame = frame;
  
  UIColor *playButtonColor = [UIColor scrollViewTexturedBackgroundColor];
  [aYouTubeButton setValue:playButtonColor forKey:@"tintColor"];

  [aYouTubeButton addTarget:self action:@selector(openYouTubeList:)
	       forControlEvents:UIControlEventTouchUpInside];
  
  [aYouTubeButton setTitle:@"YouTube" forState:UIControlStateNormal];
  aYouTubeButton.alpha = kYouTubeButtonAlpha;

  return aYouTubeButton;
}

- (IBAction)openYouTubeList:(id)sender {

  YouTubeListViewController *viewController = 
  [[YouTubeListViewController alloc] 
    initWithNibName:@"YouTubeListViewController" bundle:nil];
  [self.navigationController pushViewController:viewController animated:YES];

  [viewController release];
}

#pragma mark -
#pragma mark PlayList Methods

- (IBAction)changeShuffleMode:(id)sender {

  NSLog(@"changeShuffleMode:%d", [sender selectedSegmentIndex]);

 switch ([sender selectedSegmentIndex]) {
 case kShuffleModeNone:
   NSLog(@"0");
   musicPlayer.shuffleMode = MPMusicShuffleModeOff;
   break;
 case kShuffleModeOne:
   NSLog(@"1");
   musicPlayer.shuffleMode = MPMusicShuffleModeSongs;
   break;
 case kShuffleModeAll:
   NSLog(@"2");
   musicPlayer.shuffleMode = MPMusicShuffleModeAlbums;
   break;
 }
}

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

  if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeNone;    
  }
  if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeOne;    
  }
  if (musicPlayer.shuffleMode == MPMusicShuffleModeAlbums) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeAll;    
  }
  

  if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeNone;    
  }
  if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeOne;
  }
  if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeAll;
  }

  if (self.appDelegate.get_twitterusers_preference) {
    friendGetModeControl.selectedSegmentIndex = 1;
  } else {
    friendGetModeControl.selectedSegmentIndex = 0;
  }

  [self.appDelegate setHalfCurlAnimationWithController:self
       frontView:songView
       curlUp:YES];
  
  if (songView.superview != nil) {
    [songView removeFromSuperview];
  }

  [self.baseView addSubview:settingView];
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
  viewController.musicPlayer = self;

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Tweet"  imageName:nil];
  [viewController release];

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

  self.navigationItem.leftBarButtonItem = 
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

@end

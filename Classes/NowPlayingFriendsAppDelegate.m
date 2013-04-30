//
//  NowPlayingFriendsAppDelegate.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NowPlayingFriendsAppDelegate.h"

#import "ArtistFriendsViewController.h"
#import "FBAuthViewController.h"
#import "HomeTimelineViewController.h"
#import "ITunesStore.h"
#import "MentionsTimelineViewController.h"
#import "MusicPlayerViewController.h"
#import "NowPlayingViewController.h"
#import "SettingViewController.h"
#import "SongFriendsViewController.h"
#import "TwitterClient.h"
#import "UserAuthenticationViewController.h"
#import "UserTimelineViewController.h"
#import "YouTubeClient.h"

@interface NowPlayingFriendsAppDelegate (Local)

- (NSArray *)searchAlbumsOrPlaylists:(NSString *)searchTerm
		   mediaGroupingType:(NSInteger)groupingType
		   predicateProperty:(NSString *)mediaItemProperty;

- (NSArray *)searchAlbumsOrPlaylistsBySong:(NSString *)searchTerm
			 mediaGroupingType:(NSInteger)groupingType
			 predicateProperty:(NSString *)mediaItemProperty;

- (UIImage *)streatchedImage:(UIImage *)orgImage
		       width:(NSInteger)width height:(NSInteger)height;
@end


@implementation NowPlayingFriendsAppDelegate

@dynamic auto_upload_picture_preference;
@dynamic autotweet_preference;
@dynamic get_twitterusers_preference;
@dynamic isForeGround;
@dynamic manual_upload_picture_preference;
@dynamic select_youtube_link_preference;
@dynamic template_preference;
@dynamic use_itunes_manual_preference;
@dynamic use_itunes_preference;
@dynamic use_youtube_manual_preference;
@dynamic use_youtube_preference;
@dynamic fb_post_preference;
@dynamic tw_post_preference;
@dynamic userDefaults;
@synthesize bgTask;
@synthesize isBackGround;
@synthesize musicPlayer;
@synthesize musicPlayerViewController;
@synthesize profileImages;
@synthesize profileImagesIndex;
@synthesize tabBarController;
@synthesize window;

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];
}

- (void)dealloc {
    
  [managedObjectContext_ release];
  [managedObjectModel_ release];
  [musicPlayerViewController release];
  [persistentStoreCoordinator_ release];
  [tabBarController release];
  [profileImages release];
  [profileImagesIndex release];
  [window release];
  [super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)isForeGround {
  return !isBackGround;
}

/**
 * @brief 与えられたviewControllerを含むナビゲーションビューをタブのタイトルと画像を設定して返す。
 */
- (UINavigationController *)navigationWithViewController:(id)viewController
						   title:(NSString *)title 
					       imageName:(NSString *)imageName {

  [viewController setTitle:title];

  UINavigationController *navController = 
    [[UINavigationController alloc] initWithRootViewController:viewController];
  
  navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  navController.tabBarItem.image = [UIImage imageNamed:imageName];

  return [navController autorelease];
}

- (void)addMusicPlayerNotification:(id)object {

  NSNotificationCenter *notificationCenter = 
    [NSNotificationCenter defaultCenter];

  [notificationCenter 
    addObserver:object
    selector:@selector(handle_NowPlayingItemChanged:)
    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
    object:musicPlayer];

  [notificationCenter 
    addObserver: object
    selector: @selector (handle_PlayBackStateDidChanged:)
    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
    object: musicPlayer];

  [notificationCenter
    addObserver:object
    selector:@selector(handle_VolumeChanged:)
    name:MPMusicPlayerControllerVolumeDidChangeNotification
    object:musicPlayer];

  [musicPlayer beginGeneratingPlaybackNotifications];
}

- (void)removeMusicPlayerNotification:(id)object {

  NSNotificationCenter *notificationCenter = 
    [NSNotificationCenter defaultCenter];

  [notificationCenter 
    removeObserver:object
    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
    object:musicPlayer];
  
  [notificationCenter 
    removeObserver: object
    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
    object: musicPlayer];

  [notificationCenter
    removeObserver:object
    name:MPMusicPlayerControllerVolumeDidChangeNotification
    object:musicPlayer];

  [musicPlayer endGeneratingPlaybackNotifications];
}

- (void)setupMusicPlayer {

  self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
}

- (NSString *)nowPlayingTagsString {

  return KNowPlayingTags;
}

/**
 * @brief 現在のWindowの高さをかえす。
 */
- (CGFloat)windowHeight {
  return self.window.frame.size.height;
}

/**
 * @brief 現在のWindowの高さをかえす。
 */
- (CGFloat)windowWidth {
  return self.window.frame.size.width;
}

/**
 * @brief iPhone4までと比べた場合のWindowの高さの補正値を返す。
 */
- (CGFloat)windowHeightFixVal {
  return ([self windowHeight] - 480);
}

/**
 * @brief 渡されたviewの高さをiPhone5以降縦長になった分伸ばす。
 */
- (void)fixHeightForAfteriPhone5View:(UIView *)aView {

  CGRect frame = aView.frame;
  frame.size.height = frame.size.height + [self windowHeightFixVal];
  aView.frame = frame;
}

/**
 * @brief 渡されたviewの縦方向の位置をiPhone5以降縦長になった分下に下ろす。
 * 未使用（使用する時はこのコメント行を消す）
 */
- (void)fixPositionForAfteriPhone5View:(UIView *)aView {

  CGRect frame = aView.frame;
  frame.origin.y = frame.origin.y + [self windowHeightFixVal];
  aView.frame = frame;
}

/**
 * @brief アルバム情報を持つMPMediaItemCollectionの配列を返します。
 */
- (NSArray *)albums {
  
  MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query setGroupingType: MPMediaGroupingAlbum];

  NSArray *albums = [query collections];
  [query release];

  return albums;
}

/**
 * @brief プレイリスト情報を持つMPMediaPlaylistの配列を返します。
 */
- (NSArray *)playLists {
  
  MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query setGroupingType: MPMediaGroupingPlaylist];

  NSArray *albums = [query collections];
  [query release];

  return [self uniqArray:albums];
}

/**
 * @brief 与えられた文字列を含むアルバムを検索する。
 */
- (NSArray *)searchAlbums:(NSString *)searchTerm {
  
  NSMutableArray *array = [NSMutableArray array];
  [array addObjectsFromArray:[self searchAlbumsByAlbumName:searchTerm]];
  [array addObjectsFromArray:[self searchAlbumsByArtistName:searchTerm]];

  return [self uniqArray:array];
}

/**
 * @brief 与えられた文字列を含むプレイリストを検索する。
 */
- (NSArray *)searchPlaylists:(NSString *)searchTerm {
  
  NSMutableArray *array = [NSMutableArray array];
  [array addObjectsFromArray:[self searchPlaylistsByPlaylistName:searchTerm]];
  [array addObjectsFromArray:[self searchPlaylistsByArtistName:searchTerm]];

  return [self uniqArray:array];
}

/**
 * @brief 与えられた条件のアルバムまたはプレイリストを検索する。
 */
- (NSArray *)searchAlbumsOrPlaylists:(NSString *)searchTerm
		   mediaGroupingType:(NSInteger)groupingType
		   predicateProperty:(NSString *)mediaItemProperty {
  
 MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query setGroupingType: groupingType];

  MPMediaPropertyPredicate *predicate = 
    [MPMediaPropertyPredicate predicateWithValue: searchTerm
			     forProperty: mediaItemProperty
			     comparisonType:MPMediaPredicateComparisonContains];
  
  [query addFilterPredicate:predicate];

  NSArray *albums = [query collections];
  [query release];
  
  return albums;
}

/**
 * @brief 与えられた文字列を含むアーティストのアルバムオブジェクトを返す。
 */
- (NSArray *)searchPlaylistsByPlaylistName:(NSString *)searchTerm {

  MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query setGroupingType:MPMediaGroupingPlaylist];

  NSArray *playlists = [query collections];
  [query release];

  NSMutableArray *array = [NSMutableArray array];
  MPMediaPlaylist *playlist = nil;

  for (playlist in playlists) {
    NSString *name = [playlist valueForProperty:MPMediaPlaylistPropertyName];

    if ([name rangeOfString:searchTerm].location != NSNotFound) {
      [array addObject:playlist];
    }
  }

  return array;
}

/**
 * @brief 与えられた文字列を含むアーティストの曲を含むプレイリストオブジェクトを返す。
 */
- (NSArray *)searchPlaylistsByArtistName:(NSString *)searchTerm {

  return [self searchAlbumsOrPlaylistsBySong:searchTerm
	       mediaGroupingType:MPMediaGroupingPlaylist
	       predicateProperty:MPMediaItemPropertyArtist];
}

/**
 * @brief 与えられた条件の曲を含むアルバムまたはプレイリストを検索する。
 */
- (NSArray *)searchAlbumsOrPlaylistsBySong:(NSString *)searchTerm
		   mediaGroupingType:(NSInteger)groupingType
		   predicateProperty:(NSString *)mediaItemProperty {
  

  MPMediaQuery *query = [[MPMediaQuery alloc] init];
  [query setGroupingType:groupingType];

  NSArray *playlists = [query collections];
  [query release];

  NSMutableArray *array = [NSMutableArray array];
  MPMediaPlaylist *playlist = nil;

  for (playlist in playlists) {
    NSArray *songs = [playlist items];
    MPMediaItem *song = nil;

    for (song in songs) {
      NSString *term = [song valueForProperty:mediaItemProperty];

      if ([term rangeOfString:searchTerm].location != NSNotFound) {
	[array addObject:playlist];
	break;
      }
    }
  }

  return array;
}


/**
 * @brief 与えられた文字列を含むアーティストのアルバムオブジェクトを返す。
 */
- (NSArray *)searchAlbumsByArtistName:(NSString *)searchTerm {

  return [self searchAlbumsOrPlaylists:searchTerm
	       mediaGroupingType:MPMediaGroupingAlbum
	       predicateProperty:MPMediaItemPropertyArtist];
}

/**
 * @brief 与えられた文字列を含むアルバム名のアルバムオブジェクトを返す。
 */
- (NSArray *)searchAlbumsByAlbumName:(NSString *)searchTerm {

  return [self searchAlbumsOrPlaylists:searchTerm
	       mediaGroupingType:MPMediaGroupingAlbum
	       predicateProperty:MPMediaItemPropertyAlbumTitle];
}

- (void)handle_NowPlayingItemChanged:(id)notification {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  NSString *nowPlayingTitle = 
    [currentItem valueForProperty: MPMediaItemPropertyTitle];
  NSLog(@"title: %@", nowPlayingTitle);
}

/**
 * @brief 与えられた配列から重複を取り除いた配列を返す。
 */
-(NSArray *)uniqArray:(NSArray *)origArray {

  NSSet *uniqElementsSet = [NSSet setWithArray:origArray];
  return [uniqElementsSet allObjects];
}

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
  NSLog(@"Stating Launching Now Playing Friends!!");
  testFlag = 0;
  [FBProfilePictureView class]; /* for Facebook Profile Picture View */

  TwitterClient *client = [[TwitterClient alloc] init];
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  NSMutableArray *newProfileImagesIndex = [[NSMutableArray alloc] init];
  isBackGround = NO;

  self.profileImages = newProfileImages;
  [newProfileImages release];

  self.profileImagesIndex = newProfileImagesIndex;
  [newProfileImagesIndex release];

  [self createDirectory:kProfileImageDirectory];
  [self createDirectory:kYouTubeThumbnailDirectory];  
  [self setupMusicPlayer];

  [UIApplication sharedApplication].statusBarStyle = 
    UIStatusBarStyleBlackOpaque;
  
  self.tabBarController = [[UITabBarController alloc] init];

  NSMutableArray *controllers = [[NSMutableArray alloc] init];
  UIViewController *viewController;
  UINavigationController *navController;
  NSString *username = [client username];

  /* Music Player */
  viewController = [[MusicPlayerViewController alloc] 
		     initWithNibName:@"MusicPlayerViewController" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Player" imageName:@"65-note.png"];

  self.musicPlayerViewController = (MusicPlayerViewController *)viewController;
  [controllers addObject:navController];
  [viewController release];

  /* Song */
  viewController = [[SongFriendsViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Song"  imageName:@"120-headphones.png"];

  [controllers addObject:navController];
  [viewController release];

  /* Artist */
  viewController = [[ArtistFriendsViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Artist"  imageName:@"112-group.png"];

  [controllers addObject:navController];
  [viewController release];

  /* MentionsTimeline */
  viewController = [[MentionsTimelineViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers"
		     bundle:nil];
  
  navController = [self navigationWithViewController:viewController
			title:@"Mentions"  
			imageName:@"atMark.png"];
  
  [controllers addObject:navController];

  [viewController /* 自分宛の@があったらタブに赤いバッジを表示するルーチン */
    performSelectorInBackground:@selector(updateNewItemCountToBadge)
    withObject:nil];
  [viewController release];
  
  /* Homeimeline */
  viewController = [[HomeTimelineViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers"
		     bundle:nil];
  
  navController = [self navigationWithViewController:viewController
			title:@"Home"  
			imageName:@"53-house.png"];
  
  [controllers addObject:navController];
  [viewController release];
  
  /* SelfTimeline */
  viewController = [[UserTimelineViewController alloc] 
		     initWithUserName:username];
  
  navController = [self navigationWithViewController:viewController
			title:@"Sent Tweet"  
			imageName:@"23-bird.png"];
    
  [controllers addObject:navController];
  [viewController release];

  /* Now */
  viewController = [[NowPlayingViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Now Playing"  imageName:@"09-chat2.png"];

  [controllers addObject:navController];
  [viewController release];

  /* UserAuth */
  viewController = [[UserAuthenticationViewController alloc] 
		     initWithNibName:@"UserAuthenticationViewController" 
		     bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Twutter Authentication"  
			imageName:@"30-key.png"];

  [controllers addObject:navController];
  [viewController release];

  /* Facebook UserAuth */
  viewController = [[FBAuthViewController alloc] 
		     initWithNibName:@"FBAuthViewController" 
		     bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Facebook Authentication"  
			imageName:@"30-key.png"];

  [controllers addObject:navController];
  [viewController release];


  /* SettingViewController */
  viewController = [[SettingViewController alloc] 
		     initWithNibName:@"SettingViewController" 
		     bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Settings"  
			imageName:@"20-gear2.png"];

  [controllers addObject:navController];
  [viewController release];


  /* create tabBar */
  [tabBarController setViewControllers:controllers];

  if ([client oAuthTokenExist]) {
    [client saveFriends];
  }

  [controllers release];
  [client release];
  [window makeKeyAndVisible];
  [window addSubview:tabBarController.view];

  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}

/**
 * @brief アプリがバックグラウンドに移行する際に呼ばれる。
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"application goto background.");
  [self cleanupProfileImageFileCache];

  UIApplication *app = [UIApplication sharedApplication];
  [app beginBackgroundTaskWithExpirationHandler:^{
      [app endBackgroundTask:bgTask];
      bgTask = UIBackgroundTaskInvalid;
    }];

  isBackGround = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"application will goto foreground.");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"application goto foreground.");

  isBackGround = NO;
  [musicPlayerViewController playBackStateDidChanged];
  [musicPlayerViewController setViewTitleAndMusicArtwork];
}

/**
   applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
*/
- (void)applicationWillTerminate:(UIApplication *)application {

  NSError *error = nil;
  if (managedObjectContext_ != nil) {
    if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    } 
  }
}

#pragma mark -
#pragma Facebook Methods

- (BOOL)loggedinToFacebook {
  return ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] != NSNotFound);
}

#pragma mark -
#pragma iPod Information Methods

- (BOOL)hasYouTubeLink {

  NSString *template = self.template_preference;
  return ([template rangeOfString:@"[yt]"].location != NSNotFound);
}

- (NSString *)tweetString {

  NSString *template = self.template_preference;
  NSString *tweet;

  tweet = [template stringByReplacingOccurrencesOfString:@"[st]"
		    withString:[self nowPlayingTitle]];

  tweet = [tweet stringByReplacingOccurrencesOfString:@"[al]"
		    withString:[self nowPlayingAlbumTitle]];

  tweet = [tweet stringByReplacingOccurrencesOfString:@"[ar]"
		 withString:[self nowPlayingArtistName]];

  return tweet;
}

- (NSString *)nowPlayingTitle {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  NSLog(@"currentItem:%@", currentItem);

  if (currentItem == nil) {
    return @"";
  }

  return [currentItem valueForProperty:MPMediaItemPropertyTitle];
}

- (NSString *)nowPlayingAlbumTitle {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil) {
    return @"";
  }

  return [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
}

- (NSString *)nowPlayingArtistName {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil) {
    return @"";
  }

  return [currentItem valueForProperty:MPMediaItemPropertyArtist];
}

- (UIImage *)currentMusicArtWorkWithWidth:(NSInteger)width
				   height:(NSInteger)height
			       useDefault:(BOOL)useDefault {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
  UIImage *orgImage = nil;     //   original size Image
  UIImage *artworkImage = nil; //   resized Image;

  if (currentItem != nil) {
    MPMediaItemArtwork *artwork = 
      [currentItem valueForProperty:MPMediaItemPropertyArtwork];

    if (artwork) {
      orgImage = [artwork imageWithSize:CGSizeMake(width, height)];
      artworkImage = [self streatchedImage:orgImage
				     width:width height:height];
    }
  }

  if (useDefault && artworkImage == nil) {
    orgImage = [UIImage imageNamed:kNoArtWorkImage];
    artworkImage = [self streatchedImage:orgImage
				   width:width height:height];
  }

  return artworkImage;
}

- (UIImage *)noArtworkImageWithWidth:(NSInteger)width
			      height:(NSInteger)height {

  UIImage *orgImage = [UIImage imageNamed:kNoArtWorkImage];
  UIImage *artworkImage = [orgImage stretchableImageWithLeftCapWidth:width 
				    topCapHeight:height];
  
  return artworkImage;
}

#pragma mark -
#pragma mark SettingBundle Methods

/**
 * @brief ユーザデフォルトオブジェクトを返します。
 */
- (NSUserDefaults *)userDefaults {

  return [NSUserDefaults standardUserDefaults];
}

/**
 * @brief ツイッターへのポストのテンプレート文字列を返す。
 */
- (NSString *)template_preference {

  NSString *template = [self.userDefaults valueForKey:@"template_preference"];

  if (template == nil) {
    template = kTweetTemplate;
  }

  return template;
}

- (void)setTemplate_preference:(NSString *)template {

  [self.userDefaults setObject:template forKey:@"template_preference"];
}

/**
 * @brief 同じ曲を聴いているツイッターユーザを取得するかどうかの設定を返す。
 */
- (BOOL)get_twitterusers_preference {

  NSNumber *autorefresh = 
    [self.userDefaults valueForKey:@"get_twitterusers_preference"];
  
  if (autorefresh == nil) {autorefresh = [NSNumber numberWithInteger:1];}
  
  BOOL flag;
  if ([autorefresh integerValue] == 1) {
    flag = YES;
  } else {
    flag = NO;
  }

  return flag;
}

- (void)setGet_twitterusers_preference:(BOOL)aFlag {

  NSNumber *getFlag = [NSNumber numberWithInteger:0];

  if (aFlag) {
    getFlag = [NSNumber numberWithInteger:1];
  }

  [self.userDefaults setObject:getFlag forKey:@"get_twitterusers_preference"];
}

/**
 * @brief 曲が変わった際に自動ツイートするかどうかの設定。
 */
- (BOOL)autotweet_preference {

  NSNumber *autorefresh = 
    [self.userDefaults valueForKey:@"autotweet_preference"];
  
  if (autorefresh == nil) {autorefresh = [NSNumber numberWithInteger:0];}
  
  BOOL flag;
  if ([autorefresh integerValue] == 1) {
    flag = YES;
  } else {
    flag = NO;
  }

  return flag;
}

- (void)setAutotweet_preference:(BOOL)flag {

  NSNumber *autorefresh = [NSNumber numberWithInteger:0];

  if (flag) {
    autorefresh = [NSNumber numberWithInteger:1];
  }

  [self.userDefaults setValue:autorefresh forKey:@"autotweet_preference"];
}

/**
 * @brief バックグラウンドで自動ツイートするかどうかの設定。
 */
- (BOOL)autotweet_when_background_preference {

  NSNumber *val = 
    [self.userDefaults valueForKey:@"autotweet_when_background_preference"];
  
  if (val == nil) {val = [NSNumber numberWithBool:NO];}
  return [val boolValue];
}

- (void)setAutotweet_when_background_preference:(BOOL)flag {

  NSNumber *val = [NSNumber numberWithBool:flag];
  [self.userDefaults setValue:val
		       forKey:@"autotweet_when_background_preference"];
}

/**
 * @brief 自動ツイート時にYouTubeリンクを付加するかどうかの設定。
 */
- (BOOL)use_youtube_preference {

  NSNumber *use_youtube_preference = 
    [self.userDefaults valueForKey:@"use_youtube_preference"];
  
  if (use_youtube_preference == nil) {
    use_youtube_preference = [NSNumber numberWithBool:YES];
  }
  
  return [use_youtube_preference boolValue];
}

- (void)setUse_youtube_preference:(BOOL)flag {

  NSNumber *use_youtube_preference = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:use_youtube_preference 
       forKey:@"use_youtube_preference"];
}

/**
 * @brief 手動ツイート時にYouTubeリンクを付加するかどうかの設定。
 */
- (BOOL)use_youtube_manual_preference {

  NSNumber *use_youtube_manual_preference = 
    [self.userDefaults valueForKey:@"use_youtube_manual_preference"];
  
  if (use_youtube_manual_preference == nil) {
    use_youtube_manual_preference = [NSNumber numberWithBool:NO];
  }
  
  return [use_youtube_manual_preference boolValue];
}

- (void)setUse_youtube_manual_preference:(BOOL)flag {

  NSNumber *use_youtube_manual_preference = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:use_youtube_manual_preference 
       forKey:@"use_youtube_manual_preference"];
}

- (BOOL)use_itunes_preference {

  NSNumber *use_itunes_preference = 
    [self.userDefaults valueForKey:@"use_itunes_preference"];
  
  if (use_itunes_preference == nil) {
    use_itunes_preference = [NSNumber numberWithBool:NO];
  }
  
  return [use_itunes_preference boolValue];
}

- (void)setUse_itunes_preference:(BOOL)flag {

  NSNumber *use_itunes_preference = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:use_itunes_preference 
       forKey:@"use_itunes_preference"];
}

- (BOOL)use_itunes_manual_preference {

  NSNumber *use_itunes_manual_preference = 
    [self.userDefaults valueForKey:@"use_itunes_manual_preference"];
  
  if (use_itunes_manual_preference == nil) {
    use_itunes_manual_preference = [NSNumber numberWithBool:NO];
  }
  
  return [use_itunes_manual_preference boolValue];
}

- (void)setUse_itunes_manual_preference:(BOOL)flag {

  NSNumber *use_itunes_manual_preference = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:use_itunes_manual_preference 
       forKey:@"use_itunes_manual_preference"];
}

- (NSInteger)select_youtube_link_preference {

  NSNumber *select_youtube_link_preference = 
    [self.userDefaults valueForKey:@"select_youtube_link_preference"];
  
  if (select_youtube_link_preference == nil) {
    select_youtube_link_preference = 
      [NSNumber numberWithInteger:kSelectYouTubeTypeConfirmation];
  }
  
  return [select_youtube_link_preference integerValue];
}

- (void)setSelect_youtube_link_preference:(NSInteger)selectType {

  NSNumber *select_youtube_link_preference = 
    [NSNumber numberWithInteger:selectType];

  [self.userDefaults setValue:select_youtube_link_preference
       forKey:@"select_youtube_link_preference"];
}

- (BOOL)auto_upload_picture_preference {

  NSNumber *value = 
    [self.userDefaults valueForKey:@"auto_upload_picture_preference"];
  
  if (value == nil) {
    value = [NSNumber numberWithInteger:NO];
  }
  
  return [value boolValue];
}

- (void)setAuto_upload_picture_preference:(BOOL)flag {

  NSNumber *value = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:value 
       forKey:@"auto_upload_picture_preference"];
}

- (BOOL)manual_upload_picture_preference {

  NSNumber *value = 
    [self.userDefaults valueForKey:@"manual_upload_picture_preference"];
  
  if (value == nil) {
    value = [NSNumber numberWithInteger:NO];
  }
  
  return [value boolValue];
}

- (void)setManual_upload_picture_preference:(BOOL)flag {

  NSNumber *value = [NSNumber numberWithBool:flag];

  [self.userDefaults setValue:value 
       forKey:@"manual_upload_picture_preference"];
}

/**
 * @brief 手動投稿時にFacebookに投稿するかどうかの設定。
 */
- (BOOL)fb_post_preference {

  NSNumber *fb_post_preference = 
    [self.userDefaults valueForKey:@"fb_post_preference"];
  
  if (fb_post_preference == nil) {
    fb_post_preference = [NSNumber numberWithBool:NO];
  }
  
  return [fb_post_preference boolValue];
}

- (void)setFb_post_preference:(BOOL)flag {

  NSNumber *fb_post_preference = [NSNumber numberWithBool:flag];
  [self.userDefaults setValue:fb_post_preference forKey:@"fb_post_preference"];
}

/**
 * @brief 手動投稿時にtwitterに投稿するかどうかの設定。
 */
- (BOOL)tw_post_preference {

  NSNumber *tw_post_preference = 
    [self.userDefaults valueForKey:@"tw_post_preference"];
  
  if (tw_post_preference == nil) {
    tw_post_preference = [NSNumber numberWithBool:YES];
  }
  
  return [tw_post_preference boolValue];
}

- (void)setTw_post_preference:(BOOL)flag {

  NSNumber *tw_post_preference = [NSNumber numberWithBool:flag];
  [self.userDefaults setValue:tw_post_preference forKey:@"tw_post_preference"];
}

#pragma mark -
#pragma mark Util Methods

- (void)sleep:(NSInteger)second {

  NSDate *date = [[NSDate alloc] init];
  NSDate *nextStartDate = [[NSDate alloc] initWithTimeInterval:second 
					  sinceDate:date];

  [NSThread sleepUntilDate: nextStartDate];
  [date release];
  [nextStartDate release];
}

/**
 * @brief 渡された文字列からタグを取り除いた文字列を返します。
 */
- (NSString *)stringByUntaggedString:(NSString *)str {

  NSString *sourceString = [self stringByUnescapedString:str];
  NSArray *separatedArray = [sourceString componentsSeparatedByString:@">"];

  if ([separatedArray count] < 2) {
    return str;
  }
  
  NSString *str2 = [separatedArray objectAtIndex:1];
  separatedArray = [str2 componentsSeparatedByString:@"<"];

  return [separatedArray objectAtIndex:0];
}

/**
 * @brief HTMLエスケープされた文字列を通常の文字列に戻した文字列を返す。
 */
- (NSString *)stringByUnescapedString:(NSString *)str {

  NSDictionary *escapeDictionary = 
    [[NSDictionary alloc] initWithObjectsAndKeys:
			    @"\"", @"&quot;",
			    @">", @"&gt;",
			    @"<", @"&lt;",
			    @"&", @"&amp;",
			  nil];

  NSString *newString = [[[NSString alloc] initWithString:str] autorelease];

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  for (NSString *key in [escapeDictionary keyEnumerator]) {
    NSString *value = [escapeDictionary objectForKey:key];
    newString = [newString stringByReplacingOccurrencesOfString:key
			   withString:value];
  }

  NSString *replaced = [[NSString alloc] initWithString:newString];
  [pool release];

  [escapeDictionary release];
  return [replaced autorelease];
}

/**
 * @brief 認証がすんでいるか確認して、すんでいない場合は認証画面を表示する。
 */
- (void)checkAuthenticateWithController:(id)viewController {

  TwitterClient *client = [[TwitterClient alloc] init];

  if ([client oAuthTokenExist] == NO) {
    UserAuthenticationViewController *authenticateViewController = 
      [[UserAuthenticationViewController alloc] 
	initWithNibName:@"UserAuthenticationViewController" bundle:nil];
    
    if ([viewController isKindOfClass:[MusicPlayerViewController class]]) {
      authenticateViewController.musicPlayerViewController = viewController;
    }

    [viewController presentModalViewController:authenticateViewController 
		    animated:YES];
    [authenticateViewController autorelease];
  }

  [client release];
}

- (NSString *)clientname:(NSDictionary *)data {

  NSString *clientString = [data objectForKey:@"source"];
  NSString *untaggedString = [self stringByUntaggedString:clientString];
  return untaggedString;
}

- (NSString *)username:(NSDictionary *)data {

  NSDictionary *user = [data objectForKey:@"user"];
  NSString *username = [data objectForKey:@"name"];

  if (user != nil && username == nil) {
    username = [user objectForKey:@"screen_name"];
  }

  if (user == nil) {
    username = [data objectForKey:@"from_user"];
  }
  
  return username;
}

/**
 * @brief Tweetデータからポストされた日付を返す。
 */
- (NSDate *)tweetDate:(NSDictionary *)data {

  NSString *dateString = [data objectForKey:@"created_at"];
  NSDate *date = [NSDate dateWithNaturalLanguageString:dateString];

  return date;
}

/**
 * @brief Tweetデータから現在までの経過時間を返す。
 */
- (NSInteger)secondSinceNow:(NSDictionary *)data {

  NSDate *tweetDate = [self tweetDate:data];
  NSInteger intervalSec = abs([tweetDate timeIntervalSinceNow]);

  return intervalSec;
}

/**
 * @brief 画面が半分だけめくり上がるアニメーション
 */
- (void)setHalfCurlAnimationWithController:(id)targetViewController
				 frontView:(UIView *)frontView
				    curlUp:(BOOL)curlUp {
  
  CATransition *animation = [CATransition animation];
  [animation setDelegate:targetViewController];
  [animation setDuration:0.35];
  [animation setTimingFunction:UIViewAnimationCurveEaseInOut];

  if (curlUp) {
    animation.type = @"pageCurl";
    animation.fillMode = kCAFillModeForwards;
    animation.endProgress = 0.76;
  } else {
    animation.type = @"pageUnCurl";
    animation.fillMode = kCAFillModeBackwards;
    animation.startProgress = 0.76;
  }

  [animation setRemovedOnCompletion:NO];

  UIView *aView = [targetViewController view];
  //[aView exchangeSubviewAtIndex:0 withSubviewAtIndex:2];
  [[aView layer] addAnimation:animation forKey:@"pageCurlAnimation"];

  /*
  if (!curlUp) {
    [[[targetViewController navigationController] navigationBar] 
      setUserInteractionEnabled:NO];
    [frontView setUserInteractioonEnabled:NO];
  } else {
    [[[targetViewController navigationController] navigationBar] 
      setUserInteractionEnabled:YES];
    [frontView setUserInteractioonEnabled:YES];
  }
  */
}

/**
 * @brief 画面切り替えのアニメーション処理
 */
- (void)setAnimationWithView:(id)targetView 
	       animationType:(UIViewAnimationTransition)transition {
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.75];

  [UIView setAnimationTransition:transition 
	  forView:targetView cache:YES];
}

/**
 * @brief ユーザのプロフィール画像を返します。
 *        キャッシュにあればそれを、なければリモートから取得して返します。
 */
- (UIImage *)profileImage:(NSDictionary *)data
		getRemote:(BOOL) getRemoteFlag {

  NSDictionary *user = [data objectForKey:@"user"];

  if (user == nil) { user = data; }

  // メモリから取得
  NSString *imageURLString = [user objectForKey:@"profile_image_url"];
  UIImage *newImage = [profileImages objectForKey:imageURLString];
  NSData *imageData = nil;

  if (newImage == nil) { // ファイルから取得
    imageData = [self profileImageDataWithURLString:imageURLString];
    
    if (imageData != nil) {
      newImage = [[[UIImage alloc] initWithData:imageData] autorelease];
    }
  }

  if (newImage == nil && getRemoteFlag) { //リモートから取得
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    imageData = [NSData dataWithContentsOfURL:imageURL];
    newImage = [[[UIImage alloc] initWithData:imageData] autorelease];
    
    [self saveProfileImageData:imageData urlString:imageURLString];
  }
  
  if (newImage != nil && [profileImages objectForKey:imageURLString] == nil) {
    if ([profileImagesIndex count] > kProfileImageMaxMemoryCacheCount) {
      NSString *key = [profileImagesIndex lastObject];
      [profileImages removeObjectForKey:key];
      [profileImagesIndex removeLastObject];
    }
    
    [profileImages setObject:newImage forKey:imageURLString];
    
    if ([profileImagesIndex count] == 0) {
      [profileImagesIndex addObject:imageURLString];
    } else {
      [profileImagesIndex insertObject:imageURLString atIndex:0];
    }
  }

  return newImage;
}

- (UIImage *)originalProfileImage:(NSDictionary *)data {

  NSDictionary *user = [data objectForKey:@"user"];

  if (user == nil) { user = data; }

  NSString *normalImageURLString = [user objectForKey:@"profile_image_url"];
  NSString *imageURLString = 
    [normalImageURLString stringByReplacingOccurrencesOfString:@"_normal.jpg"
			  withString:@".jpg"];

  NSURL *imageURL = [NSURL URLWithString:imageURLString];
  NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
  UIImage *newImage = [[[UIImage alloc] initWithData:imageData] autorelease];

  return newImage;
}
  
/**
 * @brief プロフィール画像をファイルに保存
 */
- (void)saveProfileImageData:(NSData *)imageData 
	       urlString:(NSString *) urlString {

  if (imageData == nil) { return; }

  NSString *path = [self profileImageFileName:urlString];
  [imageData writeToFile:path atomically:YES];
}

/**
 * @brief ファイルとして保存されているプロフィール画像を取得
 */
- (NSData *)profileImageDataWithURLString:(NSString *)urlString {

  NSString *path = [self profileImageFileName:urlString];
  NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];

  return [imageData autorelease];
}

- (NSString *)profileImageFileName:(NSString *)urlString {

  NSString *replaced = [urlString 
			 stringByReplacingOccurrencesOfString:@"http://"
			 withString:@""];

  replaced = [replaced 
	       stringByReplacingOccurrencesOfString:@"/"
	       withString:@"_"];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);
  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *dirname = 
    [documentsDirectory stringByAppendingPathComponent:kProfileImageDirectory];

  NSString *filename = [dirname stringByAppendingPathComponent:replaced];
  
  return filename;
}


/**
 * @brief YouTubeサムネイル画像をファイルに保存
 */
- (void)saveYoutubeThumbnailData:(NSData *)imageData 
		       urlString:(NSString *) urlString {

  if (imageData == nil) { return; }

  NSString *path = [self youtubeThumbnailFileName:urlString];
  [imageData writeToFile:path atomically:YES];
}

/**
 * @brief ファイルとして保存されているYouTubeサムネイル画像を取得
 */
- (NSData *)youtubeThumbnailDataWithURLString:(NSString *)urlString {

  NSString *path = [self youtubeThumbnailFileName:urlString];
  NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];

  return [imageData autorelease];
}

- (NSString *)youtubeThumbnailFileName:(NSString *)urlString {

  NSString *replaced = [urlString 
			 stringByReplacingOccurrencesOfString:@"http://"
			 withString:@""];

  replaced = [replaced 
	       stringByReplacingOccurrencesOfString:@"/"
	       withString:@"_"];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);
  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *dirname = 
    [documentsDirectory stringByAppendingPathComponent:kYouTubeThumbnailDirectory];

  NSString *filename = [dirname stringByAppendingPathComponent:replaced];
  
  return filename;
}

/**
 * @brief アプリケーション用のディレクトリを渡された名前でDeocuments以下に作る。
 */
- (NSString *)createDirectory:(NSString *)dirname {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *dirpath = 
    [documentsDirectory stringByAppendingPathComponent:dirname];

  if (![[NSFileManager defaultManager] fileExistsAtPath:dirpath]) {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dirpath
				    withIntermediateDirectories:YES
				    attributes:nil
				    error:&error];
  }

  return dirpath;
}

- (void)cleanupProfileImageFileCache {

  NSString *dirpath = [self createDirectory:kProfileImageDirectory];
  NSError *error = nil;
  NSArray *filesArray = [[NSFileManager defaultManager] 
			  subpathsOfDirectoryAtPath:dirpath error:&error];
  NSInteger filecount = [filesArray count];

  if (filecount > kProfileImageMaxFileCacheCount) {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager]
				       enumeratorAtPath:dirpath];

    NSString *filename = nil;
    NSString *filepath = nil;
    NSError *error = nil;

    while (filename = [dirEnum nextObject]) {
      filepath = [dirpath stringByAppendingPathComponent:filename];
      [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error];
      NSLog(@"deleted filename: %@", filepath);
    }
  }
}

- (UIBarButtonItem *)listButton:(SEL)selector
			 target:(id)target {

  UIImage *image = [UIImage imageNamed:@"list-white.png"];
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithImage:image
			     style:UIBarButtonItemStyleBordered
			     target:target
			     action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)editButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
      target:target
      action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)cancelButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
      target:target
      action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)playerButton:(SEL)selector
			 target:(id)target {

  float size = 25.0f;

  UIImage *artworkImage = 
    [self currentMusicArtWorkWithWidth:size height:size useDefault:NO];

  UIImage *resized = [self resizedImageWithImage:artworkImage
			   width:size height:size];

  if (artworkImage == nil) {
    artworkImage = [UIImage imageNamed:@"no_artwork.png"];
  }

  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithImage:resized
			     style:UIBarButtonItemStyleBordered
			     target:target
			     action:selector];

  return [button autorelease];
}

- (UIBarButtonItem *)refreshButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
      target:target
      action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)pauseButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemPause
      target:target
      action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)stopButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemStop
      target:target
      action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)completeButton:(SEL)selector
			     target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] 
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target: target
      action: selector];

  return [button autorelease];
}

- (UIBarButtonItem *)sendButton:(SEL)selector
			 target:(id)target {

  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithTitle:@"Send"
			     style:UIBarButtonItemStyleDone
			     target:target
			     action:selector];

  return [button autorelease];
}

- (UIImage *)resizedImageWithImage:(UIImage *)orgImage
			     width:(float)width height:(float)height {

  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
  [orgImage drawInRect:CGRectMake(0, 0, width, height)];
  UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return resized;
}

/**
 * @brief 渡されたイメージを縦横比を保ったまま、width, heigth,値の大きい方にあわせてリサイズ
 *        した画像を返します。
 */
- (UIImage *)streatchedImage:(UIImage *)orgImage
		       width:(NSInteger)width height:(NSInteger)height {

  CGFloat ratio = 0.0f;

  if (width > height) {
    ratio = (CGFloat)width / orgImage.size.width;
  } else {
    ratio = (CGFloat)height / orgImage.size.height;
  }

  UIImage *newImage = [self resizedImageWithImage:orgImage
			    width:(ratio * orgImage.size.width) 
			    height:(ratio * orgImage.size.height)];
  NSLog(@"newImage: %@", newImage);
  return newImage;
}

/**
 * @brief 渡されたイメージを渡されたボタンに縦横比を保ったままリサイズしてセットします。
 */
- (void)setResizedImage:(UIImage *)image 
	       toButton:(UIButton *)imageButton {

  CGRect bounds = [imageButton 
		    contentRectForBounds:imageButton.bounds];

  double wide = bounds.size.height * 0.95;	
  CGSize size = image.size;
  CGFloat ratio = 0;

  if (size.width > size.height) { //	横長なので、横幅で比率計算。
    ratio = wide / size.width;
  } else {			  //	縦長。
    ratio = wide / size.height;
  }

  UIImage *newImage = [self resizedImageWithImage:image 
			    width:(ratio * size.width) 
			    height:(ratio * size.height)];

  //	スケーリングされたUIImageを設定。
  [imageButton setImage:newImage forState:UIControlStateNormal];
	
  //	説明文は消す。
  [imageButton setTitle:nil forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
  if (managedObjectContext_ != nil) {
    return managedObjectContext_;
  }
  
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if (coordinator != nil) {
    managedObjectContext_ = [[NSManagedObjectContext alloc] init];
    [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
  }
  return managedObjectContext_;
}


/**
   Returns the managed object model for the application.
   If the model doesn't already exist, it is created from the application's model.
*/
- (NSManagedObjectModel *)managedObjectModel {
  
  if (managedObjectModel_ != nil) {
    return managedObjectModel_;
  }
  NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"NowPlayingFriends" ofType:@"momd"];
  NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
  managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
  return managedObjectModel_;
}


/**
   Returns the persistent store coordinator for the application.
   If the coordinator doesn't already exist, it is created and the application's store added to it.
*/
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  
  if (persistentStoreCoordinator_ != nil) {
    return persistentStoreCoordinator_;
  }
  
  NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"NowPlayingFriends.sqlite"]];
  
  NSError *error = nil;
  persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
  }    
  
  return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {

  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
					      NSUserDomainMask, YES) 
					     lastObject];
}

@end


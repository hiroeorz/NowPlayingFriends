//
//  NowPlayingFriendsAppDelegate.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "NowPlayingFriendsAppDelegate.h"
#import "NowPlayingViewController.h"
#import "SongFriendsViewController.h"
#import "ArtistFriendsViewController.h"
#import "MusicPlayerViewController.h"

@implementation NowPlayingFriendsAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize profileImages;
@synthesize musicPlayer;

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
  [persistentStoreCoordinator_ release];
  
  [tabBarController release];
  [profileImages release];

  [window release];
  [super dealloc];
}

#pragma mark -
#pragma mark Application lifecycle

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

  /*
  [notificationCenter 
    addObserver: object
    selector: @selector (handle_NowPlayingItemChanged:)
    name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
    object: musicPlayer];
  */

  [musicPlayer beginGeneratingPlaybackNotifications];
}

- (void)setupMusicPlayer {

  [self setMusicPlayer:[MPMusicPlayerController iPodMusicPlayer]];
  [self addMusicPlayerNotification:self];

  if ([musicPlayer nowPlayingItem]) {
    
  }
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

  return albums;
}

- (void)handle_NowPlayingItemChanged:(id)notification {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  NSString *nowPlayingTitle = 
    [currentItem valueForProperty: MPMediaItemPropertyTitle];
  NSLog(@"title: %@", nowPlayingTitle);
}

- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
  
  testFlag = 0;

  [self setupMusicPlayer];

  [UIApplication sharedApplication].statusBarStyle = 
    UIStatusBarStyleBlackOpaque;
  
  self.tabBarController = [[UITabBarController alloc] init];

  NSMutableArray *controllers = [[NSMutableArray alloc] init];
  UIViewController *viewController;
  UINavigationController *navController;

  /* Music Player */
  viewController = [[MusicPlayerViewController alloc] 
		     initWithNibName:@"MusicPlayerViewController" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"再生" imageName:@"65-note.png"];

  [controllers addObject:navController];
  [viewController release];

  /* Song */
  viewController = [[SongFriendsViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"曲名"  imageName:@"120-headphones.png"];

  [controllers addObject:navController];
  [viewController release];

  /* Artist */
  viewController = [[ArtistFriendsViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"アーティスト"  imageName:@"112-group.png"];

  [controllers addObject:navController];
  [viewController release];

  /* Now */
  viewController = [[NowPlayingViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Now Playing"  imageName:@"09-chat2.png"];

  [controllers addObject:navController];
  [viewController release];

  [tabBarController setViewControllers:controllers];
  [controllers release];

  [window makeKeyAndVisible];
  [window addSubview:tabBarController.view];
  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
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
#pragma iPod Information Methods

- (NSString *)nowPlayingTitle {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
  return [currentItem valueForProperty:MPMediaItemPropertyTitle];
}

- (NSString *)nowPlayingAlbumTitle {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
  return [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle];
}

- (NSString *)nowPlayingArtistName {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
  return [currentItem valueForProperty:MPMediaItemPropertyArtist];
}

#pragma mark -
#pragma mark Util Methods

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
- (NSData *)profileImage:(NSDictionary *)data
	       getRemote:(BOOL) getRemoteFlag {

  NSDictionary *user = [data objectForKey:@"user"];

  if (user == nil) { user = data; }

  NSString *imageURLString = [user objectForKey:@"profile_image_url"];

  NSData *imageData = [profileImages objectForKey:imageURLString];

  if (imageData == nil && getRemoteFlag) {
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    imageData = [NSData dataWithContentsOfURL:imageURL];
    
    @synchronized(profileImages) {
      [profileImages setObject:imageData forKey:imageURLString];
    }
    
  }

  return imageData;
}

- (UIBarButtonItem *)listButton:(SEL)selector
			 target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithTitle:@"リスト"
			     style:UIBarButtonItemStyleBordered
			     target:target
			     action:selector];
  return [button autorelease];
}

- (UIBarButtonItem *)completeButton:(SEL)selector
			     target:(id)target {
  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithTitle:@"完了"
			     style:UIBarButtonItemStyleBordered
			     target: self
			     action: selector];

  return [button autorelease];
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


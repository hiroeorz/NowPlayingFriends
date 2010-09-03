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
#import "TwitterClient.h"
#import "UserAuthenticationViewController.h"
#import "UserTimelineViewController.h"
#import "MentionsTimelineViewController.h"
#import "HomeTimelineViewController.h"

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

- (void)setupMusicPlayer {

  [self setMusicPlayer:[MPMusicPlayerController iPodMusicPlayer]];
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

  TwitterClient *client = [[TwitterClient alloc] init];
  [self cleanupProfileImageFileCache];

  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

  [self createDirectory:kProfileImageDirectory];
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
			title:@"Player" imageName:@"65-note.png"];

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

  /* Now */
  viewController = [[NowPlayingViewController alloc] 
		     initWithNibName:@"NowPlayingViewControllers" bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Now Playing"  imageName:@"09-chat2.png"];

  [controllers addObject:navController];
  [viewController release];

  NSString *username = [client username];

  if (username != nil) {

    /* Homeimeline */
    viewController = [[HomeTimelineViewController alloc] 
		       initWithNibName:@"NowPlayingViewControllers"
		       bundle:nil];
    
    navController = [self navigationWithViewController:viewController
			  title:@"Home"  
			  imageName:@"30-key.png"];
    
    [controllers addObject:navController];
    [viewController release];
    
    /* MentionsTimeline */
    viewController = [[MentionsTimelineViewController alloc] 
		       initWithNibName:@"NowPlayingViewControllers"
		       bundle:nil];
    
    navController = [self navigationWithViewController:viewController
			  title:@"Mentions"  
			  imageName:@"30-key.png"];
    
    [controllers addObject:navController];
    [viewController release];
    
    /* SelfTimeline */
    viewController = [[UserTimelineViewController alloc] 
		       initWithUserName:username];
    
    navController = [self navigationWithViewController:viewController
			  title:@"tweet"  
			  imageName:@"30-key.png"];
    
    [controllers addObject:navController];
    [viewController release];
  }

  /* UserAuth */
  viewController = [[UserAuthenticationViewController alloc] 
		     initWithNibName:@"UserAuthenticationViewController" 
		     bundle:nil];

  navController = [self navigationWithViewController:viewController
			title:@"Authentication"  
			imageName:@"30-key.png"];

  [controllers addObject:navController];
  [viewController release];

  /* create tabBar */
  [tabBarController setViewControllers:controllers];
  [controllers release];
  [client release];

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

- (NSString *)tweetString {

  NSString *template = kTweetTemplate;
  NSString *tweet;

  tweet = [template stringByReplacingOccurrencesOfString:@"[st]"
		    withString:[self nowPlayingTitle]];

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
  UIImage *artworkImage = nil; // = noArtworkImage;

  if (currentItem != nil) {
    MPMediaItemArtwork *artwork = 
      [currentItem valueForProperty:MPMediaItemPropertyArtwork];

    if (artwork) {
      artworkImage = 
	[artwork imageWithSize:CGSizeMake(width, height)];
    }
  }

  if (useDefault && artworkImage == nil) {
    UIImage *orgImage = [UIImage imageNamed:@"no_artwork_image.jpg"];
    artworkImage = [orgImage stretchableImageWithLeftCapWidth:width 
			     topCapHeight:height];
  }

  return artworkImage;
}

#pragma mark -
#pragma mark Util Methods

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

  NSMutableString *newString = [[NSMutableString alloc] initWithString:str];

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
    
    [viewController presentModalViewController:authenticateViewController 
		    animated:YES];
  }

  [client release];
}

- (NSDictionary *)clientname:(NSDictionary *)data {

  NSString *clientString = [data objectForKey:@"source"];
  NSString *untaggedString = [self stringByUntaggedString:clientString];
  return untaggedString;
}

- (NSString *)username:(NSDictionary *)data {

  NSLog(@"data: %@", data);
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
    animation.endProgress = 0.70;
  } else {
    animation.type = @"pageUnCurl";
    animation.fillMode = kCAFillModeBackwards;
    animation.startProgress = 0.70;
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

  NSString *imageURLString = [user objectForKey:@"profile_image_url"];
  UIImage *newImage = [profileImages objectForKey:imageURLString];
  NSData *imageData = nil;

  if (newImage != nil) {
    NSLog(@"get from memory: %@", newImage);
  }

  if (newImage == nil) {
    imageData = [self profileImageDataWithURLString:imageURLString];
    
    if (imageData != nil) {
      newImage = [[UIImage alloc] initWithData:imageData];
      NSLog(@"get from file: %@", newImage);
    }
  }

  if (newImage == nil && getRemoteFlag) {
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    imageData = [NSData dataWithContentsOfURL:imageURL];
    newImage = [[UIImage alloc] initWithData:imageData];
    
    [self saveProfileImageData:imageData urlString:imageURLString];

    @synchronized(profileImages) {
      if (newImage != nil) {
	NSLog(@"get from remote: %@", newImage);
	[profileImages setObject:newImage forKey:imageURLString];
      }    
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
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];

  return newImage;
}
  
- (void)saveProfileImageData:(NSData *)imageData 
	       urlString:(NSString *) urlString {

  if (imageData == nil) { return; }

  NSString *path = [self profileImageFileName:urlString];
  [imageData writeToFile:path atomically:YES];
}

- (NSData *)profileImageDataWithURLString:(NSString *)urlString {

  NSString *path = [self profileImageFileName:urlString];
  NSData *imageData = [[NSData alloc] initWithContentsOfFile:path];

  return imageData;
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
 * @brief アプリケーション用のディレクトリを渡された名前でDeocuments以下に作る。
 */
- (NSString *)createDirectory:(NSString *)dirname {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *dirpath = 
    [documentsDirectory stringByAppendingPathComponent:dirname];

  if (![[NSFileManager defaultManager] fileExistsAtPath:dirpath]) {
    [[NSFileManager defaultManager] 
      createDirectoryAtPath:dirpath attributes:nil];
  }

  return dirpath;
}

- (void)cleanupProfileImageFileCache {

  NSString *dirpath = [self createDirectory:kProfileImageDirectory]; 
  NSArray *filesArray = [[NSFileManager defaultManager] 
			  directoryContentsAtPath:dirpath];
  NSInteger filecount = [filesArray count];

  if (filecount > kProfileImageMaxFileCacheCount) {
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager]
				       enumeratorAtPath:dirpath];

    NSString *filename;
    NSString *filepath;

    while (filename = [dirEnum nextObject]) {
      filepath = [dirpath stringByAppendingPathComponent:filename];
      [[NSFileManager defaultManager] removeFileAtPath:filepath handler:self];
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

  UIImage *artworkImage = 
    [self currentMusicArtWorkWithWidth:20 height:20 useDefault:NO];

  if (artworkImage == nil) {
    artworkImage = [UIImage imageNamed:@"no_artwork.png"];
  }

  UIBarButtonItem *button = 
    [[UIBarButtonItem alloc] initWithImage:artworkImage
			     style:UIBarButtonItemStylePlain
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

  CGRect rect = CGRectMake(0.0, 0.0, 
			   ratio * size.width, ratio * size.height);

  //	計算した描画領域を指定して描画準備。
  UIGraphicsBeginImageContext(rect.size);	

  //	UIGraphicsGetImageFromCurrentImageContextが呼ばれるまで
  //	描画はすべて新しい描画領域が対象となる。
  [image drawInRect:rect];	//	イメージ描画。
	
  //	新しい描画領域からUIImageを作成。
  image = UIGraphicsGetImageFromCurrentImageContext();	
  UIGraphicsEndImageContext();			//	解除。
	
  //	スケーリングされたUIImageを設定。
  [imageButton setImage:image forState:UIControlStateNormal];
	
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


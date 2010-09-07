//
//  NowPlayingFriendsAppDelegate.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#define kTweetTemplate @"♪ Now Playing \"[st]\" by \"[ar]\" ♬ #nowplaying"
#define kMaxTweetLength 140
#define kProfileImageDirectory @"profileImages"
#define kProfileImageMaxFileCacheCount 512
#define kProfileImageMaxMemoryCacheCount 30
#define KNowPlayingTags @"@youtube OR #Playing OR #nowplaying OR #listening OR #nowlistening OR #playing OR #twitmusic";


@interface NowPlayingFriendsAppDelegate : NSObject <UIApplicationDelegate> {
  
  UIWindow *window;
  
@private
  NSManagedObjectContext *managedObjectContext_;
  NSManagedObjectModel *managedObjectModel_;
  NSPersistentStoreCoordinator *persistentStoreCoordinator_;
  UITabBarController *tabBarController;
  
  NSMutableDictionary *profileImages;
  MPMusicPlayerController *musicPlayer;
  
  NSInteger testFlag;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *profileImages;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

- (NSString *)applicationDocumentsDirectory;
- (UINavigationController *)navigationWithViewController:(id)viewController
						   title:(NSString *)title
					       imageName:(NSString *)imageName;

- (void)addMusicPlayerNotification:(id)object;
- (void)removeMusicPlayerNotification:(id)object;
- (void)setupMusicPlayer;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (NSString *)nowPlayingTitle;
- (NSString *)nowPlayingAlbumTitle;
- (NSString *)nowPlayingArtistName;
- (UIImage *)currentMusicArtWorkWithWidth:(NSInteger)width
				   height:(NSInteger)height
			       useDefault:(BOOL)useDefault;
- (void)setupMusicPlayer;
- (NSString *)nowPlayingTagsString;
- (NSArray *)albums;
- (NSArray *)playLists;
- (NSString *)tweetString;

- (void)setHalfCurlAnimationWithController:(id)targetViewController
				 frontView:(UIView *)frontView
				    curlUp:(BOOL)curlUp;
- (void)setAnimationWithView:(id)targetView 
	       animationType:(UIViewAnimationTransition)transition;

- (NSString *)stringByUntaggedString:(NSString *)str;
- (NSString *)stringByUnescapedString:(NSString *)str;
- (void)checkAuthenticateWithController:(id)viewController;

- (NSString *)clientname:(NSDictionary *)data;
- (NSString *)username:(NSDictionary *)data;
- (NSDate *)tweetDate:(NSDictionary *)data;
- (NSInteger)secondSinceNow:(NSDictionary *)data;


- (UIImage *)profileImage:(NSDictionary *)data 
		getRemote:(BOOL) getRemoteFlag;
- (void)clearProfileImageCache;

- (UIImage *)originalProfileImage:(NSDictionary *)data;
- (NSString *)profileImageFileName:(NSString *)urlString;
- (void)saveProfileImageData:(NSData *)imageData
		   urlString:(NSString *) urlString;
- (NSData *)profileImageDataWithURLString:(NSString *)urlString;
- (NSString *)createDirectory:(NSString *)dirname;
- (void)cleanupProfileImageFileCache;

- (void)setResizedImage:(UIImage *)image 
	       toButton:(UIButton *)imageButton;

- (UIBarButtonItem *)listButton:(SEL)selector
			 target:(id)target;
- (UIBarButtonItem *)editButton:(SEL)selector
			 target:(id)target;
- (UIBarButtonItem *)cancelButton:(SEL)selector
			   target:(id)target;
- (UIBarButtonItem *)playerButton:(SEL)selector
			   target:(id)target;
- (UIBarButtonItem *)pauseButton:(SEL)selector
			  target:(id)target;
- (UIBarButtonItem *)refreshButton:(SEL)selector
			    target:(id)target;
- (UIBarButtonItem *)stopButton:(SEL)selector
			 target:(id)target;
- (UIBarButtonItem *)completeButton:(SEL)selector
			     target:(id)target;

@end


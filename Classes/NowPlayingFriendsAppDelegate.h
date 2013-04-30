//
//  NowPlayingFriendsAppDelegate.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

#define kTweetTemplate @"♪ #NowPlaying \"[st]\" by \"[ar]\" on album \"[al]\" ♬"

#define kMaxTweetLength 140
#define kProfileImageDirectory @"profileImages"
#define kYouTubeThumbnailDirectory @"youtubeThumbnails"
#define kProfileImageMaxFileCacheCount 1024
#define kProfileImageMaxMemoryCacheCount 10
#define KNowPlayingTags @"nowplaying OR nowlistening OR twitmusic OR BGM";
#define kNoArtWorkImage @"no_artwork_image.png"

#define kSelectYouTubeTypeTopOfSerach 0
#define kSelectYouTubeTypeSelectFromList 1
#define kSelectYouTubeTypeConfirmation 2


@class MusicPlayerViewController;


@interface NowPlayingFriendsAppDelegate : NSObject <UIApplicationDelegate> {
  
  UIWindow *window;
  
@private
  NSManagedObjectContext *managedObjectContext_;
  NSManagedObjectModel *managedObjectModel_;
  NSPersistentStoreCoordinator *persistentStoreCoordinator_;
  UITabBarController *tabBarController;
  NSMutableDictionary *profileImages;
  NSMutableArray *profileImagesIndex;
  MPMusicPlayerController *musicPlayer;
  MusicPlayerViewController *musicPlayerViewController;
  BOOL isBackGround;
  NSInteger testFlag;
  UIBackgroundTaskIdentifier bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *profileImages;
@property (nonatomic, retain) NSMutableArray *profileImagesIndex;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MusicPlayerViewController *musicPlayerViewController;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic) BOOL isBackGround;
@property (nonatomic, readonly) BOOL isForeGround;

@property (nonatomic, retain) NSString *template_preference;
@property (nonatomic) BOOL get_twitterusers_preference;
@property (nonatomic) BOOL autotweet_preference;
@property (nonatomic) BOOL use_youtube_preference;
@property (nonatomic) BOOL use_youtube_manual_preference;
@property (nonatomic) BOOL use_itunes_preference;
@property (nonatomic) BOOL use_itunes_manual_preference;
@property (nonatomic) NSInteger select_youtube_link_preference;
@property (nonatomic) BOOL auto_upload_picture_preference;
@property (nonatomic) BOOL manual_upload_picture_preference;
@property (nonatomic) BOOL fb_post_preference;
@property (nonatomic) BOOL tw_post_preference;


- (NSString *)applicationDocumentsDirectory;
- (UINavigationController *)navigationWithViewController:(id)viewController
						   title:(NSString *)title
					       imageName:(NSString *)imageName;

- (BOOL)loggedinToFacebook;

- (void)addMusicPlayerNotification:(id)object;
- (void)removeMusicPlayerNotification:(id)object;
- (void)setupMusicPlayer;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (CGFloat)windowHeight;
- (CGFloat)windowWidth;
- (CGFloat)windowHeightFixVal;
- (void)fixHeightForAfteriPhone5View:(UIView *)aView;
- (void)fixPositionForAfteriPhone5View:(UIView *)aView;

- (NSString *)nowPlayingTitle;
- (NSString *)nowPlayingAlbumTitle;
- (NSString *)nowPlayingArtistName;
- (UIImage *)currentMusicArtWorkWithWidth:(NSInteger)width
				   height:(NSInteger)height
			       useDefault:(BOOL)useDefault;
- (UIImage *)noArtworkImageWithWidth:(NSInteger)width
			      height:(NSInteger)height;

- (void)setupMusicPlayer;
- (NSString *)nowPlayingTagsString;

- (NSArray *)albums;
- (NSArray *)playLists;

- (NSArray *)searchAlbums:(NSString *)searchTerm;
- (NSArray *)searchPlaylists:(NSString *)searchTerm;
- (NSArray *)searchPlaylistsByPlaylistName:(NSString *)searchTerm;
- (NSArray *)searchPlaylistsByArtistName:(NSString *)searchTerm;
- (NSArray *)searchAlbumsByArtistName:(NSString *)searchTerm;
- (NSArray *)searchAlbumsByAlbumName:(NSString *)searchTerm;

- (BOOL)hasYouTubeLink;
- (NSString *)tweetString;

- (void)setHalfCurlAnimationWithController:(id)targetViewController
				 frontView:(UIView *)frontView
				    curlUp:(BOOL)curlUp;
- (void)setAnimationWithView:(id)targetView 
	       animationType:(UIViewAnimationTransition)transition;

- (NSUserDefaults *)userDefaults;

- (void)sleep:(NSInteger)second;
- (NSString *)stringByUntaggedString:(NSString *)str;
- (NSString *)stringByUnescapedString:(NSString *)str;
- (void)checkAuthenticateWithController:(id)viewController;

- (NSString *)clientname:(NSDictionary *)data;
- (NSString *)username:(NSDictionary *)data;
- (NSDate *)tweetDate:(NSDictionary *)data;
- (NSInteger)secondSinceNow:(NSDictionary *)data;


- (UIImage *)profileImage:(NSDictionary *)data 
		getRemote:(BOOL) getRemoteFlag;

- (UIImage *)originalProfileImage:(NSDictionary *)data;
- (NSString *)profileImageFileName:(NSString *)urlString;
- (void)saveProfileImageData:(NSData *)imageData
		   urlString:(NSString *) urlString;
- (NSData *)profileImageDataWithURLString:(NSString *)urlString;
- (NSString *)createDirectory:(NSString *)dirname;
- (void)cleanupProfileImageFileCache;

- (void)saveYoutubeThumbnailData:(NSData *)imageData 
		       urlString:(NSString *) urlString;
- (NSData *)youtubeThumbnailDataWithURLString:(NSString *)urlString;
- (NSString *)youtubeThumbnailFileName:(NSString *)urlString;

- (UIImage *)resizedImageWithImage:(UIImage *)orgImage
			     width:(float)width height:(float)height;
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
- (UIBarButtonItem *)sendButton:(SEL)selector
			 target:(id)target;

-(NSArray *)uniqArray:(NSArray *)origArray;

@end


//
//  MusicPlayerViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "TwitterClient.h"


@class MusicPlayerNowPlayingAnimation;


#define kProfileImageButtonAlpha 0.55f
#define kProfileImageSize 64
#define kPlayListTableRowHeight 55
#define kModeSelectTableRowHeight 65

#define kListModeAlbum 0
#define kListModePlayList 1

#define kShuffleModeNone 0
#define kShuffleModeOne 1
#define kShuffleModeAll 2

#define kRepeatModeNone 0
#define kRepeatModeOne 1
#define kRepeatModeAll 2

#define kAutoTweetTimeLag 10
#define kMusicPlayerDefaultNowInterval 60 * 10
#define kNowButtonFrame (CGRectMake(39.0f, 44.5f, 23.5f, 18.5f))
#define kNowButtonInfoFrame (CGRectMake(265.0f, 8.0f, 23.5f, 18.5f))
#define kNowButtonAlpha 0.7f
#define kPlayButtonFrame (CGRectMake(185.0f, 23.5f, 70.0f, 70.0f))
#define kPlayButtonAlpha 0.7f
#define kRefreshButtonFrame (CGRectMake(220.0f, 12.0f, 100.0f, 50.0f))
#define kRefreshButtonAlpha 1.0f
#define kYouTubeButtonFrame (CGRectMake(25.0f, 62.0f, 155.0f, 30.0f))
#define kYouTubeButtonAlpha 1.0f

#define kAccelerationThreshold 1.6
#define kAccelerationUpdateInterval (1.0f / 10.0f)

@interface MusicPlayerViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UIAccelerometerDelegate,
 UISearchBarDelegate> {

  NSArray *timeline;

@private

  BOOL autoTweetMode;
  BOOL cancelFlag;
  BOOL sending;
  BOOL sent;
  BOOL updateAfterSafetyTime;
  BOOL updatingFlag;
  MPMusicPlayerController *musicPlayer;
  MusicPlayerNowPlayingAnimation *animationOperator;
  NSArray *albumLists;
  NSArray *beforeTimeline;
  NSArray *playLists;
  NSDictionary *youtubeSearchResultForAutoTweet;
  NSInteger listmode;
  NSInteger subControlTouchCount;
  NSMutableArray *addLinkArray;
  NSMutableArray *nowButtons;
  NSMutableArray *profileImageButtons;
  NSString *itemCollectionTitle;
  NSString *recentSongTitle;
  NSString *refreshProfileImagesMutex;
  TwitterClient *twitterClient;
  UIButton *button;
  UIButton *playButton;
  UIButton *subControlDisplayButton;
  UIButton *youTubeButton;
  UIImageView *albumImageView;
  UISearchBar *songSearchBar;
  UISegmentedControl *friendGetModeControl;
  UISegmentedControl *musicSegmentedControl;
  UISegmentedControl *refreshTypeSegmentedControl;
  UISegmentedControl *repeatModeControll;
  UISegmentedControl *shuffleModeControll;
  UISlider *volumeSlider;
  UISwitch *autoTweetSwitch;
  UITableView *listView;
  UIView *baseView;
  UIView *musicControllerView;
  UIView *settingView;
  UIView *songView;
  UIView *subControlView;
  UIViewController *songListController;
}

@property (nonatomic) BOOL autoTweetMode;
@property (nonatomic) BOOL sending;
@property (nonatomic) BOOL sent;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *subControlDisplayButton;
@property (nonatomic, retain) IBOutlet UIButton *youTubeButton;
@property (nonatomic, retain) IBOutlet UIImageView *albumImageView;
@property (nonatomic, retain) IBOutlet UISearchBar *songSearchBar;
@property (nonatomic, retain) IBOutlet UISegmentedControl *friendGetModeControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *musicSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *refreshTypeSegmentedControl;
@property (nonatomic, retain) IBOutlet UISegmentedControl *repeatModeControll;
@property (nonatomic, retain) IBOutlet UISegmentedControl *shuffleModeControll;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UISwitch *autoTweetSwitch;
@property (nonatomic, retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) IBOutlet UIView *musicControllerView;
@property (nonatomic, retain) IBOutlet UIView *settingView;
@property (nonatomic, retain) IBOutlet UIView *songView;
@property (nonatomic, retain) IBOutlet UIView *subControlView;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MusicPlayerNowPlayingAnimation *animationOperator;
@property (nonatomic, retain) NSArray *albumLists;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, retain) NSArray *playLists;
@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSMutableArray *addLinkArray;
@property (nonatomic, retain) NSMutableArray *nowButtons;
@property (nonatomic, retain) NSMutableArray *profileImageButtons;
@property (nonatomic, retain) NSString *itemCollectionTitle;
@property (nonatomic, retain) NSString *recentSongTitle;
@property (nonatomic, retain) NSString *refreshProfileImagesMutex;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) UIView *baseView;
@property (nonatomic, retain) UIViewController *songListController;


- (IBAction)touchSubControl:(id)sender;
- (IBAction)touchSubControllerDisplayButton:(id)sender;
- (void)displaySubview;
- (void)setViewTitleAndMusicArtwork;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
@end

@interface MusicPlayerViewController (Notification)
- (void)playBackStateDidChanged;
- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;
@end

@interface MusicPlayerViewController (Settings)
- (IBAction)changeAutoTweetMode:(id)sender;
- (IBAction)changeFriendGetMode:(id)sender;
- (IBAction)changeMusicSegmentedControl:(id)sender;
- (IBAction)changeRefreshType:(id)sender;
- (IBAction)changeRepeatMode:(id)sender;
- (IBAction)changeShuffleMode:(id)sender;
- (IBAction)changeVolume:(id)sender;
- (IBAction)closeSettingView:(id)sender;
- (IBAction)closeSettingView:(id)sender;
- (IBAction)openSettingView:(id)sender;
- (IBAction)openSettingView:(id)sender;
- (IBAction)skipToBeginningOrPreviousItem:(id)sender;
- (IBAction)skipToNextItem:(id)sender;
- (IBAction)skipToPreviousItem:(id)sender;
- (IBAction)togglePlayStop:(id)sender;
@end

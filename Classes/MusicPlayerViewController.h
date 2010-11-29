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

#import "NowPlayingFriendsAppDelegate.h"
#import "TwitterClient.h"

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
#define kNowButtonFrame (CGRectMake(35.0f, 40.0f, 30.0f, 25.0f))
#define kNowButtonInfoFrame (CGRectMake(260.0f, 3.0f, 30.0f, 25.0f))
#define kNowButtonAlpha 0.7f
#define kPlayButtonFrame (CGRectMake(185.0f, 23.5f, 70.0f, 70.0f))
#define kPlayButtonAlpha 0.7f
#define kRefreshButtonFrame (CGRectMake(220.0f, 12.0f, 100.0f, 50.0f))
#define kRefreshButtonAlpha 1.0f

#define kAccelerationThreshold 1.6
#define kAccelerationUpdateInterval (1.0f / 10.0f)

@interface MusicPlayerViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UIAccelerometerDelegate> {

  NSArray *timeline;

@private

  BOOL autoTweetMode;
  BOOL cancelFlag;
  BOOL sending;
  BOOL sent;
  BOOL updatingFlag;
  MPMusicPlayerController *musicPlayer;
  NSArray *albumLists;
  NSArray *beforeTimeline;
  NSArray *playLists;
  NSInteger listmode;
  NSInteger subControlTouchCount;
  NSMutableArray *nowButtons;
  NSMutableArray *profileImageButtons;
  NSString *refreshProfileImagesMutex;
  UIButton *button;
  UIButton *playButton;
  UIImageView *albumImageView;
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
  UIButton *subControlDisplayButton;
}

@property (nonatomic) BOOL autoTweetMode;
@property (nonatomic) BOOL sending;
@property (nonatomic) BOOL sent;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *subControlDisplayButton;
@property (nonatomic, retain) IBOutlet UIImageView *albumImageView;
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
@property (nonatomic, retain) NSArray *albumLists;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, retain) NSArray *playLists;
@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSMutableArray *nowButtons;
@property (nonatomic, retain) NSMutableArray *profileImageButtons;
@property (nonatomic, retain) NSString *refreshProfileImagesMutex;
@property (nonatomic, retain) UIView *baseView;
@property (nonatomic, retain) UIViewController *songListController;

- (IBAction)changeAutoTweetMode:(id)sender;
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
- (IBAction)touchSubControl:(id)sender;
- (IBAction)touchSubControllerDisplayButton:(id)sender;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;

@end

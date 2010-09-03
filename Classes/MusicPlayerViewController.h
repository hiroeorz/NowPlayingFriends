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

#define kProfileImageButtonAlpha 0.4f
#define kProfileImageSize 64
#define kPlayListTableRowHeight 55
#define kModeSelectTableRowHeight 65

#define kListModeAlbum 0
#define kListModePlayList 1

#define kRepeatModeNone 0
#define kRepeatModeOne 1
#define kRepeatModeAll 2

#define kAutoTweetTimeLag 10

@interface MusicPlayerViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  NSArray *timeline;

@private
  NSArray *beforeTimeline;
  UIImageView *albumImageView;
  UISlider *volumeSlider;
  UIButton *playButton;
  UIButton *button;
  NSMutableArray *profileImageButtons;
  MPMusicPlayerController *musicPlayer;
  UIView *songView;
  UITableView *listView;
  NSArray *playLists;
  NSArray *albumLists;
  NSInteger listmode;
  NSString *refreshProfileImagesMutex;
  UIViewController *songListController;
  UIView *settingView;

  UISegmentedControl *repeatModeControll;
  BOOL autoTweetMode;
  BOOL autoTweetModeDefault;
  UISwitch *autoTweetSwitch;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *albumImageView;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) NSMutableArray *profileImageButtons;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) IBOutlet UIView *songView;
@property (nonatomic, retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) IBOutlet UIView *settingView;
@property (nonatomic, retain) NSArray *playLists;
@property (nonatomic, retain) NSArray *albumLists;
@property (nonatomic, retain) NSString *refreshProfileImagesMutex;
@property (nonatomic, retain) UIViewController *songListController;
@property (nonatomic, retain) IBOutlet UISegmentedControl *repeatModeControll;
@property (nonatomic, retain) IBOutlet UISwitch *autoTweetSwitch;

- (void)setMusicArtwork;

- (void)refreshTimeline;
- (void)setFriendImageView;

- (IBAction)changeAutoTweetMode:(id)sender;
- (IBAction)changeVolume:(id)sender;
- (IBAction)togglePlayStop:(id)sender;
- (IBAction)skipToNextItem:(id)sender;
- (IBAction)skipToBeginningOrPreviousItem:(id)sender;
- (IBAction)skipToPreviousItem:(id)sender;
- (void)openUserInformationView:(id)sender;

- (IBAction)changeRepeatMode:(id)sender;
- (IBAction)openSettingView:(id)sender;
- (void)closeSettingView;
- (IBAction)closeSettingView:(id)sender;
- (void)openEditView;
- (void)changeToListview;
- (void)changeToSongview;

- (void)sendAutoTweetAfterTimeLag;
- (void)sendAutoTweet;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;


- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

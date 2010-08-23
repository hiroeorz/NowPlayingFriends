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

#define kProfileImageButtonAlpha 0.7f
#define kProfileImageSize 64
#define kPlayListTableRowHeight 55
#define kModeSelectTableRowHeight 65

#define kListModeAlbum 0
#define kListModePlayList 1


@interface MusicPlayerViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

@private
  NSArray *timeline;
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
@property (nonatomic, retain) NSArray *playLists;
@property (nonatomic, retain) NSArray *albumLists;
@property (nonatomic, retain) NSString *refreshProfileImagesMutex;

- (void)setMusicArtwork;

- (void)refreshTimeline;
- (void)setFriendImageView;

- (IBAction)changeVolume:(id)sender;
- (IBAction)togglePlayStop:(id)sender;
- (IBAction)skipToNextItem:(id)sender;
- (IBAction)skipToBeginningOrPreviousItem:(id)sender;
- (IBAction)skipToPreviousItem:(id)sender;

- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

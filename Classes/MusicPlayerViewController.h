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

#define kProfileImageButtonAlpha 0.5f
#define kProfileImageSize 64

@interface MusicPlayerViewController : UIViewController {
  NSArray *timeline;
  NSArray *beforeTimeline;
  BOOL activateFlag;
  UIImageView *albumImageView;
  UIButton *button;
  NSMutableArray *profileImageButtons;
  MPMusicPlayerController *musicPlayer;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *albumImageView;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) NSMutableArray *profileImageButtons;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

- (void)setMusicArtwork;

- (void)friendImageRefreshLoop;
- (void)refreshTimeline;
- (void)setFriendImageView;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

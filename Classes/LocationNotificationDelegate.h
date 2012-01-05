//
//  LocationNotificationDelegate.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 12/01/05.
//  Copyright (c) 2012年 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>

@class NowPlayingFriendsAppDelegate;

@interface LocationNotificationDelegate : NSObject <CLLocationManagerDelegate> {
@private
  CLLocationManager *locationManager;
  NSString *recentSongTitle;
  MPMusicPlayerController *musicPlayer;
}


@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic ,retain) NSString *recentSongTitle;

- (void)start;
- (void)stop;
- (void)handle_PlayBackStateDidChanged:(id)notification;

@end

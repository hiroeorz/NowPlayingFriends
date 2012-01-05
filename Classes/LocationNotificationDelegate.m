//
//  LocationNotificationDelegate.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 12/01/05.
//  Copyright (c) 2012年 hiroe_orz17. All rights reserved.
//

#import "LocationNotificationDelegate.h"

#import "NowPlayingFriendsAppDelegate.h"


@implementation LocationNotificationDelegate

@dynamic appDelegate;
@synthesize recentSongTitle;

- (void)dealloc {
  [locationManager release];
  [musicPlayer release];
  [recentSongTitle release];
  [super dealloc];
}

- (id)init {
  
  self = [super init];

  if (self != nil) {
    musicPlayer = [[MPMusicPlayerController iPodMusicPlayer] retain];
    locationManager = nil;

    if ([CLLocationManager locationServicesEnabled] == YES) {
      locationManager = [[CLLocationManager alloc] init];
      locationManager.delegate = self;
      //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
      locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
      locationManager.distanceFilter = kCLDistanceFilterNone;
    }
  }

  return self;
}

/**
 * @brief 位置情報の追跡を開始する。
 */
- (void)start {
  
  NSLog(@"location tracking START.");
  self.recentSongTitle = [self.appDelegate nowPlayingTitle];

  if ([CLLocationManager locationServicesEnabled] == YES) {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter 
						 defaultCenter];
    [notificationCenter 
      addObserver: self
	 selector: @selector (handle_PlayBackStateDidChanged:)
	     name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
	   object: musicPlayer];
    
    [locationManager startUpdatingLocation];
  }
}

/**
 * @brief 位置情報の追跡を停止する。
 */
- (void)stop {

  NSLog(@"location tracking STOP.");

  if ([CLLocationManager locationServicesEnabled] == YES) {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter 
						 defaultCenter];
    [notificationCenter 
      removeObserver: self
		name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
	      object: musicPlayer];

    [locationManager stopUpdatingLocation];
  }
}

/**
 * @brief iPodプレイヤーの状態が変化したら呼ばれる。
 *        再生中でなかったら位置情報の追跡をやめる。
 */
- (void)handle_PlayBackStateDidChanged:(id)notification {

  NSLog(@"Play State Changed!(in LocationManagerDelegate)");

  if ([musicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
    [self stop];
  }
}

#pragma mark -
#pragma Location Manager Delegate Methods

- (void) locationManager:(CLLocationManager *)manager 
     didUpdateToLocation:(CLLocation *)newLocation 
	    fromLocation:(CLLocation *)oldLocation {
  NSLog(@"NOTICE! LOCATION CHANGED!");

  NSString *nowTitle = [self.appDelegate nowPlayingTitle];

  if (![recentSongTitle isEqualToString:nowTitle]) {
    NSLog(@"music changed when background");
    self.recentSongTitle = nowTitle;
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"NOTICE! LOCATION DID FAIL!");
}

#pragma mark -
#pragma Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

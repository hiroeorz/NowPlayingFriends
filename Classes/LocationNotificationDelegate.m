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
  [recentSongTitle release];
  [super dealloc];
}

- (id)init {
  
  self = [super init];

  if (self != nil) {
    locationManager = nil;

    if ([CLLocationManager locationServicesEnabled] == YES || 
	locationManager.locationServicesEnabled == YES) {
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

- (void)start {

  self.recentSongTitle = [self.appDelegate nowPlayingTitle];

  if ([CLLocationManager locationServicesEnabled] == YES || 
      locationManager.locationServicesEnabled == YES) {
    [locationManager startUpdatingLocation];
  }
}

- (void)stop {

  if ([CLLocationManager locationServicesEnabled] == YES || 
      locationManager.locationServicesEnabled == YES) {
    [locationManager stopUpdatingLocation];
  }

}

- (void) locationManager:(CLLocationManager *)manager 
     didUpdateToLocation:(CLLocation *)newLocation 
	    fromLocation:(CLLocation *)oldLocation {
  NSLog(@"NOTICE! LOCATION CHANGED!");

  NSString *nowTitle = [self.appDelegate nowPlayingTitle];

  if (![recentSongTitle isEqualToString:nowTitle]) {
    NSLog(@"music changed when background");
  }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"NOTICE! LOCATION DID FAIL!");
}

- (void)locationManager:(CLLocationManager *)manager   
       didUpdateHeading:(CLHeading *)newHeading {  
  NSLog(@"NOTICE! LOCATION HEADING CHANGED!");
}

#pragma mark -
#pragma Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

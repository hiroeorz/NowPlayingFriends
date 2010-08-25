//
//  NowPlayingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingFriendsAppDelegate.h"

#define kTimelineTableRowHeight 90


@interface FriendsViewController : UITableViewController {

  NSArray *timeline;

@private
  NSArray *beforeTimeline;
  BOOL activateFlag;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;

- (void)refreshTimeline;
- (void)tableRefreshLoop;

- (NSString *)username:(NSDictionary *)data;
- (void)setProfileImageWithObjects:(NSDictionary *)objects;
- (void) cacheAllProfileImage;

- (void)openUserInformationView:(id)sender;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

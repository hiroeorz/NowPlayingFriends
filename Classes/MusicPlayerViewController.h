//
//  MusicPlayerViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingFriendsAppDelegate.h"

#define kProfileImageButtonAlpha 0.75f
#define kProfileImageSize 64

@interface MusicPlayerViewController : UIViewController {
  NSArray *timeline;
  BOOL activateFlag;
  UIImageView *albumImageView;
  UIButton *button;
  NSMutableArray *profileImageButtons;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *albumImageView;
@property (nonatomic, retain) IBOutlet UIButton *button;
@property (nonatomic, retain) NSMutableArray *profileImageButtons;

- (void)friendImageRefreshLoop;
- (void)refreshTimeline;
- (void)setFriendImageView;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

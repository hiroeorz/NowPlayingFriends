//
//  SettingSelectYouTubeLinkView.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/07.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingFriendsAppDelegate.h"


@interface SettingSelectYouTubeLinkView : UITableViewController {

  NSArray *titles;
  NSArray *values;
  NSIndexPath *lastIndexPath;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) NSArray *titles;
@property (nonatomic, retain) NSArray *values;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

@end

//
//  NowPlayingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTimelineTableRowHeight 90


@interface NowPlayingViewController : UITableViewController {
  NSArray *timeline;
  NSMutableDictionary *profileImages;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSMutableDictionary *profileImages;

- (void)refreshTimeline;
- (void)tableRefreshLoop;

- (NSString *)username:(NSDictionary *)data;
- (void)setProfileImageWithObjects:(NSDictionary *)objects;
- (UIImage *)profileImage:(NSDictionary *)data 
		getRemote:(BOOL) getRemoteFlag;
- (void) cacheAllProfileImage;

@end

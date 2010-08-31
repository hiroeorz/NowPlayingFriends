//
//  NowPlayingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingFriendsAppDelegate.h"

#define kTimelineTableRowHeight 76.0f
#define kDefaultBodyTextHeight 27.0f
#define kViewFrameHeight 66.0f
#define kTextFrameHeight 27.0f

@interface FriendsViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  NSArray *timeline;
  UITableView *friendsTableView;

@private
  NSArray *beforeTimeline;
  BOOL activateFlag;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *friendsTableView;

- (NSInteger)refreshTimeline;
- (NSInteger)createNewTimeline:(NSArray *)newTimeline;
- (void)tableRefreshLoop;

- (NSString *)username:(NSDictionary *)data;
- (void)setProfileImageWithObjects:(NSDictionary *)objects;
- (void) cacheAllProfileImage;

- (void)openUserInformationView:(id)sender;
- (CGFloat)lineHeightValue:(NSIndexPath *)indexPath;
- (CGFloat)lineOverFlowSize:(NSIndexPath *)indexPath;
- (NSInteger)newOffset:(NSInteger)addCount;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

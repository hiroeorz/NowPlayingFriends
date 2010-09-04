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
#define kTextFrameHeight 32.0f
#define kTimelineUpdateInterval 60 * 5
#define kMaxTableCellRow 100
#define kTableUpdateMaxScrollRow 80

@interface FriendsViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  NSArray *timeline;
  UITableView *friendsTableView;
  BOOL changed;

@private
  NSArray *beforeTimeline;
  BOOL activateFlag;
  NSInteger cellRow;
}

@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *friendsTableView;

- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (NSInteger)refreshTimeline;
- (NSInteger)createNewTimeline:(NSArray *)newTimeline;
- (void)tableRefreshLoop;
- (void)shurinkTimeline;

- (IBAction)refreshTableOnThread;
- (void)refreshTable;

- (NSString *)clientname:(NSDictionary *)data;
- (NSString *)username:(NSDictionary *)data;
- (void)setProfileImageWithObjects:(NSDictionary *)objects;
- (void) cacheAllProfileImage;

- (void)openUserInformationView:(id)sender;
- (CGFloat)lineHeightValue:(NSIndexPath *)indexPath;
- (CGFloat)lineOverFlowSize:(NSIndexPath *)indexPath;
- (NSInteger)newOffset:(NSInteger)addCount;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

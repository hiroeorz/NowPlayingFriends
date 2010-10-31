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
#define kViewFrameHeight 75.0f
#define kTextFrameHeight 32.0f
#define kTimelineUpdateInterval 3 * 60
#define kMaxTableCellRow 100
#define kTableUpdateMaxScrollRow 80

@interface FriendsViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  BOOL changed;
  BOOL firstFlag;
  NSArray *timeline;
  NSMutableArray *lineOverFlowQueue;
  NSString *myUserName;
  UIImage *noArtWorkMini;
  UITableView *friendsTableView;

@private
  BOOL activateFlag;
  NSArray *beforeTimeline;
  NSInteger cellRow;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain)  UIImage *noArtWorkMini;
@property (nonatomic, retain) IBOutlet UITableView *friendsTableView;
@property (nonatomic, retain) NSArray *beforeTimeline;
@property (nonatomic, retain) NSArray *timeline;
@property (nonatomic, retain) NSMutableArray *lineOverFlowQueue;
@property (nonatomic, retain) NSString *myUserName;


- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;

- (void)updateNewItemCountToBadge;
- (NSInteger)createNewTimeline:(NSArray *)newTimeline;
- (NSNumber *)lastTweetId;

@end

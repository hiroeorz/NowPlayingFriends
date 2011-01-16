//
//  TwitterFriendsListViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/15.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kRecentFriendsFileName @"recent_friends.plist"
#define kRecentFriendsGroupName @"recent"
#define kRecentFriendMaxCount 10

@class SendTweetViewController;
@class NowPlayingFriendsAppDelegate;


@interface TwitterFriendsListViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  NSArray *initials;
  NSMutableDictionary *friends;
  NSString *selectedName;
  SendTweetViewController *tweetViewController;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) NSString *selectedName;
@property (nonatomic, retain) NSArray *initials;
@property (nonatomic, retain) NSMutableDictionary *friends;
@property (nonatomic, retain) SendTweetViewController *tweetViewController;

@end

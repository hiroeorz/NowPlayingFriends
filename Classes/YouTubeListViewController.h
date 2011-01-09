//
//  YouTubeListViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kYouTubeSearchCount 7
#define kYouTubeThumbnailHeight 91


@class SendTweetViewController;
@class NowPlayingFriendsAppDelegate;
@class YoutubeTypeSelectViewController;


@interface YouTubeListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate> {

  NSArray *movies;
  SendTweetViewController *tweetViewController;
  UITableView *movieTableView;
  YoutubeTypeSelectViewController *typeSelectViewController;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *movieTableView;
@property (nonatomic, retain) NSArray *movies;
@property (nonatomic, retain) SendTweetViewController *tweetViewController;
@property (nonatomic, retain) YoutubeTypeSelectViewController *typeSelectViewController;


@end

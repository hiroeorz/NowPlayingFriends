//
//  YouTubeListViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kYouTubeSearchCount 10
#define kYouTubeThumbnailHeight 91


@class NowPlayingFriendsAppDelegate;
@class SendTweetViewController;
@class YoutubeTypeSelectViewController;


@interface YouTubeListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate> {

  BOOL movieSelected;
  NSDictionary *selectedMovie;
  NSArray *movies;
  SendTweetViewController *tweetViewController;
  UITableView *movieTableView;
  YoutubeTypeSelectViewController *typeSelectViewController;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UITableView *movieTableView;
@property (nonatomic, retain) NSArray *movies;
@property (nonatomic, retain) NSDictionary *selectedMovie;
@property (nonatomic, retain) SendTweetViewController *tweetViewController;
@property (nonatomic, retain) YoutubeTypeSelectViewController *typeSelectViewController;


@end

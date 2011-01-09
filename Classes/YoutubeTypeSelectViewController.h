//
//  YoutubeTypeSelectViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SendTweetViewController;
@class NowPlayingFriendsAppDelegate;

@interface YoutubeTypeSelectViewController : UIViewController {

  BOOL openSelectViewFlag;
  SendTweetViewController *tweetViewController;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) SendTweetViewController *tweetViewController;


-(IBAction)cancel:(id)sender;
-(IBAction)selectTopOfRanking:(id)sender;
-(IBAction)openSelectView:(id)sender;

@end

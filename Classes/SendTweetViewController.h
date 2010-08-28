//
//  SendTweetViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NowPlayingFriendsAppDelegate.h"
#import "TwitterClient.h"

@interface SendTweetViewController : UIViewController {
  TwitterClient *twitterClient;
  UITextView *editView;
}

@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) IBOutlet UITextView *editView;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

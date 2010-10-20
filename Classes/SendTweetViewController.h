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

@interface SendTweetViewController : UIViewController <UITextViewDelegate> {
  TwitterClient *twitterClient;
  UITextView *editView;
  UILabel *letterCountLabel;
  BOOL sending;
}

@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) IBOutlet UITextView *editView;
@property (nonatomic, retain) IBOutlet UILabel *letterCountLabel;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)countAndWriteTweetLength:(NSInteger)textcount;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

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


#define setTweetEditField(aEditView, kXPosition, kWidth, kHeight)  \
                          CGRect frame;	      \
                          frame.origin.x = kXPosition; \
                          frame.origin.y = 5; \
                          frame.size.width = kWidth; \
                          frame.size.height = kHeight; \
                          aEditView.backgroundColor = [UIColor whiteColor]; \
                          aEditView.textColor = [UIColor blackColor]; \
                          aEditView.font = [UIFont systemFontOfSize:15]; \
                          aEditView.frame = frame;



@interface SendTweetViewController : UIViewController <UITextViewDelegate> {

  BOOL sending;
  NSString *defaultTweetString;
  TwitterClient *twitterClient;
  UIActivityIndicatorView *indicator;
  UILabel *letterCountLabel;
  UITextView *editView;
  UIView *indicatorBase;
}

@property (nonatomic, retain) IBOutlet NSString *defaultTweetString;
@property (nonatomic, retain) IBOutlet UILabel *letterCountLabel;
@property (nonatomic, retain) IBOutlet UITextView *editView;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIView *indicatorBase;
@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;

- (IBAction)clearText:(id)sender;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)countAndWriteTweetLength:(NSInteger)textcount;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

//
//  SendTweetViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "TwitterClient.h"


@class MusicPlayerViewController;
@class NowPlayingFriendsAppDelegate;
@class TwitterClient;


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



@interface SendTweetViewController : UIViewController <UITextViewDelegate, FBLoginViewDelegate> {

  BOOL addAlbumArtwork;
  BOOL linkAdded;
  BOOL sending;
  MusicPlayerViewController *musicPlayer;
  NSDictionary *youtubeSearchResult;
  NSNumber  *inReplyToStatusId;
  NSString *defaultTweetString;
  NSString *sourceString;
  TwitterClient *twitterClient;
  UIActivityIndicatorView *indicator;
  UIButton *addAlbumArtworkButton;
  UIButton *retweetButton;
  UIButton *selectSNSButton;
  UILabel *letterCountLabel;
  UISwitch *isSendToFacabookSwitch;
  UISwitch *isSendToTwitterSwitch;
  UITextView *editView;
  UIView *indicatorBase;
  UIView *snsSelectViewFacebook;

  /* Facebook */
  FBProfilePictureView *profilePic;
  UIButton *buttonPostStatus;
  UIButton *buttonPostPhoto;
  UIButton *buttonPickFriends;
  UIButton *buttonPickPlace;
  UILabel *labelFirstName;
  id<FBGraphUser> loggedInUser;
  BOOL isFacebookLoggedIn;
}

@property (nonatomic, retain) IBOutlet NSString *defaultTweetString;
@property (nonatomic, retain) IBOutlet UIButton *addAlbumArtworkButton;
@property (nonatomic, retain) IBOutlet UIButton *retweetButton;
@property (nonatomic, retain) IBOutlet UIButton *selectSNSButton;
@property (nonatomic, retain) IBOutlet UILabel *letterCountLabel;
@property (nonatomic, retain) IBOutlet UISwitch *isSendToFacabookSwitch;
@property (nonatomic, retain) IBOutlet UISwitch *isSendToTwitterSwitch;
@property (nonatomic, retain) IBOutlet UITextView *editView;
@property (nonatomic, retain) IBOutlet UIView *snsSelectViewFacebook;
@property (nonatomic, retain) MusicPlayerViewController *musicPlayer;
@property (nonatomic, retain) NSNumber  *inReplyToStatusId;
@property (nonatomic, retain) NSString *sourceString;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIView *indicatorBase;
@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;

/* Facebook */
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostStatus;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickFriends;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickPlace;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;


- (IBAction)changeFacebookSelectStatus:(id)sender;
- (IBAction)changeTwitterSelectStatus:(id)sender;

- (IBAction)showSNSSelectView:(id)sender;
- (IBAction)toggleAddAlbumArtworkFlag:(id)sender;
- (IBAction)addITunesStoreSearchTweet:(id)sender;
- (IBAction)addYouTubeTweet:(id)sender;
- (IBAction)clearText:(id)sender;
- (IBAction)openTwitterFriendsViewController:(id)sender;
- (IBAction)setRetweetString:(id)sender;
- (void)addScreenName:(NSString *)screenName;
- (void)addYouTubeLink:(NSArray *)searchResults;
- (void)countAndWriteTweetLength:(NSInteger)textcount;
- (void)startIndicator;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

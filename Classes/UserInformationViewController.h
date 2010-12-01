//
//  UserInformationViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NowPlayingFriendsAppDelegate.h"
#import "OAuthConsumer/OAConsumer.h"
#import "OAuthConsumer/OAMutableURLRequest.h"
#import "OAuthConsumer/OARequestParameter.h"
#import "OAuthConsumer/OADataFetcher.h"

@interface UserInformationViewController : UIViewController {

@private
  BOOL activateFlag;
  NSString *username;
  UIButton *profileImageButton;
  UILabel *nameLabel;
  UILabel *locationLabel;
  UITextView *descriptionView;
  UILabel *followersLabel;
  UILabel *friendsLabel;
  UIButton *followButton;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) IBOutlet UIButton *profileImageButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UILabel *followersLabel;
@property (nonatomic, retain) IBOutlet UILabel *friendsLabel;
@property (nonatomic, retain) IBOutlet UIButton *followButton;

- (id)initWithUserName:(NSString *)newUsername;

- (void)setFollowButtonEnabled;
- (void)setUserInformations:(NSDictionary *)user;
- (void)getUserInformation;
- (void)getUserProfileImage:(NSDictionary *)user;
- (void)setUserProfileImage:(UIImage *)imageData;

- (IBAction)openUserTimeline;
- (IBAction)followUser;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

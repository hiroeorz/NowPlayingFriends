//
//  UserInformationViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NowPlayingFriendsAppDelegate.h"

@interface UserInformationViewController : UIViewController {

@private
  NSString *username;
  UIButton *profileImageButton;
  UILabel *nameLabel;
  UILabel *locationLabel;
  UITextView *descriptionView;
  UILabel *followersLabel;
  UILabel *friendsLabel;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) IBOutlet UIButton *profileImageButton;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *locationLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) IBOutlet UILabel *followersLabel;
@property (nonatomic, retain) IBOutlet UILabel *friendsLabel;

- (id)initWithUserName:(NSString *)newUsername;

- (void)setUserInformations:(NSDictionary *)user;
- (void)getUserInformation;
- (void)getUserProfileImage:(NSDictionary *)user;
- (void)setUserProfileImage:(NSData *)imageData;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

//
//  UserAuthenticationViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TwitterClient.h"
#import "NowPlayingFriendsAppDelegate.h"


@class  MusicPlayerViewController;


@interface UserAuthenticationViewController : UIViewController {

  UITextField *nameField;
  UITextField *passwordField;
  TwitterClient *twitterClient;
  MusicPlayerViewController *musicPlayerViewController;
}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) MusicPlayerViewController *musicPlayerViewController;

- (IBAction)authenticate:(id)sender;
- (IBAction)nameFieldDoneEditing:(id)sender;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (NowPlayingFriendsAppDelegate *)appDelegate;

@end

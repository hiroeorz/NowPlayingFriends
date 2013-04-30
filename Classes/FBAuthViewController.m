//
//  FBAuthViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 13/04/28.
//  Copyright (c) 2013年 hiroe_orz17. All rights reserved.
//

#import "FBAuthViewController.h"

#import <CoreLocation/CoreLocation.h>
#import "NowPlayingFriendsAppDelegate.h"


@interface FBAuthViewController () <FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePic;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostStatus;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostPhoto;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickFriends;
@property (strong, nonatomic) IBOutlet UIButton *buttonPickPlace;
@property (strong, nonatomic) IBOutlet UILabel *labelFirstName;
@property (strong, nonatomic) id<FBGraphUser> loggedInUser;
@end

@interface FBAuthViewController (Local)
@end


@implementation FBAuthViewController

@synthesize buttonPostStatus = _buttonPostStatus;
@synthesize buttonPostPhoto = _buttonPostPhoto;
@synthesize buttonPickFriends = _buttonPickFriends;
@synthesize buttonPickPlace = _buttonPickPlace;
@synthesize labelFirstName = _labelFirstName;
@synthesize loggedInUser = _loggedInUser;
@synthesize profilePic = _profilePic;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NowPlayingFriendsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
  CGFloat width = [appDelegate windowWidth];
  CGFloat height = [appDelegate windowHeight];
  
  FBLoginView *loginview = [[FBLoginView alloc] init];

  CGFloat loginviewOffsetX = width / 2.0f - (loginview.frame.size.width / 2.0f);
  CGFloat loginviewOffsetY = height / 2.0f - (loginview.frame.size.height / 2.0f);

  loginview.frame = CGRectOffset(loginview.frame, loginviewOffsetX, loginviewOffsetY);
  loginview.delegate = self;
  [self.view addSubview:loginview];
  [loginview sizeToFit];
}

- (void)viewDidUnload {
  self.buttonPickFriends = nil;
  self.buttonPickPlace = nil;
  self.buttonPostPhoto = nil;
  self.buttonPostStatus = nil;
  self.labelFirstName = nil;
  self.loggedInUser = nil;
  self.profilePic = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

  self.buttonPostPhoto.enabled = YES;
  self.buttonPostStatus.enabled = YES;
  self.buttonPickFriends.enabled = YES;
  self.buttonPickPlace.enabled = YES;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

  self.labelFirstName.text = [NSString stringWithFormat:@"Logged in with %@", user.first_name];
  self.profilePic.profileID = user.id;
  self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {

  FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
  p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
  BOOL canShareFB = [FBDialogs canPresentShareDialogWithParams:p];
  BOOL canShareiOS6 = [FBDialogs canPresentOSIntegratedShareDialogWithSession:nil];

  self.buttonPostStatus.enabled = canShareFB || canShareiOS6;
  self.buttonPostPhoto.enabled = NO;
  self.buttonPickFriends.enabled = NO;
  self.buttonPickPlace.enabled = NO;
    
  self.profilePic.profileID = nil;
  self.labelFirstName.text = nil;
  self.loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {

  NSLog(@"FBLoginView encountered an error=%@", error);
}


@end

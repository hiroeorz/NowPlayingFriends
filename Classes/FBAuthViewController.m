//
//  FBAuthViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 13/04/28.
//  Copyright (c) 2013年 hiroe_orz17. All rights reserved.
//

#import "FBAuthViewController.h"

#import <CoreLocation/CoreLocation.h>

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
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  FBLoginView *loginview = [[FBLoginView alloc] init];
  loginview.frame = CGRectOffset(loginview.frame, 10, 10);
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
  // first get the buttons set for login mode
  self.buttonPostPhoto.enabled = YES;
  self.buttonPostStatus.enabled = YES;
  self.buttonPickFriends.enabled = YES;
  self.buttonPickPlace.enabled = YES;

  // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
  [self.buttonPostStatus setTitle:@"Post Status Update (Logged On)" forState:self.buttonPostStatus.state];
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
  // here we use helper properties of FBGraphUser to dot-through to first_name and
  // id properties of the json response from the server; alternatively we could use
  // NSDictionary methods such as objectForKey to get values from the my json object
  self.labelFirstName.text = [NSString stringWithFormat:@"Hello %@!", user.first_name];
  // setting the profileID property of the FBProfilePictureView instance
  // causes the control to fetch and display the profile picture for the user
  self.profilePic.profileID = user.id;
  self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  // test to see if we can use the share dialog built into the Facebook application
  FBShareDialogParams *p = [[FBShareDialogParams alloc] init];
  p.link = [NSURL URLWithString:@"http://developers.facebook.com/ios"];
#ifdef DEBUG
  [FBSettings enableBetaFeatures:FBBetaFeaturesShareDialog];
#endif
  BOOL canShareFB = [FBDialogs canPresentShareDialogWithParams:p];
  BOOL canShareiOS6 = [FBDialogs canPresentOSIntegratedShareDialogWithSession:nil];

  self.buttonPostStatus.enabled = canShareFB || canShareiOS6;
  self.buttonPostPhoto.enabled = NO;
  self.buttonPickFriends.enabled = NO;
  self.buttonPickPlace.enabled = NO;
    
  // "Post Status" available when logged on and potentially when logged off.  Differentiate in the label.
  [self.buttonPostStatus setTitle:@"Post Status Update (Logged Off)" forState:self.buttonPostStatus.state];
    
  self.profilePic.profileID = nil;
  self.labelFirstName.text = nil;
  self.loggedInUser = nil;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
  // see https://developers.facebook.com/docs/reference/api/errors/ for general guidance on error handling for Facebook API
  // our policy here is to let the login view handle errors, but to log the results
  NSLog(@"FBLoginView encountered an error=%@", error);
}


@end

//
//  UserInformationViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserInformationViewController.h"
#import "TwitterClient.h"
#import "UserTimelineViewController.h"

@implementation UserInformationViewController

@synthesize username;
@synthesize profileImageButton;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize descriptionView;
@synthesize followersLabel;
@synthesize friendsLabel;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [username release];
  [profileImageButton release];
  [nameLabel release];
  [locationLabel release];
  [descriptionView release];
  [followersLabel release];
  [friendsLabel release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.username = nil;
  self.profileImageButton = nil;
  self.nameLabel = nil;
  self.locationLabel = nil;
  self.descriptionView = nil;
  self.followersLabel = nil;
  self.friendsLabel = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma initializer

- (id)initWithUserName:(NSString *)newUsername {

  self = [super initWithNibName:@"UserInformationViewController" bundle:nil];

  if (self != nil) {
    self.username = newUsername;
  }

  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {

  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = username;
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  [self performSelectorInBackground:@selector(getUserInformation)
	withObject:nil];

  [super viewDidAppear:animated];
}

#pragma mark -

- (void)getUserInformation {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  TwitterClient *client = [[TwitterClient alloc] init];

  NSDictionary *user = [client userInformation:username];
  NSLog(@"user: %@", user);

  [self performSelectorInBackground:@selector(getUserProfileImage:)
	withObject:user];

  [self performSelectorOnMainThread:@selector(setUserInformations:)
	withObject:user
	waitUntilDone:YES];

  [client release];
  [pool release];
}

- (void)setUserInformations:(NSDictionary *)user {

  nameLabel.text = [user objectForKey:@"name"];
  locationLabel.text = [user objectForKey:@"location"];
  descriptionView.font = [UIFont systemFontOfSize:13];
  descriptionView.text = [user objectForKey:@"description"];

  followersLabel.text = [NSString stringWithFormat:@"Followers :  %@",
				  [user objectForKey:@"followers_count"]];

  friendsLabel.text = [NSString stringWithFormat:@"Friends    :  %@",
				[user objectForKey:@"friends_count"]];

}

- (void)getUserProfileImage:(NSDictionary *)user {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSData *imageData = [self.appDelegate originalProfileImage:user];

  [self performSelectorOnMainThread:@selector(setUserProfileImage:)
	withObject:imageData
	waitUntilDone:YES];

  [pool release];
}

- (void)setUserProfileImage:(NSData *)imageData {

  UIImage *newImage = [[UIImage alloc] initWithData:imageData];
  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
  [newImage release];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)openUserTimeline {
  
  UserTimelineViewController *viewController = 
    [[UserTimelineViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

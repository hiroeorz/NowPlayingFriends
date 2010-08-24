//
//  UserInformationViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserInformationViewController.h"
#import "TwitterClient.h"


@implementation UserInformationViewController

@synthesize username;
@synthesize profileImageButton;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize descriptionView;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [username release];
  [profileImageButton release];
  [nameLabel release];
  [locationLabel release];
  [descriptionView release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.username = nil;
  self.profileImageButton = nil;
  self.nameLabel = nil;
  self.locationLabel = nil;
  self.descriptionView = nil;
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

  [self performSelectorOnMainThread:@selector(setUserInformations:)
	withObject:user
	waitUntilDone:YES];

  [client release];
  [pool release];
}

#pragma mark -

- (void)setUserInformations:(NSDictionary *)user {

  nameLabel.text = [user objectForKey:@"name"];
  locationLabel.text = [user objectForKey:@"location"];
  descriptionView.font = [UIFont systemFontOfSize:13];
  descriptionView.text = [user objectForKey:@"description"];

  NSData *imageData = [self.appDelegate originalProfileImage:user];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];
  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
  [newImage release];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

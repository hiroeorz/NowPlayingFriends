//
//  UserInformationViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserInformationViewController.h"
#import "TwitterClient.h"
#import "JSON/JSON.h"
#import "UserTimelineViewController.h"

@implementation UserInformationViewController

@synthesize username;
@synthesize profileImageButton;
@synthesize nameLabel;
@synthesize locationLabel;
@synthesize descriptionView;
@synthesize followersLabel;
@synthesize friendsLabel;
@synthesize followButton;

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
  [followButton release];
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
  self.followButton = nil;
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

  [followButton setEnabled:NO];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  [self performSelectorInBackground:@selector(getUserInformation)
	withObject:nil];

  [self performSelectorInBackground:@selector(setFollowButtonEnabled)
	withObject:nil];

  [super viewDidAppear:animated];
}

#pragma mark -

- (void)setFollowButtonEnabled {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  TwitterClient *client = [[TwitterClient alloc] init];
  BOOL following = [client checkFollowing:username];

  [self performSelectorOnMainThread:@selector(setFollowingButtonFollowing:)
	withObject:following
	waitUntilDone:NO];

  [client release];
  [pool release];
}

- (void)setFollowingButtonFollowing:(BOOL)following {

  if (following == YES) {
    [followButton setEnabled:NO];
    followButton.titleLabel.text = @"Following";
  } else {
    [followButton setEnabled:YES];
    followButton.titleLabel.text = @"  Follow";
  }
}

- (void)getUserInformation {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  TwitterClient *client = [[TwitterClient alloc] init];
  NSDictionary *user = [client userInformation:username];

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
  descriptionView.font = [UIFont systemFontOfSize:15];
  descriptionView.text = [user objectForKey:@"description"];

  followersLabel.text = [NSString stringWithFormat:@"Followers :  %@",
				  [user objectForKey:@"followers_count"]];

  friendsLabel.text = [NSString stringWithFormat:@"Friends    :  %@",
				[user objectForKey:@"friends_count"]];

}

- (void)getUserProfileImage:(NSDictionary *)user {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  UIImage *newImage = [self.appDelegate originalProfileImage:user];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  [self performSelectorOnMainThread:@selector(setUserProfileImage:)
	withObject:newImage
	waitUntilDone:YES];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [pool release];
}

- (void)setUserProfileImage:(UIImage *)newImage {

  [self.appDelegate setResizedImage:newImage toButton:profileImageButton];
  [newImage release];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)openUserTimeline {
  
  UserTimelineViewController *viewController = 
    [[UserTimelineViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)followUser {

  TwitterClient *client = [[TwitterClient alloc] init];
  [client followUser:username delegate:self];

  [client release];
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSDictionary *result = [dataString JSONValue];

  if ([result objectForKey:@"error"] != nil) {
    UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Could not follow"
			   message:[result objectForKey:@"error"]
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  } else {

    [followButton setEnabled:NO];
    followButton.titleLabel.text = @"Following";
  }
  
  [dataString release];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

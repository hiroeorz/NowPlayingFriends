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

@interface UserInformationViewController (Local)
- (void)setFollowingButtonFollowing:(NSNumber *)followingNumber;
@end

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

  //[descriptionView release]; /* commented out because reason of crash */
  [followButton release];
  [followersLabel release];
  [friendsLabel release];
  [locationLabel release];
  [nameLabel release];
  [profileImageButton release];
  [username release];
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
    activateFlag = NO;
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  [super viewDidLoad];
  self.title = username;

  if (descriptionView != nil) {
    [descriptionView release];
  }

  descriptionView = [[UITextView alloc] init];
  CGRect frame;
  frame.origin.x = 0;
  frame.origin.y = 169;
  frame.size.width = 320;
  frame.size.height = 193;
  descriptionView.frame = frame;
  descriptionView.font = [UIFont systemFontOfSize:15];
  descriptionView.backgroundColor = [UIColor blackColor];
  descriptionView.textColor = [UIColor grayColor];
}

- (void)viewWillAppear:(BOOL)animated {

  [followButton setEnabled:NO];
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {

  activateFlag = YES;
  
  [self performSelectorInBackground:@selector(getUserInformation)
	withObject:nil];
  
  [self performSelectorInBackground:@selector(setFollowButtonEnabled)
	withObject:nil];

  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  NSLog(@"viewWillDisappear");
  activateFlag = NO;
}

#pragma mark -

- (void)setFollowButtonEnabled {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  TwitterClient *client = [[[TwitterClient alloc] init] autorelease];
  BOOL following = [client checkFollowing:username];

  if (activateFlag) {
    [self performSelectorOnMainThread:@selector(setFollowingButtonFollowing:)
	  withObject:[NSNumber numberWithBool:following]
	  waitUntilDone:YES];
  }

  [pool release];
}

- (void)setFollowingButtonFollowing:(NSNumber *)followingNumber {

  BOOL following = [followingNumber boolValue];

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
  TwitterClient *client = [[[TwitterClient alloc] init] autorelease];

  NSDictionary *user = [client userInformation:username];

  if (activateFlag) {
    [self performSelectorOnMainThread:@selector(setUserInformations:)
	  withObject:user
	  waitUntilDone:YES];
  }

  [self getUserProfileImage:user];
  [pool release];
}

- (void)setUserInformations:(NSDictionary *)user {

  if (![[user objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
    nameLabel.text = [user objectForKey:@"name"];
  }

  if (![[user objectForKey:@"location"] isKindOfClass:[NSNull class]]) {
    locationLabel.text = [user objectForKey:@"location"];
  }

  if (![[user objectForKey:@"followers_count"] isKindOfClass:[NSNull class]]) {
    followersLabel.text = [NSString stringWithFormat:@"Followers :  %@",
				    [user objectForKey:@"followers_count"]];
  }

  if (![[user objectForKey:@"friends_count"] isKindOfClass:[NSNull class]]) {
    friendsLabel.text = [NSString stringWithFormat:@"Friends    :  %@",
				  [user objectForKey:@"friends_count"]];
  }

  if (![[user objectForKey:@"description"] isKindOfClass:[NSNull class]]) {
    descriptionView.text = [user objectForKey:@"description"];
    [self.view addSubview:descriptionView];
  }
}

- (void)getUserProfileImage:(NSDictionary *)user {

  UIImage *newImage = [[self.appDelegate originalProfileImage:user] retain];

  if (activateFlag) {
    [self performSelectorOnMainThread:@selector(setUserProfileImage:)
	  withObject:newImage
	  waitUntilDone:YES];
  }
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
  [viewController release];
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

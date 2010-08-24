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

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [username release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.username = nil;
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

  [client release];
  [pool release];
}

@end

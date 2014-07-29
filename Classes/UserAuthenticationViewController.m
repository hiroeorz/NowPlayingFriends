//
//  UserAuthenticationViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserAuthenticationViewController.h"
#import "MusicPlayerViewController.h"
#import "TwitterFriendsGetter.h"

@implementation UserAuthenticationViewController

@synthesize musicPlayerViewController;
@synthesize nameField;
@synthesize passwordField;
@synthesize twitterClient;

- (void)dealloc {
  
  [musicPlayerViewController release];
  [nameField release];
  [passwordField release];
  [twitterClient release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.musicPlayerViewController = nil;
  self.nameField = nil;
  self.passwordField = nil;
  self.twitterClient = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    self.twitterClient = [[TwitterClient alloc] init];
  }
  return self;
}

- (void)viewDidLoad {

  [super viewDidLoad];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate completeButton:@selector(authenticate:) target:self];

  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)viewDidAppear:(BOOL)animated {

  [nameField becomeFirstResponder];
}

- (IBAction)authenticate:(id)sender {

  NSString *username = nameField.text;
  NSString *password = passwordField.text;

  if ([username length] > 0 && [password length] > 0) {
    [twitterClient getAccessTokenWithUsername:username password:password
		   delegate:self];
  }
}

- (IBAction)nameFieldDoneEditing:(id)sender {
  
  [passwordField becomeFirstResponder];
}

#pragma mark -

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  NSString *dataString = [[NSString alloc] initWithData:data 
					   encoding:NSUTF8StringEncoding];
  [dataString autorelease];
  NSLog(@"dataString: %@", dataString);
  
  NSRange rangeOfInvalid = [dataString rangeOfString:@"Invalid"];
  NSRange rangeOfOauthToken = [dataString rangeOfString:@"oauth_token"];

  if (rangeOfInvalid.location == NSNotFound && 
      rangeOfOauthToken.location != NSNotFound) {

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *pair in [dataString componentsSeparatedByString:@"&"]) {
      NSArray *keyValue = [pair componentsSeparatedByString:@"="];
      NSLog(@"pair:%@", pair);
      
      [dict setObject:[keyValue objectAtIndex:1] 
	    forKey:[keyValue objectAtIndex:0]];
    }
    
    NSLog(@"result: %@", dict);
    
    [dict writeToFile:[twitterClient oAuthAccessTokenFileName] atomically:YES];

    UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Authentication success"
			   message:@"authentication seccess, enjoy!"
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
    [passwordField resignFirstResponder];

    if (musicPlayerViewController != nil) {
      [musicPlayerViewController 
	performSelectorInBackground:@selector(refreshProfileImages)
	withObject:nil];
      [musicPlayerViewController displaySubview];
    }

    TwitterFriendsGetter *friendsGetter = [[TwitterFriendsGetter alloc] init];
    [friendsGetter deleteFriendsFiles];
    [friendsGetter release];

    [twitterClient saveFriends];

    [self dismissViewControllerAnimated:YES completion:nil];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Authentication failed"
			   message:dataString
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
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

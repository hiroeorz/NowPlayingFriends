//
//  UserAuthenticationViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserAuthenticationViewController.h"


@implementation UserAuthenticationViewController

@synthesize nameField;
@synthesize passwordField;
@synthesize twitterClient;

- (void)dealloc {
  
  [nameField release];
  [passwordField release];
  [twitterClient release];
  [super dealloc];
}

- (void)viewDidUnload {

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
}

- (IBAction)authenticate:(id)sender {

  NSString *username = nameField.text;
  NSString *password = passwordField.text;

  [twitterClient getAccessTokenWithUsername:username password:password
		 delegate:self];
}

#pragma mark -

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  NSString *dataString = [[NSString alloc] initWithData:data 
					   encoding:NSUTF8StringEncoding];
  [dataString autorelease];
  
  // レスポンスの解析
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  
  for (NSString *pair in [dataString componentsSeparatedByString:@"&"]) {
    NSArray *keyValue = [pair componentsSeparatedByString:@"="];
    [dict setObject:[keyValue objectAtIndex:1] 
	  forKey:[keyValue objectAtIndex:0]];
  }
  
  NSLog(@"result: %@", dict);

  [dict writeToFile:[twitterClient oAuthAccessTokenFileName] 
	atomically:YES];

  [self dismissModalViewControllerAnimated:YES];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError");
}

@end

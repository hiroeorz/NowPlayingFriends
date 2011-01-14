//
//  TwitterFriendsGetter.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/12.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "JSON/JSON.h"
#import "NowPlayingFriendsAppDelegate.h"
#import "OAuthConsumer/OAConsumer.h"
#import "OAuthConsumer/OADataFetcher.h"
#import "OAuthConsumer/OAMutableURLRequest.h"
#import "OAuthConsumer/OARequestParameter.h"
#import "TwitterClient.h"
#import "TwitterFriendsGetter.h"


@implementation TwitterFriendsGetter


@dynamic appDelegate;

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
#pragma Initilizer

- (id)init {
  
  self = [super init];

  if (self != nil) {
  }
  return self;
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData(getting friends list)");
  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSDictionary *result = [dataString JSONValue];
  [dataString release];

  if ([result objectForKey:@"error"] != nil) {
    NSLog(@"Error while friends getting");
    return;
  }

  NSNumber *next_cursor = [result objectForKey:@"next_cursor"];
  NSArray *users = [result objectForKey:@"users"];
  NSMutableArray *array = nil;

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = 
    [documentsDirectory stringByAppendingPathComponent:kFriendsFileName];


  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
  } else {
    array = [[NSMutableArray alloc] init];
  }

  for (NSDictionary *user in users) {
    NSString *screen_name = [user objectForKey:@"screen_name"];
    [array addObject:screen_name];
  }
  
  [array writeToFile:filePath atomically:YES];
  [array release];

  if ([next_cursor integerValue] == 0) {
    NSLog(@"friends getter: getting friends is finished.");
  } else {
    NSLog(@"friends getter: next cursor: %@", next_cursor);
    TwitterClient *client = [[[TwitterClient alloc] init] autorelease];
    [client saveFriendsWithCursor:next_cursor];
  }

  [self autorelease];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError(getting friends list)");
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

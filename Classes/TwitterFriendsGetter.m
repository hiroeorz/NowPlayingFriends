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


@interface TwitterFriendsGetter (Local)
- (NSString *)lastName;
@end

@implementation TwitterFriendsGetter


@dynamic appDelegate;
@synthesize nextCursor;

- (void)dealloc {

  [nextCursor release];
  [super dealloc];
}

#pragma mark -
#pragma Initilizer

- (id)init {
  
  self = [super init];

  if (self != nil) {
    trycount = 3;
  }
  return self;
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData(getting friends list)");
  trycount = 3;

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
  NSMutableDictionary *idDictionary = nil;
  BOOL knownAddressFlag = NO;

  NSString *tmpFilePath = [self tmpFilePath];
  NSString *tmpIdFilePath = [self tmpFriendIDFilePath];
  NSString *lastName = [self lastName];

  if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFilePath]) {
    array = [[NSMutableArray alloc] initWithContentsOfFile:tmpFilePath];
  } else {
    array = [[NSMutableArray alloc] init];
  }

  if ([[NSFileManager defaultManager] fileExistsAtPath:tmpIdFilePath]) {
    idDictionary = 
      [[NSMutableDictionary alloc] initWithContentsOfFile:tmpIdFilePath];
  } else {
    idDictionary = [[NSMutableDictionary alloc] init];
  }  

  for (NSDictionary *user in users) {
    NSString *screen_name = [user objectForKey:@"screen_name"];
    NSNumber *friendId = [user objectForKey:@"id"];

    NSLog(@"friendId: %@", friendId);

    if ([screen_name compare:lastName] == NSOrderedSame) {
      knownAddressFlag = YES;
    }

    if (!knownAddressFlag) {
      [array addObject:screen_name];
      [idDictionary setObject:friendId forKey:screen_name];
    }
  }
  
  [array writeToFile:tmpFilePath atomically:YES];
  [array release];

  [idDictionary writeToFile:tmpIdFilePath atomically:YES];
  [idDictionary release];

  if ([next_cursor integerValue] == 0 || knownAddressFlag) {
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:tmpFilePath
				    toPath:[self filePath]
				    error:&error];
    [[NSFileManager defaultManager] moveItemAtPath:tmpIdFilePath
				    toPath:[self idFilePath]
				    error:&error];
    NSLog(@"friends getter: getting friends is finished.");
  } else {
    NSLog(@"friends getter: next cursor: %@", next_cursor);
    TwitterClient *client = [[[TwitterClient alloc] init] autorelease];
    self.nextCursor = next_cursor;
    [client saveFriendsWithCursor:next_cursor];
  }

  [self autorelease];
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError(getting friends list)");

  if (trycount > 0) {
    trycount--;
    TwitterClient *client = [[[TwitterClient alloc] init] autorelease];
    [client saveFriendsWithCursor:nextCursor];
    [self autorelease];
  }
}

#pragma mark

- (void)deleteFriendsFiles {

  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *filePath = [self filePath];
  NSString *idFilePath = [self idFilePath];

  if ([fileManager fileExistsAtPath:filePath]) {
    NSError *error;
    [fileManager removeItemAtPath:filePath error:&error];
  }
  if ([fileManager fileExistsAtPath:idFilePath]) {
    NSError *error;
    [fileManager removeItemAtPath:idFilePath error:&error];
  }
}

- (NSNumber *)friendIdForName:(NSString *)aName {

  NSString *filePath = [self idFilePath];
  NSMutableDictionary *idDictionary = nil;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    idDictionary = 
      [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
  } else {
    return nil;
  }  
  
  return [idDictionary objectForKey:aName];
}

- (NSString *)tmpFriendIDFilePath {
  return [NSString stringWithFormat:@"%@.tmp", [self idFilePath]];
}

- (NSString *)idFilePath {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = 
    [documentsDirectory stringByAppendingPathComponent:kFriendsIdFileName];

  return filePath;
}

- (NSString *)tmpFilePath {
  return [NSString stringWithFormat:@"%@.tmp", [self filePath]];
}

- (NSString *)filePath {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = 
    [documentsDirectory stringByAppendingPathComponent:kFriendsFileName];

  return filePath;
}

#pragma mark -
#pragma mark Local Methods

- (NSString *)lastName {

  NSArray *array = nil;
  NSString *filePath = [self filePath];
  NSString *lastName = nil;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];

    if (array == nil || [array count] == 0) {
      lastName = nil;
    } else {
      lastName = [array objectAtIndex:0];
    }
    
  } else {
    lastName = nil;
  }
  
  return lastName;
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

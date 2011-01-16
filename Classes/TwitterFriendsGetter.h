//
//  TwitterFriendsGetter.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/12.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFriendsFileName @"friends.plist"
#define kFriendsIdFileName @"friends_id.plist"

@class OAServiceTicket;
@class NowPlayingFriendsAppDelegate;


@interface TwitterFriendsGetter : NSObject {

  NSNumber *nextCursor;
  NSInteger trycount;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) NSNumber *nextCursor;

- (void)deleteFriendsFiles;
- (NSNumber *)friendIdForName:(NSString *)aName;
- (NSString *)tmpFriendIDFilePath;
- (NSString *)idFilePath;
- (NSString *)filePath;
- (NSString *)tmpFilePath;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end

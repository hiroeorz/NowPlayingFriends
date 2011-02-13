//
//  FriendCellProfileImageDelegate.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/13.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>


@class FriendCell;
@class NowPlayingFriendsAppDelegate;


@interface FriendCellProfileImageDelegate : NSOperation {

  BOOL cancelFlag;
  FriendCell *cell;
  NSDictionary *tweetData;
  NSMutableData *imageData;
  NSString *imageURLString;
}


@property (nonatomic) BOOL cancelFlag;
@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) NSMutableData *imageData;
@property (nonatomic, retain) FriendCell *cell;
@property (nonatomic, retain) NSDictionary *tweetData;
@property (nonatomic, retain) NSString *imageURLString;


- (id)initWithTweetData:(NSDictionary *)aData cell:(FriendCell *)aCell;

- (void)startGetProfileImage;

@end

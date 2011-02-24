//
//  TwitpicClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/21.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TwitterClient+ConsumerKey.h"
#import "TwitterClient+TwitpicAPIKey.h"


#define kTwitPicIdsFileNmae @"twitpic_friends.plist"
#define kTwitpicBaseUrl @"http://twitpic.com/%@"
#define kTwitpicShowUrl @"http://api.twitpic.com/2/media/show.json?id=%@"
#define kTwitpicMediaUrl @"http://api.twitpic.com/2/media/show.json?id=%@"


@class NowPlayingFriendsAppDelegate;
@class TwitterClient;


@interface TwitpicClient : NSOperation {

  id senderDelegate;
  BOOL uploadedOk;
  NSMutableData *jsonData;
  NSString *tweetString;
  TwitterClient *twitterClient;
  UIImage *picImage;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) id senderDelegate;
@property (nonatomic, retain) NSMutableData *jsonData;
@property (nonatomic, retain) NSString *tweetString;
@property (nonatomic, retain) TwitterClient *twitterClient;
@property (nonatomic, retain) UIImage *picImage;


- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
      twitterClient:(TwitterClient *)twitterClient
	   delegate:(id)aDelegate;

- (NSString *)getUrlWithAlbumName:(NSString *)albumName;

@end

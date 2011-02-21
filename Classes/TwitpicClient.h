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


@class NowPlayingFriendsAppDelegate;
@class TwitterClient;


@interface TwitpicClient : NSObject {

  id senderDelegate;
  TwitterClient *twitterClient;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) id senderDelegate;
@property (nonatomic, retain) TwitterClient *twitterClient;


+ (id)twitpicWithTwitterClient:(TwitterClient *)aClient;
- (id)initWithTwitterClient:(TwitterClient *)aClient;

- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
      twitterClient:(TwitterClient *)twitterClient
	   delegate:(id)aDelegate;

@end

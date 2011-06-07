//
//  TwitterClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterClient+ConsumerKey.h"
#import "TwitterClient+TwitpicAPIKey.h"
#import "OAuthConsumer/OAServiceTicket.h"


#define kVerifyUrl @"https://api.twitter.com/1/account/verify_credentials.json"
#define kOAuthTokenUrl @"https://api.twitter.com/oauth/access_token"
#define kHomeTimelineURL @"http://twitter.com/statuses/home_timeline/%@.json%@"
#define kUserTimelineURL @"http://twitter.com/statuses/user_timeline/%@.json%@"
#define kMenthonsTimelineURL @"http://api.twitter.com/1/statuses/mentions.json%@"
#define kSearchURL @"http://search.twitter.com/search.json?q=%@"
#define kUserInformationURL @"http://api.twitter.com/1/users/show/%@.json"
#define kUpdateStatusURL @"http://twitter.com/statuses/update.json"
#define kOAuthAccetokenFileName @"access_token.plist"
#define kCreateFriendURL @"http://twitter.com/friendships/create/%@.json"
#define kCheckFriendShipURL @"http://api.twitter.com/1/friendships/show.json?target_screen_name=%@"

#define kTwitterFrindsSearchUrl @"https://api.twitter.com/1/statuses/friends.json?screen_name=%@&cursor=%@"


@class NowPlayingFriendsAppDelegate;
@class TwitpicClient;


@interface TwitterClient : NSObject {
  TwitpicClient *twitpicClient;
}


@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) TwitpicClient *twitpicClient;


- (void)saveFriends;
- (void)saveFriendsWithCursor:(NSNumber *)cursorNumber;
- (void)followUser:(NSString *)usernameOrId delegate:(id)aDelegate;
- (BOOL)checkFollowing:(NSString *)username;
- (NSArray *)getHomeTimeLine:(NSString *)username sinceId:(NSNumber *)sinceId;
- (NSArray *)getUserTimeLine:(NSString *)username sinceId:(NSNumber *)sinceId;;
- (NSArray *)getMentionsTimeLineSince:(NSNumber *)sinceId;
- (NSArray *)getSearchTimeLine:(NSString *)searchString, ...;
- (NSDictionary *)userInformation:(NSString *)username;

- (void)updateStatus:(NSString *)message
   inReplyToStatusId:(NSNumber *)replayToStatusId
	    delegate:(id)aDelegate;

- (void)updateStatus:(NSString *)message
   inReplyToStatusId:(NSNumber *)replayToStatusId
	   withArtwork:(BOOL)withArtwork
	    delegate:(id)aDelegate;


- (NSString *)username;

- (void)getAccessTokenWithUsername:(NSString *)username 
			  password:(NSString *)password
			  delegate:(id)delegate;

- (NSDictionary *)oAuthToken;
- (BOOL)oAuthTokenExist;
- (NSString *)oAuthAccessTokenFileName;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

- (void)sendUploadedAlbumArtworkLinkedTweet:(NSString *)tweet
				   delegate:(id)aDelegate;

@end

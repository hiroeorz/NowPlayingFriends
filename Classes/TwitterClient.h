//
//  TwitterClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterClient+ConsumerKey.h"
#import "OAuthConsumer/OAServiceTicket.h"

#define kHomeTimelineURL @"http://twitter.com/statuses/home_timeline/%@.json"
#define kUserTimelineURL @"http://twitter.com/statuses/user_timeline/%@.json"
#define kMenthonsTimelineURL @"http://api.twitter.com/1/statuses/mentions.json"
#define kSearchURL @"http://search.twitter.com/search.json?q=%@"
#define kUserInformationURL @"http://api.twitter.com/1/users/show/%@.json"
#define kUpdateStatusURL @"http://twitter.com/statuses/update.json"
#define kOAuthAccetokenFileName @"access_token.plist"
#define kCreateFriendURL @"http://twitter.com/friendships/create/%@.json"
#define kCheckFriendShipURL @"http://api.twitter.com/1/friendships/show.json?target_screen_name=%@"

@interface TwitterClient : NSObject {

}

- (void)followUser:(NSString *)usernameOrId delegate:(id)aDelegate;
- (BOOL)checkFollowing:(NSString *)username;
- (NSArray *)getHomeTimeLine:(NSString *)username;
- (NSArray *)getUserTimeLine:(NSString *)username;
- (NSArray *)getMentionsTimeLine;
- (NSArray *)getSearchTimeLine:(NSString *)searchString, ...;
- (NSDictionary *)userInformation:(NSString *)username;
- (void)updateStatus:(NSString *)message delegate:(id)aDelegate;
- (NSString *)username;

- (NSString *)urlEncodedString:(NSString *)str;
- (NSArray *)arrayOfRemoteJson:(NSString *)urlString;
- (NSDictionary *)dictionaryOfRemoteJson:(NSString *)urlString;
- (NSString *)stringOfRemoteJson:(NSString *)urlString;
- (void)logJsonData:(NSArray *)jsonArray;

- (void)getAccessTokenWithUsername:(NSString *)username 
			  password:(NSString *)password
			  delegate:(id)delegate;

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;

@end

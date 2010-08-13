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
#define kSearchURL @"http://search.twitter.com/search.json?q=%@"

@interface TwitterClient : NSObject {

}

- (NSArray *)getHomeTimeLine:(NSString *)username;
- (NSArray *)getUserTimeLine:(NSString *)username;
- (NSArray *)getSearchTimeLine:(NSString *)searchString;

- (NSArray *)arrayOfRemoteJson:(NSString *)urlString;
- (void)logJsonData:(NSArray *)jsonArray;

- (void)getAccessTokenWithUsername:(NSString *)username 
			  password:(NSString *)password;
- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;
- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error;



@end

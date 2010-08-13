//
//  TwitterClient.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TwitterClient.h"
#import "OAuthConsumer/OAConsumer.h"
#import "OAuthConsumer/OAMutableURLRequest.h"
#import "OAuthConsumer/OARequestParameter.h"
#import "OAuthConsumer/OADataFetcher.h"
#import "OAuthConsumer/OAServiceTicket.h"

@implementation TwitterClient

#pragma mark -
#pragma Twitter Get TimeLine Methods

#pragma mark -
#pragma Twitter Post Methods

#pragma mark -
#pragma Get AccessToken Methods

/**
 * @brief ユーザ名とパスワードからユーザのアクセストークンを取得する。
 */
- (void)getAccessTokenWithUsername:(NSString *)username 
			  password:(NSString *)password {
  NSURL *url = 
    [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];

  OAConsumer *consumer =
    [[[OAConsumer alloc] initWithKey:@"YOUR-CONSUMER-KEY"
			 secret:@"YOUR-CONSUMER-SECRET"] autorelease];
  OAMutableURLRequest 
    *request = [[OAMutableURLRequest alloc] initWithURL:url
					    consumer:consumer
					    token:nil
					    realm:nil
					    signatureProvider:nil]; 
  [request autorelease];

  // 新たに付加するパラメータ
  NSMutableArray *xAuthParameters = [NSMutableArray arrayWithCapacity:3];
  [xAuthParameters addObject:[OARequestParameter 
			       requestParameter:@"x_auth_mode" 
			       value:@"client_auth"]];

  [xAuthParameters addObject:[OARequestParameter 
			       requestParameter:@"x_auth_username" 
			       value:username]];

  [xAuthParameters addObject:[OARequestParameter 
			       requestParameter:@"x_auth_password" 
			       value:password]];

  // 順番が大事！
  [request setHTTPMethod:@"POST"];
  [request setParameters:xAuthParameters];

  OADataFetcher *fetcher = [[[OADataFetcher alloc] init] autorelease];
  [fetcher fetchDataWithRequest:request
	   delegate:self
	   didFinishSelector:@selector(ticket:didFinishWithData:)
	   didFailSelector:@selector(ticket:didFailWithError:)];
}

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

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
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError");
}

@end

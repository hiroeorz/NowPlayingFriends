//
//  TwitterClient.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TwitterClient.h"
#import "JSON/JSON.h"
#import "OAuthConsumer/OAConsumer.h"
#import "OAuthConsumer/OAMutableURLRequest.h"
#import "OAuthConsumer/OARequestParameter.h"
#import "OAuthConsumer/OADataFetcher.h"

@implementation TwitterClient

#pragma mark -
#pragma Twitter Get TimeLine Methods

/**
 * @brief 指定されたユーザのタイムラインを取得します。
 */
- (NSArray *)getHomeTimeLine:(NSString *)username {

  NSString *urlString = [[NSString alloc] 
			  initWithFormat:kHomeTimelineURL, username];

  return [self arrayOfRemoteJson:urlString];
}

- (NSArray *)getUserTimeLine:(NSString *)username {

  NSString *urlString = [[NSString alloc] 
			  initWithFormat:kUserTimelineURL, username];

  return [self arrayOfRemoteJson:urlString];
}

- (NSArray *)getSearchTimeLine:(NSString *)searchString, ... {

  NSString *eachObject;
  va_list argumentList;
  NSMutableString *urlString;
  NSString *encodedString;

  if (searchString) {
    encodedString = [self urlEncodedString:searchString];
    urlString = [[NSMutableString alloc] 
		  initWithFormat:kSearchURL, encodedString];
    
    va_start(argumentList, searchString);
    
    while(eachObject = va_arg(argumentList, id)) {
      encodedString = [self urlEncodedString:eachObject];
      [urlString appendString:@"+"];
      [urlString appendString:encodedString];
    }    
    va_end(argumentList);
  }

  NSURL *url = [NSURL URLWithString:urlString];
  [urlString release];

  NSString *jsonString = [[NSString alloc] initWithContentsOfURL:url
					   encoding:NSUTF8StringEncoding
					   error:nil];

  NSDictionary *jsonDictionary = [jsonString JSONValue];
  NSArray *jsonArray = [jsonDictionary objectForKey:@"results"];
  [jsonString release];

  return jsonArray;
}

/**
 * @brief URLエンコードされた文字列を返します。
 */
- (NSString *)urlEncodedString:(NSString *)str {

  NSString *encodedString = 
    (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,  
							str,
							NULL,  
							CFSTR(";,/?:@&=+$#"),
							kCFStringEncodingUTF8);
  return [encodedString autorelease];
}

/**
 * @brief 渡されたURL文字列からJSONデータを取得しArrayにパースして返します。
 */
- (NSArray *)arrayOfRemoteJson:(NSString *)urlString {

  NSURL *url = [NSURL URLWithString:urlString];
  [urlString release];

  NSString *jsonString = [[NSString alloc] initWithContentsOfURL:url
					   encoding:NSUTF8StringEncoding
					   error:nil];

  NSArray *jsonArray = [jsonString JSONValue];
  [jsonString release];

  //[self logJsonData:jsonArray];

  return [jsonArray autorelease];
}

- (void)logJsonData:(NSArray *)jsonArray {

  for (NSDictionary *dic in jsonArray) {
    NSDictionary *user = [dic valueForKey:@"user"];

    NSLog(@"user: %@", [user objectForKey:@"name"]);
    NSLog(@"image: %@", [user objectForKey:@"profile_image_url"]);
    NSLog(@"text: %@", [dic objectForKey:@"text"]);
    NSLog(@"created_at: %@", [dic objectForKey:@"created_at"]);
  }
}

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

  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"kConsumerKey"
					     secret:@"kConsumerSecret"];
  OAMutableURLRequest 
    *request = [[OAMutableURLRequest alloc] initWithURL:url
					    consumer:consumer
					    token:nil
					    realm:nil
					    signatureProvider:nil];
  [consumer release];

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

  [request release];
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

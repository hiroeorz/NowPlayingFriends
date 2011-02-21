//
//  TwitpicClient.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/21.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "TwitpicClient.h"

#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "JSON/JSON.h"
#import "NowPlayingFriendsAppDelegate.h"
#import "TwitterClient.h"


@interface TwitpicClient (Local)

- (void)uploadToTwitterByTwitPic:(NSString*)tweet image:(UIImage*)image
			delegate:(id)aDelegate;

- (ASIFormDataRequest *)createOAuthEchoRequest:(NSString*)url 
					format:(NSString*)format;

- (void)twitPicRequestFinished:(ASIHTTPRequest *)theRequest;
- (void)requestFailed:(ASIHTTPRequest *)theRequest;

- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
	   delegate:(id)aDelegate;

@end

@implementation TwitpicClient

@dynamic appDelegate;
@synthesize twitterClient;
@synthesize senderDelegate;


- (void)dealloc {

  [senderDelegate release];
  [twitterClient release];
  [super dealloc];
}

#pragma mark -
#pragma Twitpic Upload Methods


- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
      twitterClient:(TwitterClient *)aTwitterClient
	   delegate:(id)aDelegate {

  self.twitterClient = aTwitterClient;
  [self uploadToTwitterByTwitPic:tweet image:aImage delegate:aDelegate];
}


#pragma mark -
#pragma mark Local Methods

/**
 * @brief Twitpicへファイルをアップロードする。
 */
- (ASIFormDataRequest*)createOAuthEchoRequest:(NSString*)url 
				       format:(NSString*)format {

  OAConsumer *consumer = [[OAConsumer alloc] initWithKey:kConsumerKey
					     secret:kConsumerSecret];
    
  NSDictionary *token = [twitterClient oAuthToken];
  OAToken *accessToken =
    [[[OAToken alloc] initWithKey:[token objectForKey:@"oauth_token"]
		      secret:[token objectForKey:@"oauth_token_secret"]] 
      autorelease];

  OAMutableURLRequest *oauthRequest = 
    [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kVerifyUrl]
				  consumer:consumer
				  token:accessToken
				  realm:@"http://api.twitter.com/"
				  signatureProvider:nil] autorelease];
 
  NSString *oauthHeader = [oauthRequest 
			    valueForHTTPHeaderField:@"Authorization"];
  if (!oauthHeader) {
    [oauthRequest prepare];
    oauthHeader = [oauthRequest valueForHTTPHeaderField:@"Authorization"];
  }
 
  NSLog(@"OAuth header : %@\n\n", oauthHeader);
 
  ASIFormDataRequest *request = [ASIFormDataRequest 
				  requestWithURL:[NSURL URLWithString:url]];

  request.requestMethod = @"POST";
  request.shouldAttemptPersistentConnection = NO; 
 
  [request addRequestHeader:@"X-Auth-Service-Provider" value:kVerifyUrl];
  [request addRequestHeader:@"X-Verify-Credentials-Authorization" 
	   value:oauthHeader];
  
  return request;
}

- (void)uploadToTwitterByTwitPic:(NSString*)tweet image:(UIImage*)image 
			delegate:(id)aDelegate {

  NSString *url = @"http://api.twitpic.com/2/upload.json";
  ASIFormDataRequest *request = [self createOAuthEchoRequest:url 
				      format:@"json"];
  
  NSData *imageRepresentation = UIImageJPEGRepresentation(image, 1.0);
  [request setData:imageRepresentation forKey:@"media"];
  [request setPostValue:tweet  forKey:@"message"];
  [request setPostValue:kTwitpicAPIKey forKey:@"key"];
  
  self.senderDelegate = aDelegate;

  [request setDelegate:self];
  [request setDidFinishSelector:@selector(twitPicRequestFinished:)];
  [request setDidReceiveDataSelector:@selector(twitPicReceiveResponse:data:)];
  [request setDidFailSelector:@selector(requestFailed:)];
  [request startAsynchronous];
}

- (void)twitPicReceiveResponse:(ASIHTTPRequest *)theRequest 
			  data:(NSData *)aData {

  NSString *jsonString = [[NSString alloc] initWithData: aData
					   encoding:NSUTF8StringEncoding];

  NSLog(@"Twitpic receiveData.data: %@", jsonString);

  NSDictionary *jsonDictionary = [jsonString JSONValue];
  [jsonString release];

  NSString *tweet = [jsonDictionary objectForKey:@"text"];
  NSString *picUrl = [jsonDictionary objectForKey:@"url"];

  NSString *formattedTweet = [NSString stringWithFormat:@"%@ %@", 
				       tweet, picUrl];

  if ([formattedTweet length] > kMaxTweetLength) { /* 140文字超えたらリンク切り捨て */
    formattedTweet = [NSString stringWithFormat:@"%@", tweet];
  }
  if ([formattedTweet length] > kMaxTweetLength) { /* それでも長かったら切り捨て */
    formattedTweet = [formattedTweet substringToIndex:kMaxTweetLength];
  }

  NSLog(@"formatted tweet: %@", formattedTweet);

  id aDelegate = [[senderDelegate retain] autorelease];
  self.senderDelegate = nil;

  [twitterClient updateStatus:formattedTweet
		 inReplyToStatusId:nil
		 withArtwork:NO
		 delegate:aDelegate];  
}

- (void)twitPicRequestFinished:(ASIHTTPRequest *)theRequest {
  NSLog(@"Twitpic ok.");
  self.twitterClient = nil;
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest {
  self.twitterClient = nil;
  NSString *resultText = [NSString stringWithFormat:@"Request failed:\r\n%@",
				   [[theRequest error] localizedDescription]];
  
  NSLog(@"Twitpic failure: %@", resultText);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

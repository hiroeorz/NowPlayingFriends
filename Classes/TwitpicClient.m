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

- (NSString *)getMediaUrlWithAlbumName:(NSString *)albumName;
- (NSString *)getPictureIdWithAlbumName:(NSString *)albumName;

- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
	   delegate:(id)aDelegate;

- (void)saveId:(NSString *)aUrl withAlbumName:(NSString *)albumName;
- (void)deleteUrlWithAlbumName:(NSString *)albumName;
- (NSString *)filePath;

@end

@implementation TwitpicClient

@dynamic appDelegate;
@synthesize senderDelegate;
@synthesize tweetString;
@synthesize twitterClient;
@synthesize picImage;

- (void)dealloc {

  [picImage release];
  [senderDelegate release];
  [tweetString release];
  [twitterClient release];
  [super dealloc];
}

#pragma mark -
#pragma Public Methods

/**
 * @brief Twitpicへ画像をアップロードし、ツイートを送信する。
 */
- (void)uploadImage:(UIImage *)aImage withTweet:(NSString *)tweet
      twitterClient:(TwitterClient *)aTwitterClient
	   delegate:(id)aDelegate {

  [self cancel];
  self.twitterClient = aTwitterClient;
  self.tweetString = tweet;
  self.picImage = aImage;
  self.senderDelegate = aDelegate;
  uploadedOk = NO;

  NSString *albumName = [self.appDelegate nowPlayingAlbumTitle];
  NSString *picId = [self getPictureIdWithAlbumName:albumName];

  if (picId != nil) {
    NSLog(@"Cached twitpic checking uploaded picture is exist or not...");
    NSString *url = [self getMediaUrlWithAlbumName:albumName];
    NSLog(@"mediaUrl: %@", url);

    NSURLRequest *request = [NSURLRequest 
			      requestWithURL:[NSURL URLWithString:url]];
  
    [NSURLConnection connectionWithRequest:request delegate:self];
  } else {
    NSLog(@"No cached twitpic starting upload...");
    [self uploadToTwitterByTwitPic:tweet image:aImage delegate:aDelegate];
  }
}

#pragma mark -
#pragma NSOperation Delegate Methods

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {

  [self cancel];

  if (uploadedOk == NO) {
    NSLog(@"Picutre is already uploaded");
    uploadedOk = YES;
    [twitterClient sendUploadedAlbumArtworkLinkedTweet:tweetString
		   delegate:senderDelegate];
  }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  uploadedOk = NO;
}

-(void)connection:(NSURLConnection*)connection 
 didFailWithError:(NSError*)error {

  NSLog(@"Twitpic Connection Error");
  NSString *albumName = [self.appDelegate nowPlayingAlbumTitle];
  [self deleteUrlWithAlbumName:albumName];

  [self uploadToTwitterByTwitPic:tweetString 
	image:picImage 
	delegate:senderDelegate];
}

#pragma mark -
#pragma Twitpic Upload Local Methods

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
 
  //NSLog(@"OAuth header : %@\n\n", oauthHeader);
 
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
  
  [request setDelegate:self];
  [request setDidFinishSelector:@selector(twitPicRequestFinished:)];
  [request setDidReceiveDataSelector:@selector(twitPicReceiveResponse:data:)];
  [request setDidFailSelector:@selector(requestFailed:)];
  [request startAsynchronous];
}

/**
 * @brief 送信完了時にデータを引数として呼ばれるメソッド
 */
- (void)twitPicReceiveResponse:(ASIHTTPRequest *)theRequest 
			  data:(NSData *)aData {

  NSString *jsonString = [[NSString alloc] initWithData: aData
					   encoding:NSUTF8StringEncoding];

  //NSLog(@"Twitpic receiveData.data: %@", jsonString);

  NSDictionary *jsonDictionary = [jsonString JSONValue];
  [jsonString release];

  //NSLog(@"Twitpic receiveData.json: %@", jsonDictionary);

  NSString *tweet = [jsonDictionary objectForKey:@"text"];
  NSString *picUrl = [jsonDictionary objectForKey:@"url"];
  NSString *picId = [jsonDictionary objectForKey:@"id"];

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
  
  NSString *albumName = [self.appDelegate nowPlayingAlbumTitle];

  if (albumName != nil && ![albumName isEqualToString:@""]) {
    [self saveId:picId withAlbumName:albumName];
  }
}

/**
 * @brief 送信完了時に呼ばれるメソッド
 */
- (void)twitPicRequestFinished:(ASIHTTPRequest *)theRequest {

  NSLog(@"Twitpic Uploaded OK.");

  self.twitterClient = nil;
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


/**
 * @brief 送信失敗時に呼ばれるメソッド
 */
- (void)requestFailed:(ASIHTTPRequest *)theRequest {
  self.twitterClient = nil;
  NSString *resultText = [NSString stringWithFormat:@"Request failed:\r\n%@",
				   [[theRequest error] localizedDescription]];
  
  NSLog(@"Twitpic Upload Failure: %@", resultText);
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;


  id aDelegate = [[senderDelegate retain] autorelease];
  self.senderDelegate = nil;

  [twitterClient updateStatus:tweetString
		 inReplyToStatusId:nil
		 withArtwork:NO
		 delegate:aDelegate];
}

#pragma mark -
#pragma Picture Cache Methods

- (NSString *)getPictureIdWithAlbumName:(NSString *)albumName {

  NSString *path = [self filePath];

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    NSString *path = [self filePath];
    NSMutableDictionary *ids = [[NSMutableDictionary alloc] 
				 initWithContentsOfFile:path];
    NSString *picId = [ids objectForKey:albumName];
    NSLog(@"picId: %@", picId);
    return picId;
  } else {
    return nil;
  }
}

- (NSString *)getUrlWithAlbumName:(NSString *)albumName {

  NSString *picId = [self getPictureIdWithAlbumName:albumName];

  if (picId == nil) { return nil; }
  return [NSString stringWithFormat:kTwitpicBaseUrl, picId];
}

- (NSString *)getMediaUrlWithAlbumName:(NSString *)albumName {

  NSString *picId = [self getPictureIdWithAlbumName:albumName];

  if (picId == nil) { return nil; }
  return [NSString stringWithFormat:kTwitpicMediaUrl, picId];
}

- (void)saveId:(NSString *)picId withAlbumName:(NSString *)albumName {

  NSLog(@"save twitpic id to file: %@: %@", albumName, picId);

  NSMutableDictionary *ids = nil;
  NSString *path = [self filePath];

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    ids = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
  } else {
    ids = [[NSMutableDictionary alloc] init];
  }

  [ids setObject:picId forKey:albumName];
  [ids writeToFile:path atomically:YES];
  [ids release];
}

- (void)deleteUrlWithAlbumName:(NSString *)albumName {

  NSLog(@"delete twitpic_id from file: %@", albumName);

  NSMutableDictionary *ids = nil;
  NSString *path = [self filePath];

  if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
    ids = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    [ids removeObjectForKey:albumName];
    [ids writeToFile:path atomically:YES];
  }

  [ids release];
}

- (NSString *)filePath {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = 
    [documentsDirectory stringByAppendingPathComponent:kTwitPicIdsFileNmae];

  return filePath;
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end


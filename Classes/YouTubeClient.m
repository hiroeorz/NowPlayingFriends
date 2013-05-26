//
//  YouTubeClient.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/11/13.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import "YouTubeClient.h"


@interface YouTubeClient (Local)
- (void)startWithRequestString:(NSString *)urlString 
		     parameter:(NSString *)aParameter;
- (NSString *)shurinkedUrl:(NSString *)aUrl;
- (void)initialize;
@end

@implementation YouTubeClient

@synthesize delegate;
@synthesize name;
@synthesize contentTitle;
@synthesize linkUrl;
@synthesize searchResultArray;
@synthesize thumbnailUrl;
@synthesize contentUrl;
@synthesize viewCount;
@synthesize xmlData;
@synthesize action;
@synthesize seconds;


- (void)dealloc {
  
  [name release];
  [contentTitle release];
  [delegate release];
  [linkUrl release];
  [searchResultArray release];
  [viewCount release];
  [seconds release];
  [thumbnailUrl release];
  [contentUrl release];
  [xmlData release];
  [super dealloc];
}

/**
 * @brief 与えられたタイトルとアーティスト名からYouTubeApiで検索します。
 */
- (void)searchWithTitle:(NSString *)title artist:(NSString *)artist 
	       delegate:(id)aDelegate action:(SEL)aAction 
		  count: (NSInteger)count {

  [self initialize];
  self.delegate = aDelegate;
  self.action = aAction;

  NSString *parameter = [[[NSString alloc] initWithFormat:@"%@,%@",
					   title, artist] autorelease];
  NSString *url = [[[NSString alloc] initWithFormat:kYouTubeSearchURL, count] 
		    autorelease];

  [self startWithRequestString:url parameter:parameter];
}

/**
 * @brief 与えられたスペース区切り文字列をカンマ区切りにしてYouTubeApiで検索します。
 */
- (void)searchWithFreeParameters:(NSString *)params 
			delegate:(id)aDelegate action:(SEL)aAction 
			   count: (NSInteger)count {

  [self initialize];
  self.delegate = aDelegate;
  self.action = aAction;

  NSString *parameter = [params stringByReplacingOccurrencesOfString:@" "
							 withString:@","];
  NSString *url = [[[NSString alloc] initWithFormat:kYouTubeSearchURL, count] 
		    autorelease];
  [self startWithRequestString:url parameter:parameter];
}

#pragma mark -

- (void)startWithRequestString:(NSString *)urlString 
		     parameter:(NSString *)aParameter {
  
  self.xmlData = [NSMutableData data];
  
  NSString *replaced = 
    [aParameter stringByReplacingOccurrencesOfString:@" " withString:@","];

  CFStringRef ignoreString = CFSTR("';,/?:@&=+$#()");
  
  NSString *paramsString = 
    (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
							(CFStringRef)replaced,
							NULL,
							ignoreString,
							kCFStringEncodingUTF8);
  NSMutableString *bodyString = 
    [NSMutableString stringWithFormat:@"%@category=%@&v=2",
		     urlString, paramsString];

  [paramsString release];

  //NSLog(@"url: %@", bodyString);
  NSURLRequest *request = [NSURLRequest 
			    requestWithURL:[NSURL URLWithString:bodyString]];
  
  [self setValue:[NSNumber numberWithBool:NO] forKey:@"isFinished"]; 
  [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"]; 
  [NSURLConnection connectionWithRequest:request delegate:self];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

#pragma mark -
#pragma NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {

  [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
  [parser setDelegate:self];
  [parser parse];
  [parser release];
  
  self.xmlData = nil;

  [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"]; 
  [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];

  [delegate performSelector:action withObject:searchResultArray];
}

-(void)connection:(NSURLConnection*)connection 
 didFailWithError:(NSError*)error {

  NSLog(@"YouTube Connection Error");
  [delegate performSelector:action withObject:nil];
}

#pragma mark -
#pragma NSXMLParser Delegate Methods

/**
 * @brief XMLのエレメントを見つけるたびに呼ばれる。
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {

  //NSLog(@"elementName: %@", elementName);
  //NSLog(@"attribute dict: %@", attributeDict);

  if ([elementName compare:@"entry"] == NSOrderedSame) {
    isEntry = YES;
  }
  if ([elementName compare:@"link"] == NSOrderedSame) {
    isLink = YES;
  }
  if ([elementName compare:@"title"] == NSOrderedSame) {
    isTitle = YES;
  }
  if ([elementName compare:@"name"] == NSOrderedSame) {
    isName = YES;
  }
  if ([elementName compare:@"media:thumbnail"] == NSOrderedSame) {
    isThumbnail = YES;
  }
  if ([elementName compare:@"media:content"] == NSOrderedSame) {
    isContent = YES;
  }
  if ([elementName compare:@"yt:statistics"] == NSOrderedSame) {
    isViewCount = YES;
  }
  if ([elementName compare:@"yt:duration"] == NSOrderedSame) {
    isDuration = YES;
  }

  if (isEntry && isLink) {
    if ([(NSString *)[attributeDict objectForKey:@"rel"] 
	  compare:@"alternate"] == NSOrderedSame) {
      NSString *aUrl = (NSString *)[attributeDict objectForKey:@"href"];
      self.linkUrl = [self shurinkedUrl:aUrl];
    }
  }
  if (isEntry && isContent) {
    NSString *type = (NSString *)[attributeDict objectForKey:@"type"];
    if ([type isEqualToString: @"application/x-shockwave-flash"]) {
      self.contentUrl = (NSString *)[attributeDict objectForKey:@"url"];
      NSLog(@"contentUrl: %@", self.contentUrl);
    }
  }
  if (isEntry && isThumbnail) {
    NSString *aThumbnailUrl = (NSString *)[attributeDict objectForKey:@"url"];

    if ([aThumbnailUrl rangeOfString:@"/default.jpg"].location != NSNotFound) {
      self.thumbnailUrl = aThumbnailUrl;
    }
  }
  if (isEntry && isViewCount) {
    if ([attributeDict objectForKey:@"viewCount"] != nil) {
      self.viewCount = [attributeDict objectForKey:@"viewCount"];
    }
  }
  if (isEntry && isDuration) {
    if ([attributeDict objectForKey:@"seconds"] != nil) {
      self.seconds = [attributeDict objectForKey:@"seconds"];
    }
  }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

  if (isEntry && isTitle) {
    self.contentTitle = string;
  }
  if (isEntry && isName) {
    self.name = string;
  }

}

/**
 * @brief youtubeの短縮URLを生成する。
 */
- (NSString *)shurinkedUrl:(NSString *)aUrl {

  if (aUrl == nil) {
    return nil;
  }

  NSString *clearUrl = 
    [aUrl stringByReplacingOccurrencesOfString:@"&feature=youtube_gdata"
	     withString:@""];

  //NSLog(@"clearUrl: %@", clearUrl);
    
  NSString *shurinkedUrl = 
    [clearUrl 
      stringByReplacingOccurrencesOfString:@"http://www.youtube.com/watch?v="
      withString:@"http://youtu.be/"];

  //NSLog(@"shurinkedUrl: %@", shurinkedUrl);

  return shurinkedUrl;
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {

  if([elementName compare:@"entry"] == NSOrderedSame){
    isEntry = NO;

    if (contentTitle != nil && linkUrl != nil && thumbnailUrl != nil && contentUrl != nil) {

      NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
						  contentTitle, @"contentTitle",
						linkUrl, @"linkUrl",
						thumbnailUrl, @"thumbnailUrl",
						contentUrl, @"contentUrl",
						name, @"name",
						viewCount, @"viewCount",
						seconds, @"seconds",
						nil];
      [searchResultArray addObject: dic];
      NSLog(@"search Result: %@", dic);
      [dic release];

      self.contentTitle = nil;
      self.linkUrl = nil;
      self.thumbnailUrl = nil;
      self.contentUrl = nil;
      self.name = nil;
      self.viewCount = nil;
      self.seconds = nil;
    }
  }
  if([elementName compare:@"link"] == NSOrderedSame){
    isLink = NO;
  }
  if([elementName compare:@"media:content"] == NSOrderedSame){
    isContent = NO;
  }
  if([elementName compare:@"title"] == NSOrderedSame){
    isTitle = NO;
  }
  if([elementName compare:@"name"] == NSOrderedSame){
    isName = NO;
  }
  if([elementName compare:@"media:thumbnail"] == NSOrderedSame){
    isThumbnail = NO;
  }
  if([elementName compare:@"yt:statistics"] == NSOrderedSame){
    isViewCount = NO;
  }
  if([elementName compare:@"yt:duration"] == NSOrderedSame){
    isDuration = NO;
  }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
  NSLog(@"XML ParseError");
  [delegate performSelector:action withObject:nil];
}

#pragma mark -
#pragma Private Methods

- (void)initialize {
  self.delegate = nil;
  self.action = nil;
  self.contentTitle = nil;
  self.linkUrl = nil;
  self.thumbnailUrl = nil;
  self.contentUrl = nil;
  self.name = nil;
  self.seconds = nil;
  self.viewCount = nil;

  self.searchResultArray = [[NSMutableArray alloc] init];
}

@end

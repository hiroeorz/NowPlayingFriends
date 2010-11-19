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
@end

@implementation YouTubeClient

@synthesize delegate;
@synthesize linkUrl;
@synthesize xmlData;
@synthesize action;

- (void)dealloc {
  
  [delegate release];
  [linkUrl release];
  [xmlData release];
  [super dealloc];
}

- (void)searchWithTitle:(NSString *)title artist:(NSString *)artist 
	       delegate:(id)aDelegate action:(SEL)aAction{

  self.delegate = aDelegate;
  self.action = aAction;
  self.linkUrl = nil;
  NSString *parameter = [[NSString alloc] initWithFormat:@"%@,%@,Music",
					  artist, title];
  [self startWithRequestString:kYouTubeSearchURL parameter:parameter];
}

#pragma mark -

- (void)startWithRequestString:(NSString *)urlString 
		     parameter:(NSString *)aParameter {
  
  self.xmlData = [NSMutableData data];
  
  CFStringRef ignoreString = CFSTR(";,/?:@&=+$#");
  NSMutableString *bodyString = 
    [NSMutableString stringWithFormat:@"%@category=%@&v=2",
		     urlString,
		     (NSString *)CFURLCreateStringByAddingPercentEscapes(  
						       kCFAllocatorDefault,
						       (CFStringRef)aParameter,
						       NULL,
                                                       ignoreString,
                                                       kCFStringEncodingUTF8)];

  NSLog(@"url: %@", bodyString);
  NSURLRequest *request = [NSURLRequest 
			    requestWithURL:[NSURL URLWithString:bodyString]];
  
  [self setValue:[NSNumber numberWithBool:NO] forKey:@"isFinished"]; 
  [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"]; 
  [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {

  [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
  [parser setDelegate:self];
  [parser parse];
  [parser release];
  self.xmlData = nil;

  [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"]; 
  [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];

  [delegate performSelector:action withObject:linkUrl];
}

#pragma mark -
#pragma NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {

  if ([elementName compare:@"entry"] == NSOrderedSame) {
    isEntry = YES;
  }
  if ([elementName compare:@"link"] == NSOrderedSame) {
    isLink = YES;
  }

  if (isEntry && isLink) {
    if ([(NSString *)[attributeDict objectForKey:@"rel"] 
	  compare:@"alternate"] == NSOrderedSame) {
      self.linkUrl = (NSString *)[attributeDict objectForKey:@"href"];
    }
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {

  if([elementName compare:@"entry"] == NSOrderedSame){
    isEntry = NO;
  }
  if([elementName compare:@"link"] == NSOrderedSame){
    isLink = NO;
  }
}

@end

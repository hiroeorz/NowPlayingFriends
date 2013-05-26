//
//  ITunesStore.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/12/03.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import "ITunesStore.h"
#import "JSON/JSON.h"


@implementation ITunesStore

@synthesize urlData;
@synthesize resultDelegate;
@synthesize action;

- (void)dealloc {

  [urlData release];
  [resultDelegate release];
  [super dealloc];
}

- (void)searchLinkUrlWithTitle:(NSString *)title
			 album:(NSString *)album
			artist:(NSString *)artist
		      delegate:(id) aDelegate
			action:(SEL)aAction {

  self.resultDelegate = aDelegate;
  self.action = aAction;

  NSString *keyword1 = artist;
  NSString *keyword2 = nil;

  if (album == nil || [album length] == 0) {
    keyword2 = title;
  } else {
    keyword2 = album;
  }

  NSString *storeSearchUrl = [[NSString alloc] 
			      initWithFormat:kiTunesStoreSearchUrl, 
			      keyword1, keyword2];

  CFStringRef ignoreString = CFSTR("';,/?:@&=+$#()");
  NSString *paramsStr = 
    (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
							(CFStringRef)storeSearchUrl,
							NULL,
							ignoreString,
							kCFStringEncodingUTF8);
  NSMutableString *compressParam = 
    [NSMutableString stringWithFormat:@"longUrl=%@", paramsStr];
  [paramsStr release];
  [storeSearchUrl release];

  NSString *compressUrl = [[NSString alloc] initWithFormat:kBitlyUrl,
					    kBitlyUserName, 
					    kBitlyAPIKey,
					    compressParam];
  NSURLRequest *request = [NSURLRequest 
			    requestWithURL:[NSURL URLWithString:compressUrl]];

  [compressUrl release];

  self.urlData = [NSMutableData data];
  [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {

  [urlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

  NSString *jsonString = [[NSString alloc] initWithData:urlData
					   encoding:NSUTF8StringEncoding];
  NSLog(@"json: %@", jsonString);
  NSDictionary *jsonDictionary = [jsonString JSONValue];
  [jsonString release];

  if ([[jsonDictionary objectForKey:@"status_code"] integerValue] != 200) {
    self.urlData = nil;
    [resultDelegate performSelector:action withObject:nil];    
  }

  NSDictionary *responseData = [jsonDictionary objectForKey:@"data"];
  NSString *compressedUrl = [responseData objectForKey:@"url"];

  NSLog(@"Bitly Search Result: %@", compressedUrl);
  [resultDelegate performSelector:action withObject:compressedUrl];
  self.urlData = nil;
}

-(void)connection:(NSURLConnection*)connection 
 didFailWithError:(NSError*)error {

  NSLog(@"TinyUrl Connection Error");
  [resultDelegate performSelector:action withObject:nil];
}

@end

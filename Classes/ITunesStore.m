//
//  ITunesStore.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/12/03.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import "ITunesStore.h"


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
			artist:(NSString *)artist
		      delegate:(id) aDelegate
			action:(SEL)aAction {

  self.resultDelegate = aDelegate;
  self.action = aAction;
  NSString *query = [[NSString alloc] initWithFormat:@"%@ %@", 
				      title, artist];

  CFStringRef ignoreString = CFSTR(";,/?:@&=+$#");
  NSMutableString *storeSearchUrl = 
    [NSMutableString stringWithFormat:kiTunesStoreSearchUrl,
		     (NSString *)CFURLCreateStringByAddingPercentEscapes(  
						       kCFAllocatorDefault,
						       (CFStringRef)query,
						       NULL,
                                                       ignoreString,
                                                       kCFStringEncodingUTF8)];

  NSString *compressUrl = [[NSString alloc] 
			    initWithFormat:kTinyUrl, storeSearchUrl];


  NSURLRequest *request = [NSURLRequest 
			    requestWithURL:[NSURL URLWithString:compressUrl]];

  [compressUrl release];
  [query release];

  NSLog(@"url: %@", compressUrl);
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
  NSString *compressedUrl = [[NSString alloc] initWithData:urlData
					      encoding:NSUTF8StringEncoding];

  NSLog(@"TinyURL Search Result: %@", compressedUrl);
  [resultDelegate performSelector:action 
		  withObject:[compressedUrl autorelease]];
  self.urlData = nil;
}

-(void)connection:(NSURLConnection*)connection 
 didFailWithError:(NSError*)error {

  NSLog(@"TinyUrl Connection Error");
  [resultDelegate performSelector:action withObject:nil];
}

@end

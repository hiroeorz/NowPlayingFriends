//
//  YouTubeClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/11/13.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


#define kYouTubeSearchURL @"http://gdata.youtube.com/feeds/api/videos?max-results=1&"

@interface YouTubeClient : NSOperation <NSXMLParserDelegate>{

  NSMutableData *xmlData;
  BOOL isEntry;
  BOOL isLink;
  NSString *linkUrl;
  id delegate;
  SEL action;

  NSURLRequest *_request;
  NSURLConnection *_connection;
  BOOL _isExecuting, _isFinished;
}

@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSString *linkUrl;
@property (nonatomic, retain) id delegate;
@property (nonatomic) SEL action;

- (void)searchWithTitle:(NSString *)title artist:(NSString *)artist
	       delegate:(id)aDelegate action:(SEL)aAction;
@end

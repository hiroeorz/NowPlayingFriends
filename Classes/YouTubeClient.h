//
//  YouTubeClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/11/13.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kYouTubeSearchURL @"http://gdata.youtube.com/feeds/api/videos?max-results=%d&orderby=relevance&"

@interface YouTubeClient : NSOperation <NSXMLParserDelegate>{

  BOOL isEntry;
  BOOL isLink;
  BOOL isThumbnail;
  BOOL isTitle;
  NSMutableData *xmlData;
  NSString *contentTitle;
  NSString *linkUrl;
  NSString *thumbnailUrl;
  SEL action;
  id delegate;
  NSMutableArray *searchResultArray;

  NSURLRequest *_request;
  NSURLConnection *_connection;
  BOOL _isExecuting, _isFinished;
}

@property (nonatomic) SEL action;
@property (nonatomic, retain) NSMutableArray *searchResultArray;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSString *contentTitle;
@property (nonatomic, retain) NSString *linkUrl;
@property (nonatomic, retain) NSString *thumbnailUrl;
@property (nonatomic, retain) id delegate;


- (void)searchWithTitle:(NSString *)title artist:(NSString *)artist
	       delegate:(id)aDelegate action:(SEL)aAction
		  count: (NSInteger)count;
@end

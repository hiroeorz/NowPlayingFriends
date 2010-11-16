//
//  YouTubeClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/11/13.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxml/tree.h>


#define kYouTubeSearchURL @"http://gdata.youtube.com/feeds/api/videos?"

@interface YouTubeClient : NSOperation {

  NSURLRequest *_request;
  NSURLConnection *_connection;
  xmlParserCtxtPtr _parserContext;
  BOOL _isExecuting, _isFinished;

  BOOL _isChannel, _isItem;
  BOOL _isEntry, _isID, _isLink;
  NSMutableDictionary *_link;
  NSMutableDictionary *_channel;
  NSMutableDictionary *_currentItem;
  NSMutableString *_currentCharacters;
}

- (void)searchWithTitle:(NSString *)title artist:(NSString *)artist;
- (void)charactersFoundCharacter:(const xmlChar*)ch len:(int)len;
- (void)startElementLocalName:(const xmlChar*)localname 
		       prefix:(const xmlChar*)prefix 
			  URI:(const xmlChar*)URI 
		nb_namespaces:(int)nb_namespaces
		   namespaces:(const xmlChar**)namespaces 
		nb_attributes:(int)nb_attributes 
		 nb_defaulted:(int)nb_defaulted 
		   attributes:(const xmlChar**)attributes;

- (void)endElementLocalName:(const xmlChar*)localname 
		     prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI;

@end

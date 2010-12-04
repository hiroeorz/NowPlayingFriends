//
//  ITunesStore.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/12/03.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bitly+APIKey.h"


#define kiTunesStoreSearchUrl @"http://ax.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?term=%@ %@"
#define kTinyUrl @"http://tinyurl.com/api-create.php?url=%@"
#define kBitlyUrl @"http://api.bit.ly/v3/shorten?login=%@&apiKey=%@&format=json&%@"

@interface ITunesStore : NSOperation <NSXMLParserDelegate> {

  NSMutableData *urlData;
  id resultDelegate;
  SEL action;
}

@property (nonatomic, retain) NSData *urlData;
@property (nonatomic, retain) id resultDelegate;
@property (nonatomic) SEL action;

- (void)searchLinkUrlWithTitle:(NSString *)title
			 album:(NSString *)album
			artist:(NSString *)artist
		      delegate:(id) aDelegate
			action:(SEL)aAction;

@end

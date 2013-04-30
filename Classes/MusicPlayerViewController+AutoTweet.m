#import "MusicPlayerViewController.h"
#import "MusicPlayerViewController+Local.h"

#import "FacebookClient.h"


@implementation MusicPlayerViewController (AutoTweet)

#pragma mark -
#pragma mark Timeline Refresh Methods

/**
 * @brief 自動ツイート処理が複数平行して走らない為の処置。
 */
- (void)continuousTweetStopper {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSDate *date = [[NSDate alloc] init];
  NSDate *nextStartDate = 
    [[NSDate alloc] initWithTimeInterval:kUpdateAfterSafetyTime
		    sinceDate:date];
  
  [NSThread sleepUntilDate: nextStartDate];
  [date release];
  [nextStartDate release];

  updateAfterSafetyTime = NO;

  [pool release];
}

/**
 * @brief 一定時間、再生曲が変わらなかったら自動ツイートする。
 */
- (void)sendAutoTweetAfterTimeLag {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
  NSInteger second = kAutoTweetTimeLag;

  NSString *title = [self.appDelegate nowPlayingTitle];
  [self.appDelegate sleep:second];

  NSString *nowSongTitle = [self.appDelegate nowPlayingTitle];

  if (autoTweetMode && [nowSongTitle isEqualToString:title]) {
    [self performSelectorOnMainThread:@selector(sendAutoTweet)
	  withObject:nil
	  waitUntilDone:YES];
  }

  [pool release];
}

/**
 * @brief 自動ツイートを実行する。
 */
- (void)sendAutoTweet {

  if (sent) {return;}

  if (updateAfterSafetyTime) {
    NSLog(@"Canceled auto tweet because after tweeting safety time.");
    return;
  }

  updateAfterSafetyTime = YES;
  youtubeSearchResultForAutoTweet = nil;
  [self performSelectorInBackground:@selector(continuousTweetStopper)
	withObject:nil];

  NSMutableArray *newAddLinkArray = [[NSMutableArray alloc] init];
  self.addLinkArray = newAddLinkArray;
  [newAddLinkArray release];

  if ([self.appDelegate use_itunes_preference]) {

    ITunesStore *store = [[[ITunesStore alloc] init] autorelease];
    [store searchLinkUrlWithTitle:[self.appDelegate nowPlayingTitle] 
	   album:[self.appDelegate nowPlayingAlbumTitle]
	   artist:[self.appDelegate nowPlayingArtistName]
	   delegate:self 
	   action:@selector(createMessageIncludeITunes:)];
    return;

  } else if ([self.appDelegate use_youtube_preference]) {
    YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
    
    [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	     artist:[self.appDelegate nowPlayingArtistName]
	     delegate:self
	     action:@selector(createMessageIncludeYouTube:)
	     count:1];
    return;

  } else {
    NSString *message = [self.appDelegate tweetString];
    [self sendAutoTweetDetail:message];
  }
}

- (NSString *)tweetString:(NSString *)aTweetString
	   withLinksArray:(NSArray *)aLinksArray {

  if (aLinksArray == nil || [aLinksArray count] == 0) { return aTweetString; }

  NSString *newString = nil;
  NSString *resultString = [[[NSString alloc] initWithString:aTweetString]
			    autorelease];

  for (NSString *aLink in aLinksArray) {
    NSString *addedString = [[NSString alloc] 
			      initWithFormat:@"%@ %@", resultString, aLink];
    newString = [[NSString alloc] initWithString:addedString];
    [addedString release];

    if ([newString length] > kMaxTweetLength) {
      [newString release];
      continue;
    }
    
    resultString = [[[NSString alloc] initWithString:newString] autorelease];
    [newString release];
  }

  return resultString;
}

/**
 * @brief 受け取ったYouTubeリンクをメッセージに埋込む。YouTubeクライアントから呼ばれる。
 */
- (void)createMessageIncludeYouTube:(NSArray *)linkUrlArray {

  NSString *message = [self tweetString:[self.appDelegate tweetString]
			    withLinksArray:addLinkArray];
  NSString *linkedMessage = nil;
  
  if (linkUrlArray == nil || [linkUrlArray count] == 0) {
    linkedMessage = message;
  } else {
    NSDictionary *linkDic = [linkUrlArray objectAtIndex:0];
    NSString *linkUrl = [linkDic objectForKey: @"linkUrl"];

    linkedMessage = [[[NSString alloc] 
		       initWithFormat:@"%@ %@", message, linkUrl] autorelease];
    if ([linkedMessage length] > kMaxTweetLength) {linkedMessage = message;}

    [linkDic retain]; [youtubeSearchResultForAutoTweet release];
    youtubeSearchResultForAutoTweet = linkDic;
  }
  
  [self sendAutoTweetDetail: linkedMessage];
}

/**
 * @brief 受け取ったiTunes検索リンクをメッセージに埋込む。
          YouTubeクライアントから呼ばれる。
 */
- (void)createMessageIncludeITunes:(NSString *)linkUrl {

  if (linkUrl != nil) { [addLinkArray addObject:linkUrl]; }

  if ([self.appDelegate use_youtube_preference]) { /* call youtube if YES */
    YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
    
    [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	     artist:[self.appDelegate nowPlayingArtistName]
	     delegate:self
	     action:@selector(createMessageIncludeYouTube:)
	     count:1];
    return;
  }

  NSString *message = [self.appDelegate tweetString];
  NSString *linkedMessage = nil;

  if (linkUrl == nil) {
    linkedMessage = message;
  } else {
    linkedMessage = [[[NSString alloc] 
		       initWithFormat:@"%@ iTunes: %@", message, linkUrl] 
		      autorelease];
    if ([linkedMessage length] > kMaxTweetLength) {linkedMessage = message;}
  }

  [self sendAutoTweetDetail: linkedMessage];
}

/**
 * @brief 引数で受け取ったメッセージを送信する。
 */
- (void)sendAutoTweetDetail:(NSString *)message {

  if ([message length] >= kMaxTweetLength) {/* それでも長かったら切り捨て */
    message = [message substringToIndex:kMaxTweetLength];
  }

  if (self.appDelegate.tw_post_preference == YES) {
    [twitterClient updateStatus:message inReplyToStatusId:nil
		    withArtwork:[self.appDelegate auto_upload_picture_preference]
		       delegate:self];
  }

  if (self.appDelegate.fb_post_preference == YES) {
      FacebookClient *facebookClient = [[[FacebookClient alloc] init ] autorelease];

      if (youtubeSearchResultForAutoTweet != nil) { /* YouTube埋込み */
	facebookClient.youtubeSearchResult = youtubeSearchResultForAutoTweet;
      }
      if (self.appDelegate.auto_upload_picture_preference == YES) { /* アルバム画像アップロード */
	facebookClient.pictureImage = [self.appDelegate 
					  currentMusicArtWorkWithWidth:kFBPictureSizeHeight
					  height:kFBPictureSizeWidth
					  useDefault:NO];
      }

      [facebookClient postMessage:message callback:^{
	  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	  NSLog(@"facebook post sended.");
	}];  
  }

  sending = NO;
  sent = YES;
}

@end

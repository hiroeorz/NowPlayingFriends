#import "MusicPlayerViewController+Local.h"


@implementation MusicPlayerViewController (FriendsIcon)

-(void)refreshProfileImagesIfChanged {

  if (![recentSongTitle isEqualToString:[self.appDelegate nowPlayingTitle]]) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
			   withObject:nil];
  } else {
    NSLog(@"skip refresh icons because same song...");
  }
}

- (void)refreshProfileImages {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  cancelFlag = YES;
  NSLog(@"waiting for mutex...");
  
  @synchronized(refreshProfileImagesMutex) {
    
    @try {
      if (self.appDelegate.get_twitterusers_preference == YES) {
	if (![twitterClient oAuthTokenExist]) {
	  NSLog(@"oAuth Token is not exist. refresh not executed.");
	  return;
	}
	
	cancelFlag = NO;
	updatingFlag = YES;
	NSLog(@"starting refresh timeline");
	
	self.beforeTimeline = timeline;
	
	if ([self refreshTimeline]) {
	  if (cancelFlag) {
	    [self releaseNowButtons];
	    [self releaseProfileImageButtons];
	  }
	  [self setFriendImageView];
	}
	
      }
    }
    @finally {
      updatingFlag = NO;      
    }
  }

  [pool release];
}

- (BOOL)refreshTimeline {

  NSLog(@"updating timeline data...");
  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];
  NSString *tags = [self.appDelegate nowPlayingTagsString];
  NSArray *newTimeline = nil;
  
  NSLog(@"INDEX: %d", refreshTypeSegmentedControl.selectedSegmentIndex);

  if (cancelFlag) { NSLog(@"Stopping refresh timeline because cacelFlag=YES");
    [client release];
    return NO;
  }

  switch (refreshTypeSegmentedControl.selectedSegmentIndex) {
  case kRefreshTypeSong:
    newTimeline = [client getSearchTimeLine: songTitle, artistName, tags, nil];
    break;
  case kRefreshTypeArtist:
    newTimeline = [client getSearchTimeLine: artistName, tags, nil];
    break;
  case kRefreshTypeAll:
    newTimeline = [client getSearchTimeLine: tags, nil];
    break;
  }

  NSMutableArray *uniqArray = [[NSMutableArray alloc] init];
  NSMutableArray *checkArray = [[NSMutableArray alloc] init];

  for (NSDictionary *data in newTimeline) {
    NSString *username = [self.appDelegate username:data];

    if ([checkArray indexOfObject:username] == NSNotFound) {
      [uniqArray addObject:data];
      [checkArray addObject:username];
    }
  }

  BOOL changed = [self checkTimelineUpdated:uniqArray];
  self.timeline = uniqArray;

  [client release];
  [uniqArray release];
  [checkArray release];

  NSLog(@"timeline data updated.");
  return changed;
}

- (BOOL)checkTimelineUpdated:(NSArray *)newArray {

  if ([newArray count] != [timeline count]) { return YES; }

  BOOL changed = NO;
  NSInteger i = 0;

  for(NSDictionary *newItem in newArray) {
    NSDictionary *oldItem = [timeline objectAtIndex:i];
    NSString *oldName = [self.appDelegate username:oldItem];
    NSString *newName = [self.appDelegate username:newItem];

    if (![oldName isEqualToString:newName]) {
      changed = YES; break;
    }

    i++;
  }

  return changed;
}

/**
 * @brief nowButtonをプロフィール画像ボタンから外してリリースする。
 */
- (void)releaseNowButtons {

  for (UIButton *nowButton in nowButtons) {
    if (nowButton.superview != nil) { [nowButton removeFromSuperview]; }
  }

  [nowButtons release];
  nowButtons = [[NSMutableArray alloc] init];
  animationOperator.buttonAndLines = [NSMutableArray array];
}

- (void)releaseProfileImageButtons {

  for (UIButton *profileButton in profileImageButtons) {
    if (profileButton.superview != nil) { [profileButton removeFromSuperview]; }
  }
}

- (void)setFriendImageView {

  [self releaseNowButtons];
  NSInteger i = 0;
  NSInteger x = 0;
  NSInteger xRange = kProfileImageSize;
  NSInteger y = albumImageView.frame.size.height - xRange + 32.0f;
  
  for (NSDictionary *data in timeline)  {
    if (cancelFlag || timeline == beforeTimeline) { break; }

    UIButton *profileImageButton = nil;
    BOOL newButtonFlag = NO;
    
    if ([profileImageButtons count] >= (i + 1)) {
      newButtonFlag = NO;
      profileImageButton = [profileImageButtons objectAtIndex:i];
    }
    
    if (profileImageButton == nil) {
      newButtonFlag = YES;
      profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];

      [profileImageButton addTarget:self 
			  action:@selector(openUserInformationView:)
			  forControlEvents:UIControlEventTouchUpInside];
    }

    profileImageButton.tag = i;

    profileImageButton.frame = CGRectMake(x, y, 
					  kProfileImageSize, 
					  kProfileImageSize);
    
    UIImage *newImage = [self.appDelegate profileImage:data
			     getRemote:YES];

    BOOL nowPlayer = [self checkNowPlayingUser:data];
    float alpha = kProfileImageButtonAlpha;
      
    if (nowPlayer) { alpha = 1.0f; }

    NSNumber *alphaNumber = [NSNumber numberWithFloat:alpha];
    
    NSDictionary *objects = 
      [[NSDictionary alloc] initWithObjectsAndKeys:
			      profileImageButton, @"profileImageButton",
			    newImage, @"newImage", 
			    alphaNumber, @"alpha",
			    nil];
    
    if (newButtonFlag == YES) {
      
      [profileImageButtons addObject:profileImageButton];

      [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	    withObject:objects
	    waitUntilDone:YES];

    }else if (newButtonFlag == NO && profileImageButton.superview == nil) {

      [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	    withObject:objects
	    waitUntilDone:YES];

    } else {

      [self performSelectorOnMainThread:@selector(setBackgroundImage:)
	    withObject:objects
	    waitUntilDone:NO];
    }

    [self performSelectorOnMainThread:@selector(setBackgroundApha:)
	  withObject:objects
	  waitUntilDone:NO];

    if (nowPlayer) {
      [self performSelectorOnMainThread:@selector(addNowButton:)
	    withObject:objects
	    waitUntilDone:NO];
    }

    x = x + xRange;
    
    if (((i + 1) % 5) == 0) {
      y = y - kProfileImageSize;
      x = 0;
    }
    i++;

    [objects release];
  }
  
  if ([timeline count] < [profileImageButtons count]) {
    for (int x = i; x < [profileImageButtons count]; x++) {
      UIButton *profileImageButton = [profileImageButtons objectAtIndex:x];
      [profileImageButton removeFromSuperview];
    }
  }
}

- (void)addProfileImageButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [self.songView addSubview:profileImageButton];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
}

- (void)setBackgroundImage:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];
  
  [self.appDelegate setAnimationWithView:profileImageButton
			   animationType:UIViewAnimationTransitionFlipFromLeft];
  
  [profileImageButton setBackgroundImage:newImage 
				forState:UIControlStateNormal];
  
  [UIView commitAnimations];
}

- (void)setBackgroundApha:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  float alpha = [[objects objectForKey:@"alpha"] floatValue];
  profileImageButton.alpha = alpha;
}

- (void)addNowButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIButton *nowButton = [self nowButton:@selector(openUserInformationView:) 
				   frame:kNowButtonFrame];

  nowButton.tag = profileImageButton.tag;
  [self addGraphViewToNowButton:nowButton];

  [profileImageButton addSubview:nowButton];
  [nowButtons addObject:nowButton];
}

/**
 * @brief Nowボタンに疑似チューナーの棒グラフを追加する。
 */
- (void)addGraphViewToNowButton:(UIButton *)nowButton {
  
  NSDictionary *dic = [self dictionaryOfGraphLinesWithButton:nowButton];
  [animationOperator.buttonAndLines addObject:dic];
}

- (NSDictionary *)dictionaryOfGraphLinesWithButton:(UIButton *)nowButton {

  UIView *graphLine = nil;
  NSInteger i = 0;
  CGFloat x = 7.5f;
  CGFloat y = 9.0f;
  CGFloat width = 3.5f;
  CGFloat height = 10.0f;
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:4];

  while(i < 3) {
    graphLine = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    graphLine.backgroundColor = [UIColor whiteColor];
    [nowButton addSubview:graphLine];
    [array addObject:graphLine];
    [graphLine autorelease];
    x = x + width + 2.0f;
    i++;
  }
  
  NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
				      nowButton, @"button",
				    array, @"graphLineArray", nil];
  return dic;
}

@end

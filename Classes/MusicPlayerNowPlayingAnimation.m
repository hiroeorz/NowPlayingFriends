//
//  MusicPlayerNowPlayingAnimation.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/11/06.
//  Copyright (c) 2011年 hiroe_orz17. All rights reserved.
//

#import "MusicPlayerNowPlayingAnimation.h"

#import "MusicPlayerViewController.h"
#import "NowPlayingFriendsAppDelegate.h"


#define kNowPlayingAnimationSleepInterval 0.1


@interface MusicPlayerNowPlayingAnimation (Local)
- (void)setAnimationCutToButton:(UIButton *)button;
- (void)setupAnimationPartsList;
- (void)execMusicStopAnimation:(NSDictionary *)dic;
@end

@implementation MusicPlayerNowPlayingAnimation

@dynamic buttonAndLines;
@synthesize isRunning;
@synthesize viewController;
@synthesize sampleNowButtonDic;

- (void)dealloc {

  [buttonAndLines release];
  [sampleNowButtonDic release];
  [viewController release];
  [super dealloc];
}

- (id)init {
  self = [super init];

  if (self != nil) {
    buttonAndLines = [[NSMutableArray alloc] init];
    viewController = nil;
    isRunning = NO;
    sampleNowButtonDic = nil;
    stateIsPlay = NO;
  }

  return self;
}

#pragma mark -
#pragma Getter and Setter Methods

- (NSMutableArray *)buttonAndLines {
  return buttonAndLines;
}

- (void)setButtonAndLines:(NSMutableArray *)newArray {

  @synchronized(buttonAndLines) {
    [newArray retain];
    [buttonAndLines release];
    buttonAndLines = newArray;
  }
}

#pragma mark -
#pragma Notification Methods

- (void)handle_NowPlayingItemChanged:(id)notification {
}

- (void)handle_VolumeChanged:(id)notification {
}

- (void)handle_PlayBackStateDidChanged:(id)notification {

  NowPlayingFriendsAppDelegate *appDelegate = 
    [[UIApplication sharedApplication] delegate];

  MPMusicPlayerController *musicPlayer = appDelegate.musicPlayer;

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    NSLog(@"MusicPlayNowPlayingAnimation: State Changed:Play");
    stateIsPlay = YES;
  } else {
    NSLog(@"MusicPlayNowPlayingAnimation: State Changed:Stop or Pause");
    [self execMusicStopAnimation:sampleNowButtonDic];
    stateIsPlay = NO;
  }
}

#pragma mark -
#pragma Public Methods

/**
 * @brief アニメーションを開始する。最初に一度だけ呼ばれる
 */
- (void)startAnimation {
  
  NSAutoreleasePool *outPool = [[NSAutoreleasePool alloc] init];
  isRunning = YES;

  while (YES) {
    NSAutoreleasePool *inPool = [[NSAutoreleasePool alloc] init];
    [self performSelectorOnMainThread:@selector(execAnimation)
			   withObject:nil waitUntilDone:YES];
    [NSThread sleepForTimeInterval:kNowPlayingAnimationSleepInterval];
    [inPool release];
  }

  [outPool release];
}

#pragma mark -
#pragma LocalMethods

/**
 * @brief 全Nowボタンで一コマ分アニメーションをすすめる
 */
- (void)execAnimation {

  @try {
    @synchronized(buttonAndLines) {
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:0.2];

      for (NSDictionary *dic in buttonAndLines) {
	[self setAnimationCutToButton:dic];
      }
      if (stateIsPlay) { [self setAnimationCutToButton:sampleNowButtonDic]; }
      
      [UIView commitAnimations];
    }
  }
  @catch(...) {
    NSLog(@"Error: In Now Button GraphLine");
    [UIView commitAnimations];
  }
}

/**
 * @brief ひとつ前の状態から次の状態へ１コマ分変化するチューナーアニメーション
 */
- (void)setAnimationCutToButton:(NSDictionary *)dic {

  UIButton *aButton = [dic objectForKey:@"button"];
  NSArray *graphLineArray = [dic objectForKey:@"graphLineArray"];
  CGFloat fullHeight = 10.0f;
  CGFloat fullY = 9.0f;

  for(UIView *line in graphLineArray) {
    [line removeFromSuperview];
    CGRect frame = line.frame;
    NSInteger randVal = arc4random() % 10;
    frame.size.height = fullHeight - (CGFloat)randVal;
    frame.size.width = 3.5f;
    frame.origin.y = fullY  + (CGFloat)randVal;
    frame.origin.x = line.frame.origin.x;
    line.frame = frame;
    [aButton addSubview:line];
  }
}

/**
 * @brief チューナーアニメーションをゆっくりと停止する
 */
- (void)execMusicStopAnimation:(NSDictionary *)dic {

  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:1.0];

  @try {
    UIButton *aButton = [dic objectForKey:@"button"];
    NSArray *graphLineArray = [dic objectForKey:@"graphLineArray"];
    CGFloat fullHeight = 10.0f;
    CGFloat fullY = 9.0f;
    
    for(UIView *line in graphLineArray) {
      [line removeFromSuperview];
      CGRect frame = line.frame;
      frame.size.height = 1.0f;
      frame.size.width = 3.5f;
      frame.origin.y = fullY + (fullHeight - 1.0f);
      frame.origin.x = line.frame.origin.x;
      line.frame = frame;
      [aButton addSubview:line];
    }
    [UIView commitAnimations];
  }
  @catch(...){
    [UIView commitAnimations];
  }
}

@end

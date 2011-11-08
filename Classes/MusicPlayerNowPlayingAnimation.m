//
//  MusicPlayerNowPlayingAnimation.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/11/06.
//  Copyright (c) 2011年 hiroe_orz17. All rights reserved.
//

#import "MusicPlayerNowPlayingAnimation.h"

#import "MusicPlayerViewController.h"


#define kNowPlayingAnimationSleepInterval 0.1


@interface MusicPlayerNowPlayingAnimation (Local)
- (void)setAnimationCutToButton:(UIButton *)button;
- (void)setupAnimationPartsList;
@end

@implementation MusicPlayerNowPlayingAnimation

@dynamic buttonAndLines;
@synthesize isRunning;
@synthesize viewController;

- (void)dealloc {

  [buttonAndLines release];
  [viewController release];
  [super dealloc];
}

- (id)init {
  self = [super init];

  if (self != nil) {
    buttonAndLines = [[NSMutableArray alloc] init];
    viewController = nil;
    isRunning = NO;
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
#pragma Public Methods

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

- (void)execAnimation {

  if ([buttonAndLines count] == 0) { return; }

  @try {
    @synchronized(buttonAndLines) {
      [UIView beginAnimations:nil context:NULL];
      [UIView setAnimationDuration:0.2];
      
      for (NSDictionary *dic in buttonAndLines) {
	[self setAnimationCutToButton:dic];
      }
      
      [UIView commitAnimations];
    }
    }
  @catch(...) {
    NSLog(@"Error: In Now Button GraphLine");
    [UIView commitAnimations];
  }
}

- (void)setAnimationCutToButton:(NSDictionary *)dic {

  UIButton *aButton = [dic objectForKey:@"button"];
  NSArray *graphLineArray = [dic objectForKey:@"graphLineArray"];
  CGFloat fullHeight = 10.0f;
  CGFloat fullY = 9.0f;

  for(UIView *line in graphLineArray) {
    [line retain];
    [line removeFromSuperview];
    CGRect frame = line.frame;
    NSInteger randVal = arc4random() % 10;
    frame.size.height = fullHeight - (CGFloat)randVal;
    frame.size.width = 3.5f;
    frame.origin.y = fullY + fullHeight - (fullHeight - (CGFloat)randVal);
    frame.origin.x = line.frame.origin.x;
    line.frame = frame;
    [aButton addSubview:[line autorelease]];
  }
}

@end

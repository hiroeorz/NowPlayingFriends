//
//  MusicPlayerNowPlayingAnimation.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/11/06.
//  Copyright (c) 2011年 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MusicPlayerViewController;


@interface MusicPlayerNowPlayingAnimation : NSOperation {
@private
  MusicPlayerViewController *viewController;
  NSMutableArray *buttonAndLines;
  BOOL isRunning;
}

@property (nonatomic) BOOL isRunning;
@property (nonatomic, retain) MusicPlayerViewController *viewController;
@property (nonatomic, retain) NSMutableArray *buttonAndLines;

- (void)startAnimation;

@end


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
  BOOL isRunning;
  BOOL stateIsPlay;
  MusicPlayerViewController *viewController;
  NSDictionary *sampleNowButtonDic;
  NSMutableArray *buttonAndLines;
}

@property (nonatomic) BOOL isRunning;
@property (nonatomic, retain) MusicPlayerViewController *viewController;
@property (nonatomic, retain) NSDictionary *sampleNowButtonDic;
@property (nonatomic, retain) NSMutableArray *buttonAndLines;

- (void)handle_NowPlayingItemChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)startAnimation;

@end


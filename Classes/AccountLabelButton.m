//
//  AccountLabelButton.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/11/04.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import "AccountLabelButton.h"


@implementation AccountLabelButton

@synthesize data;

- (void)dealloc {
  
  [data release];
  [super dealloc];
}

@end

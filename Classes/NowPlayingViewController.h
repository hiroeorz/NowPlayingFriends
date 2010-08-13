//
//  NowPlayingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTimelineTableRowHeight 90


@interface NowPlayingViewController : UITableViewController {
  NSArray *timeline;
}

@property (nonatomic, retain) NSArray *timeline;

@end

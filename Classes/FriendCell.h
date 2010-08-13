//
//  FriendCell.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendCell : UITableViewCell {

  UIImageView *userImageView;
  UILabel *accountLabel;
  UILabel *clientLabel;
  UILabel *timeLabel;
  UITextView *bodyTextView;
}

@property (nonatomic, retain) IBOutlet UIImageView *userImageView;
@property (nonatomic, retain) IBOutlet UILabel *accountLabel;
@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UITextView *bodyTextView;

@end

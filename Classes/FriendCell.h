//
//  FriendCell.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendCell : UITableViewCell {

  UIButton *userImageView;
  UILabel *accountLabel;
  UILabel *clientLabel;
  UILabel *timeLabel;
  UILabel *bodyTextView;
  UIView *baseView;
}

@property (nonatomic, retain) IBOutlet UIButton *userImageView;
@property (nonatomic, retain) IBOutlet UILabel *accountLabel;
@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *bodyTextView;
@property (nonatomic, retain) IBOutlet  UIView *baseView;

@end

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
  UIButton *accountLabel;
  UILabel *clientLabel;
  UILabel *timeLabel;
  UILabel *bodyTextView;
  UIView *baseView;
  NSString *username;
}

@property (nonatomic, retain) IBOutlet UIButton *userImageView;
@property (nonatomic, retain) IBOutlet UIButton *accountLabel;
@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *bodyTextView;
@property (nonatomic, retain) IBOutlet UIView *baseView;
@property (nonatomic, retain) NSString *username;

@end

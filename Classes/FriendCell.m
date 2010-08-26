//
//  FriendCell.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FriendCell.h"


@implementation FriendCell

@synthesize userImageView;
@synthesize accountLabel;
@synthesize clientLabel;
@synthesize timeLabel;
@synthesize bodyTextView;
@synthesize baseView;

- (void)dealloc {

  [userImageView release];
  [accountLabel release];
  [clientLabel release];
  [timeLabel release];
  [bodyTextView release];
  [baseView release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier {

  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
  }
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

  [super setSelected:selected animated:animated];
}

@end

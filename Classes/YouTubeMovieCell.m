//
//  YouTubeMovieCell.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "YouTubeMovieCell.h"


@implementation YouTubeMovieCell

@synthesize titleLabel;

- (void)dealloc {
  
  [titleLabel release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier {
    
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
  }
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
  [super setSelected:selected animated:animated];
}

@end

//
//  FriendCell.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FriendCell : UITableViewCell {

  NSString *imageURLString;
  NSString *username;
  UIButton *accountLabel;
  UIButton *linkButton;
  UIButton *userImageView;
  UIButton *youTubeLinkButton;
  UILabel *bodyTextView;
  UILabel *clientLabel;
  UILabel *timeLabel;
  UIView *baseView;
}

@property (nonatomic, retain) IBOutlet UIButton *accountLabel;
@property (nonatomic, retain) IBOutlet UIButton *linkButton;
@property (nonatomic, retain) IBOutlet UIButton *userImageView;
@property (nonatomic, retain) IBOutlet UIButton *youTubeLinkButton;
@property (nonatomic, retain) IBOutlet UILabel *bodyTextView;
@property (nonatomic, retain) IBOutlet UILabel *clientLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIView *baseView;
@property (nonatomic, retain) NSString *imageURLString;
@property (nonatomic, retain) NSString *username;


- (void) getProfileImageWithTweetData:(NSDictionary *)tData;

- (BOOL)urlIsIncluded;
- (BOOL)hasYouTubeUrl;
- (NSArray *)arrayOfUrl;
- (void)openLink:(id)sender;

@end

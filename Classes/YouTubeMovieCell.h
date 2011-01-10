//
//  YouTubeMovieCell.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NowPlayingFriendsAppDelegate;


@interface YouTubeMovieCell : UITableViewCell {

  NSString *imageUrl;
  NSString *linkUrl;
  NSMutableData *responseData;
  NSURLConnection *connection;
  NSURLResponse *response;
  UIImageView *thumbnailImageView;
  UILabel *nameLabel;
  UILabel *playCountLabel;
  UILabel *timeLabel;
  UILabel *titleLabel;
}

@property (nonatomic, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *playCountLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) NSString *linkUrl;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLResponse *response;


- (void)loadMovieImage:(NSString *)aUrl;
- (IBAction)openMovie:(id)sender;

@end

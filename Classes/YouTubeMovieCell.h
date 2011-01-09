//
//  YouTubeMovieCell.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YouTubeMovieCell : UITableViewCell {

  NSMutableData *responseData;
  NSURLConnection *connection;
  NSURLResponse *response;
  UILabel *titleLabel;
  UIImageView *thumbnailImageView;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLResponse *response;


- (void)loadMovieImage:(NSString *)aUrl;

@end

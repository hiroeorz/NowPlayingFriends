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
@synthesize responseData;
@synthesize connection;
@synthesize response;
@synthesize thumbnailImageView;

- (void)dealloc {
  
  [connection release];
  [responseData release];
  [response release];
  [thumbnailImageView release];
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

/**
 * @brief Protocol for async URL loading
*/
- (void)connection:(NSURLConnection *)aConnection 
didReceiveResponse:(NSURLResponse *)aResponse {

  NSLog(@"didReceiveResponse");

  [response release];
  response = [aResponse retain];
  
  NSMutableData *aData = [[NSMutableData alloc] init];
  self.responseData = aData;
  [aData release];  
}
	
- (void)connection:(NSURLConnection *)aConnection 
  didFailWithError:(NSError *)error {
  
  NSLog(@"didFail");
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data {

  [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

  NSLog(@"didFinishLoading");
  UIImage *movieImage = [UIImage imageWithData:responseData];
  NSLog(@"image: %@", [UIImage imageWithData:responseData]);
  NSLog(@"data length: %d", [responseData length]);
  NSLog(@"image: %@", movieImage);
  thumbnailImageView.image = movieImage;

  self.responseData = nil;
}

- (void)loadMovieImage:(NSString *)aUrl {
  
  NSURLRequest *request = [NSURLRequest requestWithURL: 
					  [NSURL URLWithString:aUrl]];

  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

@end

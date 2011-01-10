//
//  YouTubeMovieCell.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "YouTubeMovieCell.h"
#import "NowPlayingFriendsAppDelegate.h"


@implementation YouTubeMovieCell

@dynamic appDelegate;
@synthesize connection;
@synthesize imageUrl;
@synthesize linkUrl;
@synthesize nameLabel;
@synthesize playCountLabel;
@synthesize response;
@synthesize responseData;
@synthesize thumbnailImageView;
@synthesize timeLabel;
@synthesize titleLabel;

- (void)dealloc {
  
  [connection release];
  [imageUrl release];
  [linkUrl release];
  [nameLabel release];
  [playCountLabel release];
  [response release];
  [responseData release];
  [thumbnailImageView release];
  [timeLabel release];
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

  UIImage *movieImage = [UIImage imageWithData:responseData];
  thumbnailImageView.image = movieImage;
  
  [self.appDelegate saveYoutubeThumbnailData:responseData 
       urlString:imageUrl];

  self.responseData = nil;
}

- (void)loadMovieImage:(NSString *)aUrl {

  self.imageUrl = aUrl;
  NSURLRequest *request = [NSURLRequest requestWithURL: 
					  [NSURL URLWithString:aUrl]];

  connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark -
#pragma IBAction Methods

- (IBAction)openMovie:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkUrl]];  
}


#pragma mark -
#pragma Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

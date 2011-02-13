//
//  FriendCellProfileImageGetter.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/13.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "FriendCell.h"
#import "FriendCellProfileImageGetter.h"
#import "NowPlayingFriendsAppDelegate.h"


@implementation FriendCellProfileImageGetter

@dynamic appDelegate;
@synthesize cancelFlag;
@synthesize cell;
@synthesize imageData;
@synthesize imageURLString;
@synthesize tweetData;


- (void)dealloc {

  [cell release];
  [imageData release];
  [imageURLString release];
  [tweetData release];
  [super dealloc];
}

#pragma mark -
#pragma Initializer

- (id)initWithTweetData:(NSDictionary *)aData cell:(FriendCell *)aCell {

  self = [super init];

  if (self != nil) {
    self.tweetData = aData;
    self.cell = aCell;
    imageData = nil;
  }

  return self;
}

#pragma mark -
#pragma Getter Methods

- (void)startGetProfileImage {

  self.imageData = [[NSMutableData alloc] init];

  NSDictionary *user = [tweetData objectForKey:@"user"];
  if (user == nil) { user = tweetData; }

  self.imageURLString = [user objectForKey:@"profile_image_url"];

  NSData *imageDataFromDisc = 
    [self.appDelegate profileImageDataWithURLString:imageURLString];

  if (imageDataFromDisc != nil) {
    UIImage *newImage = [UIImage imageWithData:imageDataFromDisc];
    [cell.userImageView setBackgroundImage:newImage
       forState:UIControlStateNormal];
    return;
  }

  NSURLRequest *request = 
    [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];

  [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma NSURLConnection Delegate Methods

- (BOOL)targetUrlIsChanged {
  return !([imageURLString isEqualToString:cell.imageURLString]);
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *) data {

  if ([self targetUrlIsChanged]) { 
    [self cancel];
    return; 
  }

  [imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  
  if (![self targetUrlIsChanged]) {
    UIImage *newImage = [UIImage imageWithData:imageData];
    [cell.userImageView setBackgroundImage:newImage
	 forState:UIControlStateNormal];
    
    [self.appDelegate saveProfileImageData:imageData urlString:imageURLString];
    [imageData release];
    self.imageData = nil;
  }
}

-(void)connection:(NSURLConnection*)connection 
 didFailWithError:(NSError*)error {

  NSLog(@"Connection Error While getting profile image");
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

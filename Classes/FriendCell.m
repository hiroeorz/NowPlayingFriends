//
//  FriendCell.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FriendCell.h"
#import "FriendCellProfileImageGetter.h"


@interface FriendCell (Local)

- (NSArray *)arrayOfUrlMatches;
@end


@implementation FriendCell

@synthesize userImageView;
@synthesize accountLabel;
@synthesize clientLabel;
@synthesize imageURLString;
@synthesize timeLabel;
@synthesize bodyTextView;
@synthesize baseView;
@synthesize username;
@synthesize linkButton;
@synthesize youTubeLinkButton;


- (void)dealloc {

  [userImageView release];
  [accountLabel release];
  [imageURLString release];
  [linkButton release];
  [clientLabel release];
  [timeLabel release];
  [bodyTextView release];
  [baseView release];
  [youTubeLinkButton release];
  [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style 
    reuseIdentifier:(NSString *)reuseIdentifier {

  if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
  }
  return self;
}

#pragma mark -
#pragma Profile Image Get Methods

- (void)getProfileImageWithTweetData:(NSDictionary *)tweetData {

  NSDictionary *user = [tweetData objectForKey:@"user"];
  if (user == nil) { user = tweetData; }

  /* 途中で表示対象のユーザが変わった事を伝える為 */
  self.imageURLString = [user objectForKey:@"profile_image_url"];

  FriendCellProfileImageGetter *getter = 
    [[FriendCellProfileImageGetter alloc] initWithTweetData:tweetData
					  cell:self];
  [getter autorelease];
  [getter startGetProfileImage];
}


#pragma mark -

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

  [super setSelected:selected animated:animated];
}

- (BOOL)urlIsIncluded {
  return ([[self arrayOfUrlMatches] count] > 0);
}

- (NSArray *)arrayOfUrl {

  NSString *body = bodyTextView.text;
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  NSArray *matches = [self arrayOfUrlMatches];

  for (NSTextCheckingResult *match in matches) {
    [array addObject:[body substringWithRange:[match rangeAtIndex:0]]];
  }

  return array;
}

- (void)openLink:(id)sender {
  
  NSArray *urlArray = [self arrayOfUrl];
  NSString *url = [urlArray objectAtIndex:0];
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];  
}

- (BOOL)hasYouTubeUrl {
  
  NSString *body = bodyTextView.text;
  if (body == nil) {return NO;}

  NSError *error = nil;

  NSRegularExpression *regexp = 
    [NSRegularExpression 
     regularExpressionWithPattern:@"https?://(www.youtube.com|youtu.be|y2u.be)/"
      options:0 error:&error];

  NSArray *matches = nil;

  if (error != nil) {
    NSLog(@"%@", error);
  } else {
    NSRange range = NSMakeRange(0, [body length]);
    matches = [regexp matchesInString:body options:0 range:range];
  }

  return ([matches count] > 0);
}

#pragma mark-
#pragma Local Methods

- (NSArray *)arrayOfUrlMatches {

  NSError *error = nil;
  NSString *body = bodyTextView.text;

  NSRegularExpression *regexp = 
    [NSRegularExpression 
      regularExpressionWithPattern:@"https?://[a-zA-Z0-9/.?_+~=%:;!#-]+"
      options:0 error:&error];

  NSArray *matches = nil;

  if (error != nil) {
    NSLog(@"%@", error);
  } else {
    NSRange range = NSMakeRange(0, [body length]);
    matches = [regexp matchesInString:bodyTextView.text options:0 range:range];
  }

  return matches;
}

@end

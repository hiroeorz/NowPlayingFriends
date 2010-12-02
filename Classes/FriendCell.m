//
//  FriendCell.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FriendCell.h"

@interface FriendCell (Local)

- (NSArray *)arrayOfUrlMaches;
@end


@implementation FriendCell

@synthesize userImageView;
@synthesize accountLabel;
@synthesize clientLabel;
@synthesize timeLabel;
@synthesize bodyTextView;
@synthesize baseView;
@synthesize username;
@synthesize linkButton;

- (void)dealloc {

  [userImageView release];
  [accountLabel release];
  [linkButton release];
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

- (NSArray *)arrayOfUrlMaches {

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

- (BOOL)urlIsIncluded {
  return ([[self arrayOfUrlMaches] count] > 0);
}

- (NSArray *)arrayOfUrl {

  NSString *body = bodyTextView.text;
  NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
  NSArray *matches = [self arrayOfUrlMaches];

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

@end

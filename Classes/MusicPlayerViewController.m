//
//  MusicPlayerViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MusicPlayerViewController.h"
#import "TwitterClient.h"


@implementation MusicPlayerViewController

@synthesize timeline;
@synthesize beforeTimeline;
@synthesize albumImageView;
@synthesize button;
@synthesize profileImageButtons;
@dynamic appDelegate;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [beforeTimeline release];
  [albumImageView release];
  [profileImageButtons release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.beforeTimeline = nil;
  self.albumImageView = nil;
  self.profileImageButtons = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  
  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  NSMutableArray *newProfileImageButtons = [[NSMutableArray alloc] init];
  self.profileImageButtons = newProfileImageButtons;
  [newProfileImageButtons release];

  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  activateFlag = YES;

  [self performSelectorInBackground:@selector(friendImageRefreshLoop)
	withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  activateFlag = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Timeline Refresh Methods

- (void)friendImageRefreshLoop {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSDate *date;
  NSDate *nextStartDate;

  while (true) {
    self.beforeTimeline = timeline;
    [self refreshTimeline];

    if (activateFlag && ![timeline isEqualToArray:beforeTimeline]) {
      [self setFriendImageView];
      NSLog(@"refreshed.");
    }

    date = [[NSDate alloc] init];
    nextStartDate = [[NSDate alloc] initWithTimeInterval:60 * 1 
				    sinceDate:date];

    [NSThread sleepUntilDate: nextStartDate];
    [date release];
    [nextStartDate release];

    if (activateFlag == NO) { break; }
  }

  [pool release];
}

- (void)refreshTimeline {

  NSLog(@"updating timeline data...");

  TwitterClient *client = [[TwitterClient alloc] init];
  NSString *songTitle = [self.appDelegate nowPlayingTitle];
  NSString *artistName = [self.appDelegate nowPlayingArtistName];

  NSArray *newTimeline = [client getSearchTimeLine:songTitle, artistName, nil];

  @synchronized(timeline) {
    self.timeline = newTimeline;
  }

  [client release];

  NSLog(@"timeline data updated.");
}

- (void)setFriendImageView {

  NSInteger i = 0;
  NSInteger x = 0;
  NSInteger y = 230;
  NSInteger xRange = kProfileImageSize;

  for (NSDictionary *data in timeline) {
    UIButton *profileImageButton;
    BOOL newButtonFlag = NO;

    if ([profileImageButtons count] < (i + 1)) {
      newButtonFlag = YES;
      profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
      profileImageButton.frame = CGRectMake(x, y, 
					    kProfileImageSize, 
					    kProfileImageSize);
    } else {
      newButtonFlag = NO;
      profileImageButton = [profileImageButtons objectAtIndex:i];
    }

    UIImage *newImage = [self.appDelegate profileImage:data
			     getRemote:YES];
    
    NSDictionary *objects = 
      [[NSDictionary alloc] initWithObjectsAndKeys:
			      profileImageButton, @"profileImageButton",
			    newImage, @"newImage", nil];
    
    if (newButtonFlag == YES) {
      [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	    withObject:objects
	    waitUntilDone:YES];
    } else {
      [self performSelectorOnMainThread:@selector(setBackgroundImage:)
	    withObject:objects
	    waitUntilDone:YES];
    }

    x = x + xRange;

    if (((i + 1) % 5) == 0) {
      y = y - kProfileImageSize;
      x = 0;
    }
    i++;
  }
}

- (void)addProfileImageButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [self.albumImageView addSubview:profileImageButton];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];

  @synchronized(profileImageButtons) {
    [profileImageButtons addObject:profileImageButton];
    NSLog(@"buttons count:%d", [profileImageButtons count]);
  }
   
  profileImageButton.alpha = kProfileImageButtonAlpha;
}

- (void)setBackgroundImage:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

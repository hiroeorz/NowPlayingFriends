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
@synthesize profileImages;
@synthesize albumImageView;
@synthesize button;
@synthesize profileImageButtons;
@dynamic appDelegate;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [profileImages release];
  [albumImageView release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.profileImages = nil;
  self.albumImageView = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

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
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

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
    [self refreshTimeline];
    [self setFriendImageView];

    NSLog(@"refreshed...");

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

  NSArray *newTimeline = [client getSearchTimeLine:@"#nowplaying", 
				 songTitle, artistName, nil];

  @synchronized(timeline) {
    self.timeline = newTimeline;
  }

  [client release];

  NSLog(@"timeline data updated.");
}

- (void)setFriendImageView {

  NSInteger i = 0;
  NSInteger startX = 0;
  NSInteger xRange = 64;

  for (UIButton *profileImageButton in profileImageButtons) {
    [profileImageButton removeFromSuperview];
  }

  NSMutableArray *newArray = [[NSMutableArray alloc] init];
  self.profileImageButtons = newArray;
  [newArray release];

  for (NSDictionary *data in timeline) {
    NSInteger x = startX + (xRange * i);
    UIButton *profileImageButton = [UIButton buttonWithType:UIButtonTypeCustom];

    NSLog(@"x:%d", x);
    profileImageButton.frame = CGRectMake(x, 0, 64, 64);

    UIImage *newImage = [self.appDelegate profileImage:data
			     profileImages:profileImages
			     getRemote:YES];

    NSLog(@"newImage:%@", newImage);


    profileImageButton.backgroundColor = [UIColor grayColor];

    NSDictionary *objects = 
      [[NSDictionary alloc] initWithObjectsAndKeys:
			      profileImageButton, @"profileImageButton",
			    newImage, @"newImage", nil];

    [self performSelectorOnMainThread:@selector(addProfileImageButton:)
	  withObject:objects
	  waitUntilDone:YES];

    [profileImageButton release];
    if ((i % 5) == 0) {}
    i++;
  }
}

- (void)addProfileImageButton:(NSDictionary *)objects {

  UIButton *profileImageButton = [objects objectForKey:@"profileImageButton"];
  UIImage *newImage = [objects objectForKey:@"newImage"];

  [self.albumImageView addSubview:profileImageButton];
  [profileImageButtons addObject:profileImageButton];
  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

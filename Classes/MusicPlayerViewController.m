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
@synthesize musicPlayer;

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

  [self setMusicPlayer:[MPMusicPlayerController iPodMusicPlayer]];
  [self.appDelegate addMusicPlayerNotification:self];

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

  self.title = [self.appDelegate nowPlayingTitle];
  [self setMusicArtwork];

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

- (void)handle_NowPlayingItemChanged:(id)notification {

  self.title = [self.appDelegate nowPlayingTitle];
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  NSString *nowPlayingTitle = 
    [currentItem valueForProperty: MPMediaItemPropertyTitle];

  self.title = nowPlayingTitle;
  NSLog(@"title: %@", nowPlayingTitle);
}

- (void)setMusicArtwork {

  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
  MPMediaItemArtwork *artwork = 
    [currentItem valueForProperty:MPMediaItemPropertyArtwork];

  UIImage *artworkImage;// = noArtworkImage;

  if (artwork) {
    artworkImage = [artwork imageWithSize:CGSizeMake(320, 291)];
  }

  self.albumImageView.image = artworkImage;

}

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
    nextStartDate = [[NSDate alloc] initWithTimeInterval:20 * 1 
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

    NSData *imageData = [self.appDelegate profileImage:data
			     getRemote:YES];

    NSDictionary *objects = 
      [[NSDictionary alloc] initWithObjectsAndKeys:
			      profileImageButton, @"profileImageButton",
			    imageData, @"newImage", nil];
    
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
  NSData *imageData = [objects objectForKey:@"newImage"];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];

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
  NSData *imageData = [objects objectForKey:@"newImage"];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];


  [self.appDelegate setAnimationWithView:profileImageButton
       animationType:UIViewAnimationTransitionFlipFromLeft];

  [profileImageButton setBackgroundImage:newImage 
		      forState:UIControlStateNormal];

  [UIView commitAnimations];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end


#import "SongsListViewController.h"
#import "PlayListSongsViewController.h"
#import "NowPlayingFriendsAppDelegate.h"

@implementation SongsListViewController

@synthesize playlist;
@synthesize musicPlayer;
@synthesize musicPlayerViewController;
@synthesize songListView;
@dynamic appDelegate;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  
  [playlist release];
  [musicPlayer release];
  [musicPlayerViewController release];
  [songListView release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.playlist = nil;
  self.musicPlayer = nil;
  self.musicPlayerViewController = nil;
  self.songListView = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate playerButton:@selector(changeToSongview) target:self];

  [super viewDidLoad];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSInteger row = [indexPath row];

  [musicPlayer endGeneratingPlaybackNotifications];

  [musicPlayer stop];
  [musicPlayer setQueueWithItemCollection:playlist];
  [musicPlayer play]; [musicPlayer pause];

  for (int i = 0; i < row; i++) {
    [musicPlayer skipToNextItem];
  }

  [musicPlayer play];
  [musicPlayer beginGeneratingPlaybackNotifications];
}


#pragma mark -

- (void)changeToSongview {

  [self.appDelegate setAnimationWithView:self.view
       animationType:UIViewAnimationTransitionFlipFromRight];

  if (songListView.superview != nil) {
    [songListView removeFromSuperview];
  }

  UIView *songView = [musicPlayerViewController songView];
  
  [self.view addSubview:songView];
  [UIView commitAnimations];

  [musicPlayerViewController setSongListController:self];  

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToSongsListview) 
	 target:musicPlayerViewController];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate editButton:@selector(openEditView) 
	 target:musicPlayerViewController];

}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

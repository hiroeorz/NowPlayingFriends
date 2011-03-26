
#import "MusicPlayerViewController.h"
#import "NowPlayingFriendsAppDelegate.h"
#import "PlayListSongsViewController.h"
#import "SendTweetViewController.h"
#import "SongsListViewController.h"

@interface SongsListViewController (Local)
- (void)openEditView;
@end

@implementation SongsListViewController

@synthesize playlist;
@synthesize musicPlayer;
@synthesize musicPlayerViewController;
@synthesize songListView;
@dynamic appDelegate;
@synthesize playListTitle;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  
  [playlist release];
  [musicPlayer release];
  [musicPlayerViewController release];
  [songListView release];
  [playListTitle release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.playlist = nil;
  self.musicPlayer = nil;
  self.musicPlayerViewController = nil;
  self.songListView = nil;
  self.playListTitle = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  [super viewDidLoad];
  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate editButton:@selector(openEditView) target:self];
}

- (void)viewWillAppear:(BOOL)animated {

  self.title = playListTitle;
  [super viewWillAppear:animated];
}

- (void)openEditView {

  musicPlayerViewController.autoTweetMode = NO;
  SendTweetViewController *viewController = 
    [[SendTweetViewController alloc] initWithNibName:@"SendTweetViewController"
				     bundle:nil];

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Tweet"  imageName:nil];
  [viewController release];

  [self presentModalViewController:navController animated:YES];
}

#pragma mark -
#pragma mark Table view delegate

/**
 * @brief タップされた曲を選択して再生する。
 */
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSInteger row = [indexPath row];
  MPMediaItem *selectedItem = [[playlist items] objectAtIndex:row];
  
  if ([self playListType] == kAlbumListType) {
    MPMediaQuery *query = [[[MPMediaQuery alloc] init] autorelease];
    MPMediaItem *representativeItem = [playlist representativeItem];
    NSString *albumTitle = [representativeItem valueForProperty:
						 MPMediaItemPropertyAlbumTitle];
    [query addFilterPredicate:[MPMediaPropertyPredicate 
				predicateWithValue:albumTitle
				forProperty: MPMediaItemPropertyAlbumTitle]];
    [musicPlayer setQueueWithQuery:query];
  } else {
    [musicPlayer setQueueWithItemCollection:playlist];
  }

  [musicPlayer setNowPlayingItem:selectedItem];
  [musicPlayer play];
}

#pragma mark -

- (void)changeToSongview {

  [self.appDelegate setAnimationWithView:self.view
       animationType:UIViewAnimationTransitionFlipFromRight];

  if (songListView.superview != nil) {
    [songListView removeFromSuperview];
  }

  
  UIView *songView = 
    [(MusicPlayerViewController *)musicPlayerViewController songView];
  
  [self.view addSubview:songView];
  [UIView commitAnimations];

  [(MusicPlayerViewController *)musicPlayerViewController 
				setSongListController:self];  

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate listButton:@selector(changeToSongsListview) 
	 target:musicPlayerViewController];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate editButton:@selector(openEditView) 
	 target:musicPlayerViewController];

}

#pragma mark -

- (NSInteger)playListType {
  return -1;
}


#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

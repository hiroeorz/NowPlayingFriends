//
//  YouTubeListViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/09.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "YouTubeListViewController.h"

#import "NowPlayingFriendsAppDelegate.h"
#import "SendTweetViewController.h"
#import "YouTubeClient.h"
#import "YoutubeTypeSelectViewController.h"
#import "YouTubeMovieCell.h"


@interface YouTubeListViewController (Local) 
- (void)cancel;
- (void)searchFromYouTube:(NSString *)searchStr;
- (void)searchFromNowPlaying;
- (void)searchFinished:(NSArray *)searchResults;
@end


@implementation YouTubeListViewController

@dynamic appDelegate;
@synthesize movieTableView;
@synthesize movies;
@synthesize searchBar;
@synthesize searchFinishButton;
@synthesize selectedMovie;
@synthesize tweetViewController;
@synthesize typeSelectViewController;

- (void)dealloc {

  [movieTableView release];
  [searchBar release];
  [searchFinishButton release];
  [selectedMovie release];
  [tweetViewController release];
  [typeSelectViewController release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.movieTableView = nil;
  self.searchBar = nil;
  self.selectedMovie = nil;
  self.tweetViewController = nil;
  self.typeSelectViewController = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

  if (self) {
    typeSelectViewController = nil;
    movieSelected = NO;
    isSearching = NO;
  }

  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (tweetViewController != nil) {
    self.navigationItem.leftBarButtonItem = 
      [self.appDelegate cancelButton:@selector(cancel) target:self];
  }

  self.title = @"YouTube Search";
  [self searchFromNowPlaying];
}

- (void)viewDidAppear:(BOOL)animated {  
}

- (void)viewDidDisappear:(BOOL)animated {
  
  if (movieSelected == YES && tweetViewController != nil) {
    [tweetViewController addYouTubeLink:
			   [NSArray arrayWithObjects:selectedMovie, nil]];
    movieSelected = NO;
  }
}

-(void)cancel {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma Search Bar Delegate Methods

- (IBAction)searchFinishButtonClicked:(id)sender {
  [self searchFromYouTube:searchBar.text];
  [self hideSearchBarWithAnimated:YES];
}

- (void)searchFromYouTube:(NSString *)searchStr {

  YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
  [youtube searchWithFreeParameters:searchStr
	   delegate:self
	   action:@selector(searchFinished:)
	   count: kYouTubeSearchCount];
}

/**
 * @brief 検索ボタンタップ時に検索実行して検索バーとキーボードを片付ける。
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

  [self searchFromYouTube:searchBar.text];
  [self hideSearchBarWithAnimated:YES];
}

/**
 * @brief ユーザの入力に伴って検索実行。
 */
- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchTerm {

  //[self searchFromYouTube:searchBar.text];
}

/**
 * @brief ユーザが検索バーをタップした際に呼び出される。
 */
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
  isSearching = YES;
  CGRect frame = searchFinishButton.frame;
  frame.origin.x = 0.0f;
  frame.origin.y = 43.0f;
  searchFinishButton.frame = frame;
  [movieTableView addSubview:searchFinishButton];
}

/**
 * @brief ユーザが検索バーのキャンセルボタンをタップした際に呼び出される。
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {

  [self hideSearchBarWithAnimated:YES];
  [self searchFromNowPlaying];
}

/**
 * @brief キー入力を隠し、検索バーを隠す処理。
 */
- (void)hideSearchBarWithAnimated:(BOOL)animated {
  isSearching = NO;
  [searchBar resignFirstResponder];
  [searchFinishButton removeFromSuperview];
  [movieTableView setContentOffset:CGPointMake(0.0, 44.0) animated:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  
  return [movies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  static NSString *movieCellIdentifier = @"movieCellIdentifier";

  YouTubeMovieCell *cell = 
    (YouTubeMovieCell *)[tableView dequeueReusableCellWithIdentifier:movieCellIdentifier];

  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YouTubeMovieCell"
					  owner:self
					  options:nil];

    for (id oneObject in nib) {
      if ([oneObject isKindOfClass:[YouTubeMovieCell class]]) {
	cell = (YouTubeMovieCell *)oneObject;	
      }
    }
  }

  NSDictionary *movie = [movies objectAtIndex:[indexPath row]];
  cell.titleLabel.text = [movie objectForKey:@"contentTitle"];

  cell.thumbnailImageView.image = nil;
  cell.nameLabel.text = [movie objectForKey:@"name"];
  cell.playCountLabel.text = [movie objectForKey:@"viewCount"];

  NSString *secondsString = [movie objectForKey:@"seconds"];
  NSInteger seconds = [secondsString intValue];
  NSInteger min = seconds / 60;
  NSInteger seconds_of_min = seconds % 60;
  NSString *time_str = [NSString stringWithFormat:@"%d:%02d", 
				 min, seconds_of_min];
  cell.timeLabel.text = time_str;

  NSString *imageUrl = [movie objectForKey:@"thumbnailUrl"];
  NSData *imageData = [self.appDelegate 
			   youtubeThumbnailDataWithURLString:imageUrl];

  if (imageData == nil) {
    [cell loadMovieImage:imageUrl];
  } else {
    UIImage *movieImage = [UIImage imageWithData:imageData];
    cell.thumbnailImageView.image = movieImage;
  }

  cell.linkUrl = [movie objectForKey:@"linkUrl"];
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kYouTubeThumbnailHeight;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSDictionary *movie = [movies objectAtIndex:[indexPath row]];
  self.selectedMovie = movie;
  movieSelected = YES;

  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma Local Methods

- (void)searchFromNowPlaying {

  YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];
  NSString *title = [self.appDelegate nowPlayingTitle];
  NSString *artist = [self.appDelegate nowPlayingArtistName];

  [youtube searchWithTitle:title artist:artist
	   delegate:self
	   action:@selector(searchFinished:)
	   count: kYouTubeSearchCount];

  NSString *parameter = [[[NSString alloc] initWithFormat:@"%@ %@",
					   title, artist] autorelease];
  searchBar.text = parameter;
}

- (void)searchFinished:(NSArray *)searchResults {

  self.movies = searchResults;
  [movieTableView reloadData];
  //NSLog(@"search results: %@", searchResults);
}


- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

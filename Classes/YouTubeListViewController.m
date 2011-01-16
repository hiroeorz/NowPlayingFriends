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
- (void)searchFromNowPlaying;
- (void)searchFinished:(NSArray *)searchResults;
@end


@implementation YouTubeListViewController

@dynamic appDelegate;
@synthesize movieTableView;
@synthesize movies;
@synthesize selectedMovie;
@synthesize tweetViewController;
@synthesize typeSelectViewController;

- (void)dealloc {

  [movieTableView release];
  [selectedMovie release];
  [tweetViewController release];
  [typeSelectViewController release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.movieTableView = nil;
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

  [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	   artist:[self.appDelegate nowPlayingArtistName]
	   delegate:self
	   action:@selector(searchFinished:)
	   count: kYouTubeSearchCount];
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

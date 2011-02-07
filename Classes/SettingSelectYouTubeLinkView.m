//
//  SettingSelectYouTubeLinkView.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/02/07.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "SettingSelectYouTubeLinkView.h"

@interface SettingSelectYouTubeLinkView (Local)

- (NowPlayingFriendsAppDelegate *)appDelegate;
@end


@implementation SettingSelectYouTubeLinkView

@synthesize lastIndexPath;
@synthesize titles;
@synthesize values;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [lastIndexPath release];
  [titles release];
  [values release];
  [super dealloc];
}

- (void)viewDidUnload {
  
  self.lastIndexPath = nil;
  self.titles = nil;
  self.values = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {

  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
  return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *titlesArray = [[NSArray alloc] initWithObjects:@"Top Of Search",
					  @"Select From List", 
					  @"Confirmation", nil];
  self.titles = titlesArray;
  [titlesArray release];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *CellIdentifier = @"SettingSelectYouTubeLinkCell";
    
    UITableViewCell *cell = 
      [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
		  initWithStyle:UITableViewCellStyleDefault 
		  reuseIdentifier:CellIdentifier] autorelease];
    }
  
    NSInteger selectType = self.appDelegate.select_youtube_link_preference;

    if (selectType == [indexPath row]) {
      cell.accessoryType = UITableViewCellAccessoryCheckmark;
      self.lastIndexPath = indexPath;
    }

    cell.textLabel.text = [titles objectAtIndex:[indexPath row]];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView 
willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  return indexPath;
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSInteger newRow = [indexPath row];
  NSInteger oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;

  if (newRow != oldRow) {
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;

    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;
    self.lastIndexPath = indexPath;

    self.appDelegate.select_youtube_link_preference = [indexPath row];
  }

  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end


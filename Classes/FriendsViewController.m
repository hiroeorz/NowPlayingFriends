//
//  NowPlayingViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendCell.h"
#import "TwitterClient.h"
#import "UserInformationViewController.h"


@implementation FriendsViewController

@synthesize timeline;
@synthesize beforeTimeline;
@dynamic appDelegate;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [beforeTimeline release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.beforeTimeline = nil;
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  
  NSArray *array = [[NSArray alloc] init];
  self.beforeTimeline = array;
  [array release];

  [super viewDidLoad];
}

- (void)refreshTimeline {
  [NSException raise:@"called base class method"
	       format:@"you must override this method:refreshTimeline"];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  
  activateFlag = YES;
  [self performSelectorInBackground:@selector(tableRefreshLoop)
	withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  activateFlag = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 * @brief 一定時間おきに検索結果を取得するループメソッド。別スレッドで実行する。
 */
- (void)tableRefreshLoop {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSDate *date;
  NSDate *nextStartDate;

  while (true) {
    self.beforeTimeline = timeline;
    [self refreshTimeline];

    if (activateFlag && ![timeline isEqualToArray:beforeTimeline]) {
      [self performSelectorOnMainThread:@selector(reloadTableDataOnMainThread)
	    withObject:nil
	    waitUntilDone:YES];

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

- (void)reloadTableDataOnMainThread {

  @synchronized(timeline) {
    [(UITableView *)self.view reloadData];
  }
}

#pragma mark -
#pragma mark Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return <#number of sections#>;
}
*/

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  
  return [timeline count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *FriendsCellIdentifier = @"Cell";
    
  FriendCell *cell = 
    (FriendCell *)[tableView 
		    dequeueReusableCellWithIdentifier:FriendsCellIdentifier];

  if (cell == nil) {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FriendCell"
					  owner:self
					  options:nil];

    for (id oneObject in nib) {
      if ([oneObject isKindOfClass:[FriendCell class]]) {
	cell = (FriendCell *)oneObject;
	cell.bodyTextView.font = [UIFont systemFontOfSize:13];

	[cell.userImageView addTarget:self 
	     action:@selector(openUserInformationView:)
	     forControlEvents:UIControlEventTouchUpInside];

      }
    }
  }
  
  NSInteger row = [indexPath row];
  NSDictionary *data = [timeline objectAtIndex:row];

  cell.bodyTextView.text = [data objectForKey:@"text"];
  cell.accountLabel.text = [self username:data];
  cell.userImageView.tag = row;

  NSDictionary *objects = [[NSDictionary alloc] initWithObjectsAndKeys:
						  data, @"data",
						cell, @"cell", nil];
  [self performSelectorInBackground:@selector(setProfileImageWithObjects:)
	withObject:objects];

  [objects release];
  return cell;
}

/**
 * @brief データからユーザ名を返します。
 */
- (NSString *)username:(NSDictionary *)data {

  return [self.appDelegate username:data];
}

- (void)setProfileImageWithObjects:(NSDictionary *)objects {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSDictionary *data = [objects objectForKey:@"data"];
  FriendCell *cell = [[objects objectForKey:@"cell"] retain];
  NSData *imageData = [self.appDelegate profileImage:data
			   getRemote:YES];

  NSDictionary *setObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
						     imageData, @"image",
						   cell, @"cell",
						   nil];

  [self performSelectorOnMainThread:@selector(setProfileImageWithImage:)
	withObject:setObjects
	waitUntilDone:YES];

  [setObjects release];
  [pool release];
}

- (void)setProfileImageWithImage:(NSDictionary *)objects {

  NSData *imageData =  [objects objectForKey:@"image"];
  UIImage *newImage = [[UIImage alloc] initWithData:imageData];

  FriendCell *cell = [objects objectForKey:@"cell"];

  @synchronized(timeline) {
    if (cell != nil && cell.superview != nil) {
      [cell.userImageView setBackgroundImage:newImage
	   forState:UIControlStateNormal];
    }
  }
}

/**
 * @brief ユーザのプロフィール画像のキャッシュをとります。
 */
- (void) cacheAllProfileImage {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  for (NSDictionary *data in timeline) {
    [self.appDelegate profileImage:data 
	 getRemote:YES];
  }

  [pool release];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kTimelineTableRowHeight;
}

#pragma mark -
#pragma mark IBAction Methods

- (void)openUserInformationView:(id)sender {

  NSLog(@"touched: %d", [sender tag]);

  NSInteger tagIndex = [sender tag];
  NSDictionary *timelineData = [timeline objectAtIndex:tagIndex];
  NSString *username = [self username:timelineData];
  NSLog(@"tupped user:%@", username);

  UserInformationViewController *viewController = 
    [[UserInformationViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end


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

@implementation FriendsViewController

@synthesize timeline;
@synthesize profileImages;
@dynamic appDelegate;

#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
  self.timeline = nil;
  self.profileImages = nil;
}

- (void)dealloc {
  [timeline release];
  [profileImages release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

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

- (void)tableRefreshLoop {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSDate *date;
  NSDate *nextStartDate;

  while (true) {
    [self refreshTimeline];
    [self performSelectorOnMainThread:@selector(reloadTableDataOnMainThread)
	  withObject:nil
	  waitUntilDone:YES];

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
      }
    }
  }
  
  NSInteger row = [indexPath row];
  NSDictionary *data = [timeline objectAtIndex:row];

  cell.bodyTextView.text = [data objectForKey:@"text"];
  cell.accountLabel.text = [self username:data];

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

  NSDictionary *user = [data objectForKey:@"user"];
  NSString *username = [data objectForKey:@"name"];

  if (user == nil) {
    username = [data objectForKey:@"from_user"];
  }
  
  return username;
}

- (void)setProfileImageWithObjects:(NSDictionary *)objects {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDictionary *data = [objects objectForKey:@"data"];
  FriendCell *cell = [objects objectForKey:@"cell"];
  UIImage *newImage = [self profileImage:data getRemote:YES];

  NSDictionary *setObjects = [[NSDictionary alloc] initWithObjectsAndKeys:
						     newImage, @"image",
						   cell, @"cell",
						   nil];

  [self performSelectorOnMainThread:@selector(setProfileImageWithImage:)
	withObject:setObjects
	waitUntilDone:YES];

  [setObjects release];
  [pool release];
}

- (void)setProfileImageWithImage:(NSDictionary *)objects {

  UIImage *newImage = [objects objectForKey:@"image"];
  FriendCell *cell = [objects objectForKey:@"cell"];

  @synchronized(timeline) {
    cell.userImageView.image = newImage;
  }
}

/**
 * @brief ユーザのプロフィール画像を返します。
 *        キャッシュにあればそれを、なければリモートから取得して返します。
 */
- (UIImage *)profileImage:(NSDictionary *)data 
		getRemote:(BOOL) getRemoteFlag {

  NSDictionary *user = [data objectForKey:@"user"];

  if (user == nil) { user = data; }

  NSString *imageURLString = [user objectForKey:@"profile_image_url"];
  UIImage *profileImage = [profileImages objectForKey:imageURLString];

  if (profileImage == nil && getRemoteFlag) {
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    profileImage = [[UIImage alloc] initWithData:imageData];

    [profileImages setObject:profileImage forKey:imageURLString];
  }

  return profileImage;
}

/**
 * @brief ユーザのプロフィール画像のキャッシュをとります。
 */
- (void) cacheAllProfileImage {
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  for (NSDictionary *data in timeline) {
    [self profileImage:data getRemote:YES];
  }

  [pool release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return kTimelineTableRowHeight;
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


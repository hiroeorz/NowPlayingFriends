//
//  NowPlayingViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NowPlayingViewController.h"
#import "FriendCell.h"
#import "TwitterClient.h"

@implementation NowPlayingViewController

@synthesize timeline;
@synthesize profileImages;

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.profileImages = nil;
}

- (void)dealloc {
  [timeline release];
  [profileImages release];
  [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  
  NSMutableDictionary *newProfileImages = [[NSMutableDictionary alloc] init];
  self.profileImages = newProfileImages;
  [newProfileImages release];

  TwitterClient *client = [[TwitterClient alloc] init];
  self.timeline = [client getTimeLine:@"hiroe_orz17"];
  [client release];

  [super viewDidLoad];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
  NSDictionary *user = [data objectForKey:@"user"];

  cell.bodyTextView.text = [data objectForKey:@"text"];
  cell.accountLabel.text = [user objectForKey:@"name"];
  cell.userImageView.image = [self profileImage:user];

  return cell;
}

/**
 * @brief ユーザのプロフィール画像を返します。
 */
- (UIImage *)profileImage:(NSDictionary *)user {

  NSString *imageURLString = [user objectForKey:@"profile_image_url"];
  UIImage *profileImage = [profileImages objectForKey:imageURLString];

  if (profileImage == nil) {
    NSURL *imageURL = [NSURL URLWithString:imageURLString];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    profileImage = [[UIImage alloc] initWithData:imageData];

    [profileImages setObject:profileImage forKey:imageURLString];
  }

  return profileImage;
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

@end


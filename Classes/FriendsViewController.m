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
@synthesize friendsTableView;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [timeline release];
  [beforeTimeline release];
  [friendsTableView release];
  [super dealloc];
}

- (void)viewDidUnload {
  self.timeline = nil;
  self.beforeTimeline = nil;
  self.friendsTableView = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  changed = YES;
  NSArray *array = [[NSArray alloc] init];
  self.beforeTimeline = array;
  [array release];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate refreshButton:@selector(refreshTableOnThread) 
	 target:self];

  [super viewDidLoad];
}

#pragma mark -
#pragma MusicPlayer Delegate Methods

/**
 * @brief プレイヤーの制御状況が変化したときに呼ばれる。
 */
- (void)handle_PlayBackStateDidChanged:(id)notification {

}

/**
 * @brief プレイヤーの音量が変化したときに呼ばれる。
 */
- (void)handle_VolumeChanged:(id)notification {

}

/**
 * @brief 再生中の曲が変わったときに呼ばれる。
 */
- (void)handle_NowPlayingItemChanged:(id)notification {
  
  NSLog(@"called handle_NowPlayingItemChanged");

  changed = YES;
  MPMediaItem *currentItem = [self.appDelegate.musicPlayer nowPlayingItem];
  
  if (currentItem != nil) {
    NSArray *array = [[NSArray alloc] init];
    self.timeline = array;
    [array release];

    [self refreshTableOnThread];
  }
}

#pragma mark -
#pragma Timeline Update Methods

- (NSInteger)refreshTimeline {
  [NSException raise:@"called base class method"
	       format:@"you must override this method:refreshTimeline"];
  return 0;
}

/**
 * @brief テーブルに表示するセルの個数を限定します。
 */
- (void)shurinkTimeline {

  if ([timeline count] > kMaxTableCellRow) {
    NSArray *newTimeline = 
      [timeline subarrayWithRange:NSMakeRange(0, kMaxTableCellRow)];
    
    self.timeline = newTimeline;
  }
}

/**
 * @brief 与えられた配列から新しいテーブル用配列を生成します。
 */
- (NSInteger)createNewTimeline:(NSArray *)newTimeline {

  NSInteger addRowCount = 0;

  @synchronized(timeline) {

    if ([timeline count] == 0) {
      self.timeline = newTimeline;
      addRowCount = [newTimeline count];

    } else {
      NSDictionary *firstItem = [timeline objectAtIndex:0];
      NSNumber *firstId = [firstItem objectForKey:@"id"];
      NSMutableArray *array = [[NSMutableArray alloc] init];

      for (NSDictionary *newItem in newTimeline) {
	NSNumber *itemId = [newItem objectForKey:@"id"];

	if ([firstId isEqualToNumber:itemId]) {
	  NSLog(@"found duplicate id:%@", itemId);
	  break;
	}

	[array addObject:newItem];
	addRowCount++;
      }


      for (NSDictionary *oldItem in timeline) {
	[array addObject:oldItem];
      }

      self.timeline = array;
      [array release];
    }

  }

  NSLog(@"timeline count: %d", [timeline count]);
  return addRowCount;
}


- (void)viewWillAppear:(BOOL)animated {

  [friendsTableView reloadData];

  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];
  /*
  activateFlag = YES;
  [self performSelectorInBackground:@selector(tableRefreshLoop)
	withObject:nil];
  */

  activateFlag = YES;
  [self refreshTableOnThread];
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
    NSLog(@"now cellRow: %d", cellRow);

    if (cellRow <= kTableUpdateMaxScrollRow) {
      [self refreshTable];
    }

    date = [[NSDate alloc] init];
    nextStartDate = [[NSDate alloc] 
		      initWithTimeInterval:kTimelineUpdateInterval 
		      sinceDate:date];

    [NSThread sleepUntilDate: nextStartDate];
    [date release];
    [nextStartDate release];

    if (activateFlag == NO) { break; }
  }

  [pool release];
}

/**
 * @brief 新たなデータを取得してテーブルの内容を更新します。
 */
- (IBAction)refreshTableOnThread {

  changed = NO;
  [self performSelectorInBackground:@selector(refreshTable)
	withObject:nil];
}

/**
 * @brief 新たなデータを取得してテーブルの内容を更新します。
 */
- (void)refreshTable {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  self.beforeTimeline = timeline;
  NSInteger addCount = [self refreshTimeline];
  NSInteger newOffset = [self newOffset:addCount];
  
  [self shurinkTimeline];
  
  if (activateFlag && ![timeline isEqualToArray:beforeTimeline]) {
    [self performSelectorOnMainThread:@selector(reloadTableDataOnMainThread:)
	  withObject:[NSNumber numberWithInteger:newOffset]
	  waitUntilDone:YES];
    
    NSLog(@"refreshed.");
  }

  [pool release];
}

/**
 * @brief テーブルを更新する。更新後も更新前に表示していた位置を表示する。
 */
- (void)reloadTableDataOnMainThread:(NSNumber *)newOffsetNumber {

  @synchronized(timeline) {
    friendsTableView.dataSource = self;
    friendsTableView.delegate = self;

    [friendsTableView reloadData];

    friendsTableView.contentOffset = 
      CGPointMake(0.0f, [newOffsetNumber floatValue]);
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
  
  NSLog(@"numberOfRowsInSection:%d", [timeline count]);
  return [timeline count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  cellRow = [indexPath row];
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
	cell.bodyTextView.font = [UIFont systemFontOfSize:15];

	[cell.userImageView addTarget:self 
	     action:@selector(openUserInformationView:)
	     forControlEvents:UIControlEventTouchUpInside];
      }
    }
  }
  
  NSInteger row = [indexPath row];
  NSDictionary *data = [timeline objectAtIndex:row];
  NSString *rowText = [data objectForKey:@"text"];

  cell.bodyTextView.text = [self.appDelegate stringByUnescapedString:rowText];
  cell.accountLabel.text = [self username:data];
  cell.userImageView.tag = row;

  CGFloat overflow = [self lineOverFlowSize:indexPath];

  CGRect viewFrame = cell.baseView.frame;
  viewFrame.size.height = kViewFrameHeight + overflow;
  cell.baseView.frame = viewFrame;

  CGRect textFrame = cell.bodyTextView.frame;
  textFrame.size.height = kTextFrameHeight + overflow;
  cell.bodyTextView.frame = textFrame;

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
  UIImage *newImage = [self.appDelegate profileImage:data
			    getRemote:YES];

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

  UIImage *newImage =  [objects objectForKey:@"image"];
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

- (NSInteger)newOffset:(NSInteger)addCount {

  CGPoint offset = friendsTableView.contentOffset;
  NSInteger totalOffset = offset.y;

  if ([timeline count] != addCount) {
    for (NSInteger i = 0; i < addCount; i++) {
      NSInteger cellViewHeight = kTimelineTableRowHeight;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
      
      cellViewHeight = cellViewHeight + [self lineOverFlowSize:indexPath];
      totalOffset = totalOffset + cellViewHeight;
    }
  }

  NSLog(@"totalOffset: %d", totalOffset);
  return totalOffset;
}

- (CGFloat)lineHeightValue:(NSIndexPath *)indexPath {

  NSInteger row = [indexPath row];
  NSDictionary *data = [timeline objectAtIndex:row];

  NSString *rowText = [data objectForKey:@"text"];
  NSString *bodyText= [self.appDelegate stringByUnescapedString:rowText];
   
  CGSize bounds = CGSizeMake(320, 1000);
  UIFont *font = [UIFont systemFontOfSize:17];
  CGSize size = [bodyText sizeWithFont:font
			  constrainedToSize:bounds
			  lineBreakMode:UILineBreakModeTailTruncation];

  return size.height + 9;
}

- (CGFloat)lineOverFlowSize:(NSIndexPath *)indexPath {

  CGFloat lineHeight = [self lineHeightValue:indexPath];

  if (lineHeight <= kDefaultBodyTextHeight) {
    return 0.0f;
  }

  CGFloat overFlowSize = lineHeight - kDefaultBodyTextHeight;
  return overFlowSize;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  CGFloat overflow = [self lineOverFlowSize:indexPath];
  return kTimelineTableRowHeight + overflow;
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


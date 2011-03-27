//
//  NowPlayingViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/12.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountLabelButton.h"
#import "FriendsViewController.h"
#import "FriendCell.h"
#import "SendTweetViewController.h"
#import "TwitterClient.h"
#import "UserInformationViewController.h"


@interface FriendsViewController (Local)

- (NSInteger)refreshTimeline;
- (void)tableRefreshLoop;
- (void)shurinkTimeline;

- (IBAction)refreshTableOnThread;
- (void)refreshTable;

- (BOOL)checkSpecialCell:(NSDictionary *)data;
- (NSString *)clientname:(NSDictionary *)data;
- (NSString *)username:(NSDictionary *)data;
- (void)openUserInformationView:(id)sender;
- (CGFloat)lineHeightValue:(NSInteger)row;
- (float)lineOverFlowSize:(NSInteger)row;
- (NSInteger)newOffset:(NSInteger)addCount;
- (float)lineOverFlowSizeFromQueue:(NSInteger)row;
- (NSString *)passedTimeString:(NSDictionary *)aData;
- (void)queuingLineOverFlowSize;

- (void)openEditView:(UIButton *)button;
- (NowPlayingFriendsAppDelegate *)appDelegate;

@end


@implementation FriendsViewController

@dynamic appDelegate;
@synthesize beforeTimeline;
@synthesize friendsTableView;
@synthesize lineOverFlowQueue;
@synthesize myUserName;
@synthesize newTimelineQueue;
@synthesize noArtWorkMini;
@synthesize timeline;

#pragma mark -
#pragma mark Memory management

- (void)dealloc {

  [beforeTimeline release];
  [friendsTableView release];
  [lineOverFlowQueue release];
  [myUserName release];
  [newTimelineQueue release];
  [noArtWorkMini release];
  [timeline release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.beforeTimeline = nil;
  self.friendsTableView = nil;
  self.lineOverFlowQueue = nil;
  self.myUserName = nil;
  self.newTimelineQueue = nil;
  self.noArtWorkMini = nil;
  self.timeline = nil;
  [super viewDidUnload];
}

#pragma mark -
#pragma mark initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    firstFlag = YES;
  }
  return self;
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {

  self.noArtWorkMini = [UIImage imageNamed:@"no_artwork_mini.png"];

  changed = YES;
  NSArray *array = [[NSArray alloc] init];
  self.beforeTimeline = array;
  [array release];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate refreshButton:@selector(refreshTableOnThread) 
	 target:self];

  TwitterClient *client = [[TwitterClient alloc] init];
  self.myUserName = [client username];
  [client release];

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

/**
 * @brief 別スレッドで実行し、新着ツイートがあったらタブのバッジに表示する。
 */
- (void)updateNewItemCountToBadge {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  TwitterClient *client = [[TwitterClient alloc] init];
  NSDate *date;
  NSDate *nextStartDate;

  while (YES) {
    NSAutoreleasePool *inPool = [[NSAutoreleasePool alloc] init];
    
    if (timeline == nil) {
      NSArray *newTimeline = [client getMentionsTimeLineSince:nil];
      self.timeline = newTimeline;
      NSLog(@"set Mentions timeline (count: %d)", [timeline count]);

    } else {
      NSNumber *lastId = [self lastTweetId];
      NSArray *newTimeline = [client getMentionsTimeLineSince:lastId];
      
      for (NSDictionary *obj in newTimeline) {
	self.newTimelineQueue = newTimeline;
	NSLog(@"id:%@", [obj objectForKey:@"id"]);
      }
      
      NSLog(@"newCount: %d", [newTimeline count]);
      
      NSString *countStr = nil;
      if ([newTimeline count] > 0) {
	countStr = [[NSString alloc] initWithFormat:@"%d", [newTimeline count]];
      }

      [self performSelectorOnMainThread:@selector(setBadgeValueOnMainThread:)
	    withObject:countStr
	    waitUntilDone:NO];
      
      [countStr release];
    }

    date = [[NSDate alloc] init];
    nextStartDate = [[NSDate alloc] 
		      initWithTimeInterval:kTimelineUpdateInterval 
		      sinceDate:date];
    [NSThread sleepUntilDate: nextStartDate];

    [date release];
    [nextStartDate release];
    date = nil;
    nextStartDate = nil;
    
    [inPool release];
  }

  [client release];
  [pool release];
}

- (void)setBadgeValueOnMainThread:(NSString *)aBadgeValue {
  self.navigationController.tabBarItem.badgeValue = aBadgeValue;
}

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
    
    NSLog(@"table data shulinked because too big:%d", [timeline count]);
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
      NSLog(@"new Time line count: %d", [timeline count]);

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

  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  
  [super viewDidAppear:animated];

  [friendsTableView reloadData];
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
  [self queuingLineOverFlowSize];

  if (activateFlag && ![timeline isEqualToArray:beforeTimeline]) {
    [self performSelectorOnMainThread:@selector(reloadTableDataOnMainThread:)
	  withObject:[NSNumber numberWithInteger:newOffset]
	  waitUntilDone:NO];    
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
    self.navigationController.tabBarItem.badgeValue = nil;

    friendsTableView.contentOffset = 
      CGPointMake(0.0f, [newOffsetNumber floatValue]);
  }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  
  return [timeline count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  cellRow = [indexPath row];
  static NSString *FriendsCellIdentifier = @"FriendCell";
    
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
  cell.userImageView.tag = row;
  cell.clientLabel.text = [self clientname:data];

  [cell.accountLabel setTitle:[self username:data] 
       forState:UIControlStateNormal];
  [cell.accountLabel setTitle:[self username:data] 
       forState:UIControlStateHighlighted];
  [cell.accountLabel addTarget:self action:@selector(openEditView:)
       forControlEvents:UIControlEventTouchUpInside];
  [(AccountLabelButton *)cell.accountLabel setData:data];

  if ([cell urlIsIncluded]) {
    UIButton *aButton = nil;

    if ([cell hasYouTubeUrl]) {
      cell.linkButton.alpha = 0.0f;
      cell.youTubeLinkButton.alpha = 1.0f;
      aButton = cell.youTubeLinkButton;
    } else {
      cell.youTubeLinkButton.alpha = 0.0f;
      cell.linkButton.alpha = 1.0f;
      aButton = cell.linkButton;
    }

    [aButton addTarget:cell action:@selector(openLink:)
	     forControlEvents:UIControlEventTouchUpInside];
  } else {
    cell.linkButton.alpha = 0.0f;
    cell.youTubeLinkButton.alpha = 0.0f;
  }

  if ([self checkSpecialCell:data]) {
    cell.baseView.backgroundColor = [UIColor colorWithHue:0.0f
					       saturation:0.72f
					       brightness:0.22f
					       alpha:1.0f];
  } else {
    cell.baseView.backgroundColor = [UIColor blackColor];
  }
  
  cell.timeLabel.text = [self passedTimeString:data];
  
  CGFloat overflow = [self lineOverFlowSizeFromQueue:[indexPath row]];

  CGRect viewFrame = cell.baseView.frame;
  viewFrame.size.height = kViewFrameHeight + overflow;
  cell.baseView.frame = viewFrame;

  CGRect textFrame = cell.bodyTextView.frame;
  textFrame.size.height = kTextFrameHeight + overflow;
  cell.bodyTextView.frame = textFrame;

  [cell.userImageView 
       setBackgroundImage:noArtWorkMini forState:UIControlStateNormal];

  [cell getProfileImageWithTweetData:data];

  return cell;
}

- (NSString *)passedTimeString:(NSDictionary *)aData {

  NSInteger intervalSec = [self.appDelegate secondSinceNow:aData];
  NSString *passedString = nil;

  if (intervalSec < 60) {
    passedString = [[NSString alloc] initWithFormat:@"%ds", intervalSec];
  } else if (intervalSec >= 60 && intervalSec < (60 * 60)) {
    passedString = [[NSString alloc] initWithFormat:@"%dm", (intervalSec / 60)];
  } else if (intervalSec >= (60 * 60) && intervalSec < (60 * 60 * 24)) {
    passedString = [[NSString alloc] initWithFormat:@"%dh", (intervalSec / (60 * 60))];
  } else if (intervalSec >= (60 * 60 * 24) && 
	     intervalSec < (60 * 60 * 24 * 30)){
    passedString = [[NSString alloc] initWithFormat:@"%dd", (intervalSec / (60 * 60 * 24))];    
  } else {
    passedString = [[NSString alloc] initWithFormat:@"%dmo", (intervalSec / (60 * 60 * 24 * 30))];    

  }
  return [passedString autorelease];
}

/**
 * @brief 特別な色のセルにするかどうかを判断する。このメソッドは継承先でオーバーライドされます。
 */
- (BOOL)checkSpecialCell:(NSDictionary *)data {

  return NO;
}

/**
 * @brief データからユーザが使用しているクライアント名を返します。
 */
- (NSString *)clientname:(NSDictionary *)data {

  return [self.appDelegate clientname:data];
}

/**
 * @brief データからユーザ名を返します。
 */
- (NSString *)username:(NSDictionary *)data {

  return [self.appDelegate username:data];
}

- (NSInteger)newOffset:(NSInteger)addCount {

  NSInteger totalOffset = 0;

  if ([timeline count] != addCount) {
    CGPoint offset = friendsTableView.contentOffset;
    totalOffset = offset.y;

    for (NSInteger i = 0; i < addCount; i++) {
      NSInteger cellViewHeight = kTimelineTableRowHeight;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
      
      cellViewHeight = cellViewHeight + [self lineOverFlowSize:[indexPath row]];
      totalOffset = totalOffset + cellViewHeight;
    }
  }

  return totalOffset;
}

- (CGFloat)lineHeightValue:(NSInteger)row {

  NSDictionary *data = [timeline objectAtIndex:row];

  NSString *rowText = [data objectForKey:@"text"];
  NSString *bodyText= [self.appDelegate stringByUnescapedString:rowText];
   
  CGSize bounds = CGSizeMake(320, 1000);
  UIFont *font = [UIFont systemFontOfSize:17];
  CGSize size = [bodyText sizeWithFont:font
			  constrainedToSize:bounds
			  lineBreakMode:UILineBreakModeTailTruncation];

  return size.height + 3.0f;
}

- (float)lineOverFlowSize:(NSInteger)row {

  CGFloat lineHeight = [self lineHeightValue:row];

  if (lineHeight <= kDefaultBodyTextHeight) {
    return 0.0f;
  }

  CGFloat overFlowSize = lineHeight - kDefaultBodyTextHeight;
  return (float)overFlowSize;
}

- (float)lineOverFlowSizeFromQueue:(NSInteger)row {

  NSNumber *overFlowNumber = [lineOverFlowQueue objectAtIndex:row];
  return [overFlowNumber floatValue];
}

- (void)queuingLineOverFlowSize {

  NSMutableArray *array = [[NSMutableArray alloc] init];
  NSInteger row = 0;

  for (NSDictionary *data in timeline) {
    [array addObject:[NSNumber numberWithFloat:[self lineOverFlowSize:row]]];
    row++;
  }

  self.lineOverFlowQueue = array;
  [array release];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {


  CGFloat overflow = [self lineOverFlowSizeFromQueue:[indexPath row]];
  return kTimelineTableRowHeight + overflow;
}

#pragma mark -
#pragma mark IBAction Methods

- (void)openUserInformationView:(id)sender {

  NSInteger tagIndex = [sender tag];
  NSDictionary *timelineData = [timeline objectAtIndex:tagIndex];
  NSString *username = [self username:timelineData];

  UserInformationViewController *viewController = 
    [[UserInformationViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
  [viewController release];
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark -
#pragma mark Local Methods

- (void)openEditView:(AccountLabelButton *)button {

  NSString *username = [self.appDelegate username:button.data];
  NSString *replyString = [[NSString alloc] initWithFormat:@"@%@ ", username];
  NSString *sourceString = [button.data objectForKey:@"text"];

  SendTweetViewController *viewController = 
    [[SendTweetViewController alloc] initWithNibName:@"SendTweetViewController"
				     bundle:nil];
  viewController.defaultTweetString = replyString;
  viewController.inReplyToStatusId = [button.data objectForKey:@"id"];
  viewController.sourceString = sourceString;

  [replyString release];

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Tweet"  imageName:nil];
  [viewController release];

  [self presentModalViewController:navController animated:YES];
}

- (NSNumber *)lastTweetId {

  if (timeline == nil || [timeline count] <= 0) {
    return nil;
  }

  NSDictionary *lastTweet = [timeline objectAtIndex:0];
  NSNumber *lastId = [lastTweet objectForKey:@"id"];
  return lastId;
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end


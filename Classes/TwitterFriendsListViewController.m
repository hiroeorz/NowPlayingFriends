//
//  TwitterFriendsListViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 11/01/15.
//  Copyright 2011 hiroe_orz17. All rights reserved.
//

#import "NowPlayingFriendsAppDelegate.h"
#import "SendTweetViewController.h"
#import "TwitterFriendsGetter.h"
#import "TwitterFriendsListViewController.h"


@interface TwitterFriendsListViewController (Local)

- (void)addRecentFriendToFile:(NSString *)friendName;
- (NSString *)recentFriendFilePath;
- (NSMutableArray *)arrayOfRecentFriends;
@end


@implementation TwitterFriendsListViewController

@dynamic appDelegate;
@synthesize friends;
@synthesize initials;
@synthesize selectedName;
@synthesize tweetViewController;

- (void)dealloc {

  [friends release];
  [initials release];
  [selectedName release];
  [tweetViewController release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.friends = nil;
  self.initials = nil;
  self.selectedName = nil;
  self.tweetViewController = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [friends release];
  [initials release];
  self.friends = nil;
  self.initials = nil;
  [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate cancelButton:@selector(cancel:) target:self];
  
  TwitterFriendsGetter *getter = [[TwitterFriendsGetter alloc] init];
  NSString *filePath = [getter filePath];
  [getter release];

  NSArray *array = nil;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
  } else {
    array = [[NSMutableArray alloc] init];
  }
  
  NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
  
  for (NSString *screen_name in array) {
    NSString *initialChar = 
      [[screen_name substringWithRange:NSMakeRange(0, 1)] lowercaseString];

    if ([dic objectForKey:initialChar] == nil) {
      [dic setObject:[NSMutableArray array] forKey:initialChar];
    }

    NSMutableArray *aArray = [dic objectForKey:initialChar];
    [aArray addObject:screen_name];
  }

  [array release];

  for (NSString *key in dic) {
    NSMutableArray *namesArray = [dic objectForKey:key];
    [namesArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
  }

  self.friends = dic;
  [dic release];

  NSArray *keys = 
    [[dic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

  NSMutableArray *mutableKeys = [[NSMutableArray alloc] initWithArray:keys];

  NSMutableArray *recentFriends = [self arrayOfRecentFriends];

  if ([recentFriends count] > 0) {
    [friends setObject:recentFriends forKey:kRecentFriendsGroupName];
    [mutableKeys insertObject:kRecentFriendsGroupName atIndex:0];
  }

  self.initials = mutableKeys;
  [mutableKeys release];
}

- (void)viewDidAppear:(BOOL)animated {  
}

- (void)viewDidDisappear:(BOOL)animated {

  if (selectedName != nil) {
    [tweetViewController addScreenName:selectedName];
  }
}

#pragma mark -
#pragma IBAction Methods

- (IBAction)cancel:(id)sender {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma Table View Data Source Methods

/**
 * @brief セクションの数を返す。
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

  return [initials count];
}

/**
 * @brief セクションのタイトルを返す。
 */
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
  
  NSString *key = [initials objectAtIndex:section];
  return key;
}

/**
 * @brief 画面右に表示するセクションのインデックスの配列を返す。
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
  return initials;
}

/**
 * @brief 現在アクティブなセクションのテーブルのセルの数を返す。
 */
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {

  NSString *key = [initials objectAtIndex:section];
  NSArray *namesArray = [friends objectForKey:key];
  return [namesArray count];
}

/**
 * @brief 端末リストのテーブルセルを生成する。
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSUInteger section = [indexPath section];
  NSUInteger row = [indexPath row];

  static NSString *cellIdentifier = @"TwitterFriendsListCellIdentifier";

  UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

  if (cell == nil) {
    cell = [[[UITableViewCell alloc] 
	      initWithStyle:UITableViewCellStyleDefault 
	      reuseIdentifier:cellIdentifier] autorelease];
  }

  NSString *key = [initials objectAtIndex:section];
  NSArray *namesArray = [friends objectForKey:key];
  NSString *screen_name = [namesArray objectAtIndex:row];

  cell.textLabel.text = screen_name;
  return cell;
}

#pragma mark -
#pragma mark UITableView Delegate Methods

/**
 * @brief ユーザが端末のセルをタップした際に呼び出される。
 */
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  NSString *key = [initials objectAtIndex:[indexPath section]];
  NSArray *namesArray = [friends objectForKey:key];
  self.selectedName = [namesArray objectAtIndex:[indexPath row]];

  [self addRecentFriendToFile:selectedName];
  [self dismissModalViewControllerAnimated:YES];

  return indexPath;
}

/**
 * @brief ユーザが右側のインデックスをタップした際に呼び出される。
 *        虫眼鏡をタップしたら検索バーを表示する。
 */
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
	       atIndex:(NSInteger)index {
  return index;
}


#pragma mark -
#pragma Local Methods

- (NSMutableArray *)arrayOfRecentFriends {

  NSString *filePath = [self recentFriendFilePath];
  NSMutableArray *array = nil;

  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
  } else {
    array = [[NSMutableArray alloc] init];
  }

  return [array autorelease];
}

- (void)addRecentFriendToFile:(NSString *)friendName {

  NSString *filePath = [self recentFriendFilePath];
  NSMutableArray *array = [self arrayOfRecentFriends];
  BOOL hasObject = NO;
  
  for (NSString *name in array) {
    if ([name compare:friendName] == NSOrderedSame) {
      hasObject = YES;
    }
  }

  if (hasObject == NO) {
    [array insertObject:friendName atIndex:0];
  }

  if ([array count] > kRecentFriendMaxCount) {
    [array removeLastObject];
  }

  NSLog(@"add: %@ to File: %@", array, filePath);
  [array writeToFile:filePath atomically:YES];
}

- (NSString *)recentFriendFilePath {

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
						       NSUserDomainMask, YES);  
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString *filePath = 
    [documentsDirectory stringByAppendingPathComponent:kRecentFriendsFileName];

  return filePath;
}


- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

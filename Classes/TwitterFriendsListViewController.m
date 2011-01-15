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

    NSMutableArray *array = [dic objectForKey:initialChar];
    [array addObject:screen_name];
  }

  for (NSString *key in dic) {
    NSMutableArray *namesArray = [dic objectForKey:key];
    [namesArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
  }

  self.friends = dic;
  [dic release];

  NSArray *keys = 
    [[dic allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

  self.initials = keys;
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
  /*
  id initial = [areas objectAtIndex:index];

  if ([area class] == [UITableViewIndexSearch class]) {
    [table setContentOffset:CGPointZero animated:YES];
    return NSNotFound;
  }
  */

  return index;
}


#pragma mark -
#pragma Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

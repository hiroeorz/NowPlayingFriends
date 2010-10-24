//
//  SettingViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/10/24.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import "SettingViewController.h"

#import "SendTweetViewController.h"
#import "NowPlayingFriendsAppDelegate.h"


@interface SettingViewController (Local)

- (NowPlayingFriendsAppDelegate *)appDelegate;
@end

@implementation SettingViewController

@synthesize resignButton;
@synthesize templateField;

- (void)dealloc {

  [resignButton release];
  [templateField release];
  [super dealloc];
}

- (void)viewDidUnload {

  self.resignButton = nil;
  self.templateField = nil;
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (id)initWithNibName:(NSString *)nibNameOrNil 
	       bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
  return self;
}

- (void)viewDidLoad {

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate completeButton:@selector(resignSettingField:) 
	 target:self];

  [super viewDidLoad];
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction)resignSettingField:(id)sender {

  [templateField resignFirstResponder];
}

- (IBAction)resetTemplete:(id)sender {

  templateField.text = kTweetTemplate;
  self.appDelegate.template_preference = kTweetTemplate;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
  
  NSInteger rowsCount = 0;

  switch (section) {
  case 0: rowsCount = 3;
    break;
  case 1: rowsCount = 1;
    break;
  }

  return rowsCount;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {

  NSString* sectionTitle;

  switch (section) {
  case 0: sectionTitle = @"Tweet Templete";
    break;
  case 1: sectionTitle = @"Tweet Settings";
    break;
  }

  return sectionTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
	 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *SettingCellIdentifier = @"SettingCell";
  static NSString *TemplateCellIdentifier = @"TemplateSettingCell";
  UITableViewCell *cell = nil;

  if ([indexPath section] == 0 && [indexPath row] == 0) {
    cell = [tableView dequeueReusableCellWithIdentifier:
			TemplateCellIdentifier];

    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:TemplateCellIdentifier];
      [cell autorelease];

      UITextView *aTextView = [[[UITextView alloc] init] autorelease];
      setTweetEditField(aTextView, 20.0f, 270.0f, 90.0f);
      aTextView.delegate = self;
      self.templateField = aTextView;
      [cell addSubview: aTextView];
    }

  } else {
    cell = [tableView dequeueReusableCellWithIdentifier:SettingCellIdentifier];
    
    if (cell == nil) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				      reuseIdentifier:SettingCellIdentifier];
      [cell autorelease];
    }
  }

  switch ([indexPath section]) {
  case 0: {

    switch ([indexPath row]) {
    case 0: {
      templateField.text = [self.appDelegate template_preference];
    }
      break;

    case 1: {
      cell.textLabel.font = [UIFont systemFontOfSize:12];
      cell.textLabel.text = 
	@"[al]:Album Name  [ar]:Artist Name  [st]:Song Title";
    }
      break;
    case 2: {
      NSLog(@"22222");
      UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      [aButton setFrame:CGRectMake(110.0f, 2.0f, 100.0f, 40.0f)]; 
      [aButton setTitle:@"Reset" forState:UIControlStateNormal];
      [aButton addTarget:self action:@selector(resetTemplete:) 
	       forControlEvents:UIControlEventTouchUpInside];
      [cell addSubview:aButton];
    }
      break;
    }

    break;
  }
  }

  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {

  CGFloat cellHeight = 0.0f;

  switch ([indexPath section]) {
  case 0: {
    if ([indexPath row] == 0) {
      cellHeight = 110.0f;
    } else {
      cellHeight = 45.0f;
    }
  }
    break;
  case 1: cellHeight = 45.0f;
    break;
  }
  
  return cellHeight;
}

#pragma mark -
#pragma mark UITextView Delegate Methods

- (BOOL)textView:(UITextView *)textView 
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

  //self.appDelegate.template_preference = templateField.text;
  return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

  self.appDelegate.template_preference = templateField.text;
}

#pragma mark -
#pragma mark Local Methods

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

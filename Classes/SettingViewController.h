//
//  SettingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/10/24.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SettingViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>{

  UIButton *resignButton;
  UITextView *templateField;
}

@property (nonatomic, retain) IBOutlet  UIButton *resignButton;
@property (nonatomic, retain) UITextView *templateField;

- (IBAction)resignSettingField:(id)sender;

@end

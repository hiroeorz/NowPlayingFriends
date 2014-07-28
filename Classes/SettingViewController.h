//
//  SettingViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/10/24.
//  Copyright 2010 hiroe_orz17. All rights reserved.
//

#import <UIKit/UIKit.h>


#define setTemplateEditField(aEditView, kXPosition, kYPosition, kWidth, kHeight)  \
                          CGRect frame;	      \
                          frame.origin.x = kXPosition; \
                          frame.origin.y = kYPosition; \
                          frame.size.width = kWidth; \
                          frame.size.height = kHeight; \
                          aEditView.backgroundColor = [UIColor whiteColor]; \
                          aEditView.textColor = [UIColor blackColor]; \
                          aEditView.font = [UIFont systemFontOfSize:15]; \
                          aEditView.frame = frame;


@interface SettingViewController : UIViewController 
<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>{

  UIButton *resignButton;
  UITextView *templateField;
}

@property (nonatomic, retain) IBOutlet  UIButton *resignButton;
@property (nonatomic, retain) UITextView *templateField;

- (IBAction)resignSettingField:(id)sender;

@end

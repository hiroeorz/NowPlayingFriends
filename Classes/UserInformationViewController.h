//
//  UserInformationViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UserInformationViewController : UIViewController {

@private
  NSString *username;
}

@property (nonatomic, retain) NSString *username;

- (id)initWithUserName:(NSString *)newUsername;

- (void)getUserInformation;

@end

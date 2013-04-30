//
//  FacebookClient.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 13/04/30.
//  Copyright (c) 2013年 hiroe_orz17. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define kFBPictureSizeHeight 170
#define kFBPictureSizeWidth 170

@class NowPlayingFriendsAppDelegate;


@interface FacebookClient : NSObject {
}

@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, strong) NSDictionary *youtubeSearchResult;
@property (nonatomic, strong) UIImage *pictureImage;

- (IBAction)postMessage:(NSString *)message callback:(void (^)(void))callback;
@end

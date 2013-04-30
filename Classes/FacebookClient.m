//
//  FacebookClient.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 13/04/30.
//  Copyright (c) 2013年 hiroe_orz17. All rights reserved.
//

#import "FacebookClient.h"

#import "NowPlayingFriendsAppDelegate.h"


@implementation FacebookClient

@dynamic appDelegate;
@synthesize youtubeSearchResult = _youtubeSearchResult;
@synthesize pictureImage = _pictureImage;

- (IBAction)postMessage:(NSString *)message callback:(void (^)(void))callback {

  if (self.youtubeSearchResult != nil) { /* YouTube埋込み */
    NSLog(@"youtube search result: %@", self.youtubeSearchResult);
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease];
    NSString *thumbnailUrl = [self.youtubeSearchResult objectForKey:@"thumbnailUrl"];
    NSString *contentUrl = [self.youtubeSearchResult objectForKey:@"contentUrl"];
    NSString *linkUrl = [self.youtubeSearchResult objectForKey:@"linkUrl"];
    [params setObject:message forKey:@"message"];
    [params setObject:contentUrl forKey:@"source"];
    [params setObject:thumbnailUrl forKey:@"picture"];
    [params setObject:linkUrl forKey:@"link"];
    
    [self performFBPublishWithCallback:^{
	[FBRequestConnection startWithGraphPath:@"me/feed"
				     parameters:params
				     HTTPMethod:@"POST"
			      completionHandler:^(FBRequestConnection *connection, id result, 
						  NSError *error) { callback(); } ]; }
    permission:@"publish_stream"];
    return;
  }

  if (self.pictureImage != nil) { /* アルバム画像アップロード */
    NSLog(@"sending picture post to facebook");
    NSMutableDictionary* params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:message forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(self.pictureImage) forKey:@"picture"];
    
    [self performFBPublishWithCallback:^{
	[FBRequestConnection startWithGraphPath:@"me/photos"
				     parameters:params
				     HTTPMethod:@"POST"
			      completionHandler:^(FBRequestConnection *connection, id result, 
						  NSError *error) { callback(); }]; }
    permission:@"publish_stream"];
    return;
  }

  [self performFBPublishWithCallback:^{
      [FBRequestConnection startForPostStatusUpdate:message
				  completionHandler:^(FBRequestConnection *connection, id result, 
						      NSError *error) { callback(); }]; }
  permission:@"publish_actions"];
}

/*
  everyone: FBSessionDefaultAudienceEveryone
  friend:   FBSessionDefaultAudienceFriends
*/
- (void)performFBPublishWithCallback:(void (^)(void))callback permission:(NSString *)permission {
  if ([FBSession.activeSession.permissions indexOfObject:permission] == NSNotFound) {
    [FBSession.activeSession requestNewPublishPermissions:@[permission]
					  defaultAudience:FBSessionDefaultAudienceFriends
					completionHandler:^(FBSession *session, NSError *error) {
	                                  if (!error) { callback(); } }];
  } else {
    callback();
  }  
}

- (void)showFBFailAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {

  if (error == nil) { return; }
  
  NSString *alertMsg;
  NSString *alertTitle;
  alertTitle = @"Error";
  
  if (error.fberrorShouldNotifyUser ||
      error.fberrorCategory == FBErrorCategoryPermissions ||
      error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
    alertMsg = error.fberrorUserMessage;
  } else {
    alertMsg = @"Operation failed due to a connection problem, retry later.";
  }
  
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
						      message:alertMsg
						     delegate:nil
					    cancelButtonTitle:@"OK"
					    otherButtonTitles:nil];
  [alertView show];
  [alertMsg release];
  [alertTitle release];
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

@end

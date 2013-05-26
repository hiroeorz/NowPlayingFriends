//
//  SendTweetViewController.m
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ITunesStore.h"

#import <CoreLocation/CoreLocation.h>
#import "FacebookClient.h"
#import "MusicPlayerViewController.h"
#import "NowPlayingFriendsAppDelegate.h"
#import "SendTweetViewController.h"
#import "TwitterFriendsListViewController.h"
#import "YouTubeClient.h"
#import "YouTubeListViewController.h"
#import "YoutubeTypeSelectViewController.h"


#define kSelectSNSButtonDisabledAlpha 0.5f


@interface SendTweetViewController (Local)
- (void)stopIndicator;
- (void)stopIndicatoWithThread;
- (void)setYouTubeLinkedTweet;
- (void)addITunesStoreSearchLink:(NSString *)linkUrl;
- (void)setAlbumArtworkButtonStyle;
@end

@implementation SendTweetViewController

@dynamic appDelegate;
@synthesize addAlbumArtworkButton;
@synthesize defaultTweetString;
@synthesize editView;
@synthesize inReplyToStatusId;
@synthesize indicator;
@synthesize indicatorBase;
@synthesize isSendToFacabookSwitch;
@synthesize isSendToTwitterSwitch;
@synthesize letterCountLabel;
@synthesize musicPlayer;
@synthesize retweetButton;
@synthesize selectSNSButton;
@synthesize snsSelectViewFacebook;
@synthesize sourceString;
@synthesize twitterClient;

/* Facebook */
@synthesize buttonPostStatus;
@synthesize buttonPostPhoto;
@synthesize buttonPickFriends;
@synthesize buttonPickPlace;
@synthesize labelFirstName;
@synthesize loggedInUser;
@synthesize profilePic;

- (void)dealloc {

  [addAlbumArtworkButton release];
  [editView release];
  [inReplyToStatusId release];
  [indicator release];
  [indicatorBase release];
  [letterCountLabel release];
  [musicPlayer release];
  [retweetButton release];
  [sourceString release];
  [twitterClient release];
  [snsSelectViewFacebook release];
  [isSendToFacabookSwitch release];
  [isSendToTwitterSwitch release];
  [youtubeSearchResult release];

  [buttonPickFriends release];
  [buttonPickPlace release];
  [buttonPostPhoto release];
  [buttonPostStatus release];
  [labelFirstName release];
  [loggedInUser release];
  [profilePic release];

  [super dealloc];
}

- (void)viewDidUnload {

  linkAdded = NO;
  self.addAlbumArtworkButton = nil;
  self.editView = nil;
  self.inReplyToStatusId = nil;
  self.indicator = nil;
  self.indicatorBase = nil;
  self.letterCountLabel = nil;
  self.retweetButton = nil;
  self.snsSelectViewFacebook = nil;

  /* Facebook */
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {

  [super didReceiveMemoryWarning];
}
  
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    twitterClient = [[TwitterClient alloc] init];
    editView = [[UITextView alloc] init];
    defaultTweetString = nil;
    inReplyToStatusId = nil;
    linkAdded = NO;
  }
  return self;
}

- (void)setFacebookLoginView {
  FBLoginView *loginview = [[FBLoginView alloc] init];
  loginview.frame = CGRectOffset(loginview.frame, 22, 10);
  loginview.delegate = self;
  [self.snsSelectViewFacebook addSubview:loginview];
  [loginview sizeToFit];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  sending = NO;
  addAlbumArtwork = [self.appDelegate manual_upload_picture_preference];

  self.navigationItem.leftBarButtonItem = 
    [self.appDelegate cancelButton:@selector(closeEditView) target:self];

  self.navigationItem.rightBarButtonItem = 
    [self.appDelegate sendButton:@selector(sendTweet) target:self];

  if (defaultTweetString == nil || sourceString == nil) {
    [retweetButton removeFromSuperview];
  }

  setTweetEditField(editView, 5.0f, 270.0f, 118.0f);
  editView.delegate = self;
  [self.view addSubview:editView];

  if (defaultTweetString != nil) { /* 通常のツイート*/
    editView.text = defaultTweetString;
  } else {                         /* 楽曲ツイート */

    if (linkAdded == NO) {
      editView.text = [self.appDelegate tweetString];
      
      if ([self.appDelegate use_itunes_manual_preference]) {
	[self addITunesStoreSearchTweet:nil];
      } else if ([self.appDelegate use_youtube_manual_preference]) {
	[self setYouTubeLinkedTweet];
      }

      linkAdded = YES;
    }
  }

  [self setFacebookLoginView];
  [self setSelectSNSSwitch];
  selectSNSButton.enabled = NO;
  selectSNSButton.alpha = kSelectSNSButtonDisabledAlpha;
}

- (void)setSelectSNSSwitch {

  isSendToFacabookSwitch.on = self.appDelegate.fb_post_preference;
  isSendToTwitterSwitch.on = self.appDelegate.tw_post_preference;
}

- (void)viewWillAppear:(BOOL)animated {

  [super viewWillAppear:animated];
  [self setAlbumArtworkButtonStyle];
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)addITunesStoreSearchLink:(NSString *)linkUrl {

  [self performSelectorInBackground:@selector(stopIndicatoWithThread)
  	withObject:nil];

  if (linkUrl != nil) {
    editView.text = [[[NSString alloc] 
		       initWithFormat:@"%@ iTunes: %@", editView.text, linkUrl] 
		      autorelease];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Error"
			   message:@"Connection Error."
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

- (void)addScreenName:(NSString *)screenName {

  editView.text = [[[NSString alloc] 
		     initWithFormat:@"%@ @%@", editView.text, screenName] 
		    autorelease];
}

- (void)addYouTubeLink:(NSArray *)searchResults {

  [self performSelectorInBackground:@selector(stopIndicatoWithThread)
  	withObject:nil];

  NSString *linkUrl = nil;

  if ([searchResults count] > 0) {
    NSDictionary *dic = [searchResults objectAtIndex:0];
    NSLog(@"youtube: %@", dic);
    linkUrl = [dic objectForKey:@"linkUrl"];

    [dic retain];[youtubeSearchResult release];
    youtubeSearchResult = dic;
  }

  if (linkUrl != nil) {
    editView.text = [[[NSString alloc] 
		       initWithFormat:@"%@ %@", editView.text, linkUrl] 
		      autorelease];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Search Failure"
			   message:@"Cannot find a movie on YouTube."
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  }
}

- (void)viewDidAppear:(BOOL)animated {

  [super viewDidAppear:animated];
  [self countAndWriteTweetLength:[editView.text length]];
}

#pragma mark

- (void)closeEditView {

  sending = NO;
  [self dismissModalViewControllerAnimated:YES];
}

- (void)sendTweet {

  if (kMaxTweetLength < [editView.text length]) {
        UIAlertView *alert = [[UIAlertView alloc] 
			   initWithTitle:@"Can't send tweet"
			   message:@"Over 140 characters."
			   delegate:nil
			   cancelButtonTitle:@"OK"
			   otherButtonTitles:nil];
    [alert show];
    [alert release];
  }

  if (sending == NO && kMaxTweetLength >= [editView.text length]) {

    if (isSendToTwitterSwitch.on || isSendToFacabookSwitch.on) {
      sending = YES;
      musicPlayer.sending = YES;
      editView.backgroundColor = [UIColor colorWithRed: 0.6f green:0.6f blue:0.6f alpha:0.9];
      editView.editable = NO;
      editView.delegate = self;
      [self startIndicator];
    }

    if (isSendToTwitterSwitch.on) {
      [twitterClient updateStatus:editView.text 
		inReplyToStatusId:inReplyToStatusId
		      withArtwork:addAlbumArtwork
			 delegate:self];
    } else {
      if (isSendToFacabookSwitch.on) { [self postFBStatusUpdate:editView.text]; }
    }
  }
}

- (IBAction)changeFacebookSelectStatus:(UISwitch *)sender {
  self.appDelegate.fb_post_preference = sender.on;
}

- (IBAction)changeTwitterSelectStatus:(UISwitch *)sender {
  self.appDelegate.tw_post_preference = sender.on;
}

- (IBAction)showSNSSelectView:(id)sender {
  [editView resignFirstResponder];
}

- (IBAction)toggleAddAlbumArtworkFlag:(id)sender {
  addAlbumArtwork = !addAlbumArtwork;
  [self setAlbumArtworkButtonStyle];
}

- (void)setAlbumArtworkButtonStyle {

  if (addAlbumArtwork) {
    UIImage *artworkImage = [self.appDelegate currentMusicArtWorkWithWidth:35
				 height:35
				 useDefault:NO];
    if (artworkImage == nil) {
      addAlbumArtwork = NO;
    } else {
      [addAlbumArtworkButton setImage:artworkImage 
			     forState:UIControlStateNormal];
    }
  } else {
    [addAlbumArtworkButton setImage:[UIImage imageNamed:@"68-paperclip.png"]
			   forState:UIControlStateNormal];
  }
}

- (IBAction)clearText:(id)sender {
  editView.text = @"";
}

- (IBAction)setRetweetString:(id)sender {

  NSString *retweetBody = [[NSString alloc] initWithFormat:@"RT %@%@",
					    defaultTweetString,
					    sourceString];
  editView.text = retweetBody;
  [retweetBody release];
}

- (void)setYouTubeLinkedTweet {
    [self startIndicator];
    YouTubeClient *youtube = [[[YouTubeClient alloc] init] autorelease];

    [youtube searchWithTitle:[self.appDelegate nowPlayingTitle] 
	     artist:[self.appDelegate nowPlayingArtistName]
	     delegate:self
	     action:@selector(addYouTubeLink:)
	     count:1];
}

- (IBAction)addYouTubeTweet:(id)sender {

  switch(self.appDelegate.select_youtube_link_preference) {
  case kSelectYouTubeTypeTopOfSerach: {
    [self setYouTubeLinkedTweet];
    }
    break;

  case kSelectYouTubeTypeSelectFromList: {
      YouTubeListViewController *viewController = 
	[[YouTubeListViewController alloc] 
	  initWithNibName:@"YouTubeListViewController" bundle:nil];
      
      viewController.tweetViewController = self;
      
      UINavigationController *navController = 
	[self.appDelegate navigationWithViewController:viewController
	     title:nil  imageName:nil];
      [viewController release];
      
      [self presentModalViewController:navController animated:YES];
    }
    break;

  case kSelectYouTubeTypeConfirmation: {
      YoutubeTypeSelectViewController *viewController = 
	[[YoutubeTypeSelectViewController alloc] 
	  initWithNibName:@"YoutubeTypeSelectViewController" bundle:nil];
      
      viewController.tweetViewController = self;
      
      [self presentModalViewController:viewController animated:YES];
      [viewController release];
    }
    break;
  }
}

- (IBAction)addITunesStoreSearchTweet:(id)sender {

  [self startIndicator];
  ITunesStore *store = [[[ITunesStore alloc] init] autorelease];
  [store searchLinkUrlWithTitle:[self.appDelegate nowPlayingTitle] 
	 album:[self.appDelegate nowPlayingAlbumTitle]
	 artist:[self.appDelegate nowPlayingArtistName]
	 delegate:self 
	 action:@selector(addITunesStoreSearchLink:)];
}

- (IBAction)openTwitterFriendsViewController:(id)sender {

  TwitterFriendsListViewController *viewController =
    [[TwitterFriendsListViewController alloc] 
      initWithNibName:@"TwitterFriendsListViewController"
      bundle:nil];

  viewController.tweetViewController = self;

  UINavigationController *navController = 
    [self.appDelegate navigationWithViewController:viewController
	 title:@"Friends"  imageName:nil];
  [viewController release];

  [self presentModalViewController:navController animated:YES];
}

#pragma mark -
#pragma mark UITextView Delegate Methods

- (void)countAndWriteTweetLength:(NSInteger)textcount {

  if (textcount > kMaxTweetLength) {
    letterCountLabel.textColor=[UIColor redColor];
  }else{
    letterCountLabel.textColor=[UIColor whiteColor];
  }

  letterCountLabel.text = [NSString stringWithFormat:@"%d",textcount];
}

- (BOOL)textView:(UITextView *)textView 
shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

  NSInteger textcount = [textView.text length] + [text length] - range.length;
  [self countAndWriteTweetLength:textcount];

  return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

  selectSNSButton.enabled = YES;
  selectSNSButton.alpha = 1.0f;
}

- (void)textViewDidEndEditing:(UITextView *)textView {

  selectSNSButton.enabled = NO;
  selectSNSButton.alpha = kSelectSNSButtonDisabledAlpha;
}

#pragma mark -
#pragma mark URLConnection Delegate Methods

- (void)ticket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {

  NSLog(@"didFinishWithData");
  sending = NO;
  musicPlayer.sending = NO;
  musicPlayer.sent = YES;

  NSString *dataString = [[NSString alloc] 
			   initWithData:data encoding:NSUTF8StringEncoding];

  NSLog(@"data: %@", dataString);
  [dataString release];

  if (isSendToFacabookSwitch.on) {
    [self postFBStatusUpdate:editView.text];
  } else {
    addAlbumArtwork = NO;
    [self performSelectorInBackground:@selector(stopIndicatoWithThread) withObject:nil];
    [self dismissModalViewControllerAnimated:YES];
  }
}

- (void)ticket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {

  NSLog(@"didFailWithError");
  sending = NO;
  musicPlayer.sending = NO;
  musicPlayer.sent = YES;
  addAlbumArtwork = NO;

  [self performSelectorInBackground:@selector(stopIndicatoWithThread)
  	withObject:nil];

  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  [self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Local Methods

- (void)stopIndicatoWithThread {

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [self stopIndicator];
  [pool release];
}

- (void)startIndicator {

  UIView *baseView = [[UIView alloc] 
		       initWithFrame:CGRectMake(0.0, 0.0, 
						self.view.frame.size.width,
						self.view.frame.size.height)];
  self.indicatorBase = baseView;
  [baseView release];

  UIColor *baseColor = [[UIColor alloc] initWithRed:0.0
					green:0.0
					blue:0.0
					alpha:0.4];
  indicatorBase.backgroundColor = baseColor;
  [baseColor release];

  UIActivityIndicatorView *indicatorView = 
    [[UIActivityIndicatorView alloc] 
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  indicatorView.frame = CGRectMake(135.0, 135.0, 50.0, 50.0);

  self.indicator = indicatorView;
  [indicatorView release];
    

  [indicatorBase addSubview:indicator];
  [self.view addSubview:indicatorBase];
  [indicator startAnimating];
}

- (void)stopIndicator {
  [indicator stopAnimating];
  [indicator removeFromSuperview];
  [indicatorBase removeFromSuperview];

  self.indicator = nil;
  self.indicatorBase = nil;
}

- (NowPlayingFriendsAppDelegate *)appDelegate {
  return [[UIApplication sharedApplication] delegate];
}

#pragma mark - FBLoginViewDelegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {

  NSLog(@"loginViewShowingLoggedInUser");
  isFacebookLoggedIn = YES;
  isSendToFacabookSwitch.enabled = YES;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {

  self.loggedInUser = user;
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {

  NSLog(@"loginViewShowingLoggedOutUser");
  NSLog(@"switch: %@", isSendToFacabookSwitch);
  isFacebookLoggedIn = NO;
  isSendToFacabookSwitch.on = NO;
  isSendToFacabookSwitch.enabled = NO;
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {

  NSLog(@"FBLoginView encountered an error=%@", error);
}

#pragma mark - FBPost

//FBSessionDefaultAudienceEveryone
//FBSessionDefaultAudienceFriends
- (void)performFBPublishAction:(void (^)(void)) action permission:(NSString *)permission {
  if ([FBSession.activeSession.permissions indexOfObject:permission] == NSNotFound) {
    [FBSession.activeSession requestNewPublishPermissions:@[permission]
					  defaultAudience:FBSessionDefaultAudienceFriends
					completionHandler:^(FBSession *session, NSError *error) {
	                                  if (!error) { action(); } }];
  } else {
    action();
  }  
}

- (IBAction)postFBStatusUpdate:(NSString *)message {

  FacebookClient *facebookClient = [[[FacebookClient alloc] init ] autorelease];

  if (youtubeSearchResult != nil) { /* YouTube埋込み */
    facebookClient.youtubeSearchResult = youtubeSearchResult;
  }

  if (addAlbumArtwork) { /* アルバム画像アップロード */
    facebookClient.pictureImage = [self.appDelegate 
				      currentMusicArtWorkWithWidth:kFBPictureSizeHeight
				      height:kFBPictureSizeWidth
				      useDefault:NO];
  }

  [facebookClient postMessage:message 
		     callback:^{
      [self performSelectorInBackground:@selector(stopIndicatoWithThread) withObject:nil];
      [self dismissModalViewControllerAnimated:YES];
    }];  
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

@end

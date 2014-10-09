#import "MusicPlayerViewController.h"
#import "MusicPlayerViewController+Local.h"


@implementation MusicPlayerViewController (Settings)

/**
 * @brief 音楽プレイヤー制御のボタンがタップされたときに呼ばれる。
 */
- (IBAction)changeMusicSegmentedControl:(id)sender {

  switch ([sender selectedSegmentIndex]) {
  case 0:
    [self skipToBeginningOrPreviousItem:sender];
    break;
  case 1:
    [self togglePlayStop:sender];
    break;
  case 2:
    [self skipToNextItem:sender];
    break;
  }
}

- (IBAction)changeRefreshType:(id)sender {
  
  subControlTouchCount ++;

  [self performSelectorInBackground:@selector(refreshProfileImages)
	withObject:nil];
}

- (void)openUserInformationView:(id)sender {

  NSInteger tagIndex = [sender tag];
  NSDictionary *timelineData = [timeline objectAtIndex:tagIndex];
  NSString *username = [self.appDelegate username:timelineData];
  NSLog(@"tupped user:%@", username);

  UserInformationViewController *viewController = 
    [[UserInformationViewController alloc] initWithUserName:username];

  [self.navigationController pushViewController:viewController animated:YES];
  [viewController release];
}

- (IBAction)changeAutoTweetMode:(id)sender {

  autoTweetMode = [sender isOn];
  self.appDelegate.autotweet_preference = [sender isOn];

  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying &&
      sent == NO && sending == NO) {
    [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
	  withObject:nil];    
  }
}

- (IBAction)changeFriendGetMode:(id)sender {
  
  NSLog(@"before change value is %@", 
	[NSNumber numberWithBool:self.appDelegate.get_twitterusers_preference]);

 switch ([sender selectedSegmentIndex]) {
 case 0: { //OFF
   NSLog(@"selected segment 0");
   cancelFlag = YES;
   self.appDelegate.get_twitterusers_preference = NO;
   [self releaseNowButtons];
   [self releaseProfileImageButtons];
 };
   break;
 case 1: { //ON
   NSLog(@"selected segment 1");
   cancelFlag = NO;
   self.appDelegate.get_twitterusers_preference = YES;
   [self performSelectorInBackground:@selector(refreshProfileImages)
	 withObject:nil];
 };
   break;
 }
}


- (IBAction)changeVolume:(id)sender {

    /* no use.
  if (musicPlayer.volume != volumeSlider.value) {
    musicPlayer.volume = volumeSlider.value;
  }
     */
}

/*
   MPMusicPlaybackStateStopped,
   MPMusicPlaybackStatePlaying,
   MPMusicPlaybackStatePaused,
   MPMusicPlaybackStateInterrupted,
   MPMusicPlaybackStateSeekingForward,
   MPMusicPlaybackStateSeekingBackward
 */
- (IBAction)togglePlayStop:(id)sender {

  if (musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
    [musicPlayer pause];
  } else {
    [musicPlayer play];
  }
}

- (IBAction)skipToNextItem:(id)sender {

  [musicPlayer skipToNextItem];
}

- (IBAction)skipToBeginningOrPreviousItem:(id)sender {

   if (musicPlayer.currentPlaybackTime < 3.0) {
     [musicPlayer skipToPreviousItem];
   } else {
     [musicPlayer skipToBeginning];
   }
}

- (IBAction)skipToPreviousItem:(id)sender {

  [musicPlayer skipToPreviousItem];
}

- (IBAction)changeShuffleMode:(id)sender {

  NSLog(@"changeShuffleMode:%d", [sender selectedSegmentIndex]);

 switch ([sender selectedSegmentIndex]) {
 case kShuffleModeNone:
   NSLog(@"0");
   musicPlayer.shuffleMode = MPMusicShuffleModeOff;
   break;
 case kShuffleModeOne:
   NSLog(@"1");
   musicPlayer.shuffleMode = MPMusicShuffleModeSongs;
   break;
 case kShuffleModeAll:
   NSLog(@"2");
   musicPlayer.shuffleMode = MPMusicShuffleModeAlbums;
   break;
 }
}

- (IBAction)changeRepeatMode:(id)sender {

  NSLog(@"changeRepeatMode:%d", [sender selectedSegmentIndex]);

 switch ([sender selectedSegmentIndex]) {
 case kRepeatModeNone:
   musicPlayer.repeatMode = MPMusicRepeatModeNone;
   break;
 case kRepeatModeOne:
   musicPlayer.repeatMode = MPMusicRepeatModeOne;
   break;
 case kRepeatModeAll:
   musicPlayer.repeatMode = MPMusicRepeatModeAll;
   break;
 }
}

- (IBAction)openSettingView:(id)sender {

  if (musicPlayer.shuffleMode == MPMusicShuffleModeOff) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeNone;    
  }
  if (musicPlayer.shuffleMode == MPMusicShuffleModeSongs) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeOne;    
  }
  if (musicPlayer.shuffleMode == MPMusicShuffleModeAlbums) {
    shuffleModeControll.selectedSegmentIndex = kShuffleModeAll;    
  }
  

  if (musicPlayer.repeatMode == MPMusicRepeatModeNone) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeNone;    
  }
  if (musicPlayer.repeatMode == MPMusicRepeatModeOne) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeOne;
  }
  if (musicPlayer.repeatMode == MPMusicRepeatModeAll) {
    repeatModeControll.selectedSegmentIndex = kRepeatModeAll;
  }

  if (self.appDelegate.get_twitterusers_preference) {
    friendGetModeControl.selectedSegmentIndex = 1;
  } else {
    friendGetModeControl.selectedSegmentIndex = 0;
  }

  [self.appDelegate setHalfCurlAnimationWithController:self
       frontView:songView
       curlUp:YES];

  [self.baseView addSubview:settingView];
  [self.view bringSubviewToFront:settingView];
  [UIView commitAnimations];
}

- (IBAction)closeSettingView:(id)sender {

  [self closeSettingView];
}

- (void)closeSettingView {

  [self.appDelegate setHalfCurlAnimationWithController:self
       frontView:songView
       curlUp:NO];
  
  if (settingView.superview != nil) {
    [settingView removeFromSuperview];
  }
  
  [self.view addSubview:songView];
  [UIView commitAnimations];
}


@end

#import "MusicPlayerViewController+Notification.h"
#import "MusicPlayerViewController+Local.h"


@implementation MusicPlayerViewController (Notification)

/**
 * @brief プレイヤーの制御状況が変化したときに呼ばれる。
 */
- (void)handle_PlayBackStateDidChanged:(id)notification {

  NSLog(@"Play State Changed!");
  [self stateLog];
  [self playBackStateDidChanged];
}

- (void)playBackStateDidChanged {
  
  UIImage *image = nil;  
  UIImage *miniImage = nil;

  updateAfterSafetyTime = NO;

  /* 停止 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
    image = [UIImage imageNamed:@"Play.png"];
    miniImage = [UIImage imageNamed:@"Play_mini.png"];
  }

  /* 再生中 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    image = [UIImage imageNamed:@"Pause.png"];
    miniImage = [UIImage imageNamed:@"Pause_mini.png"];
    if (autoTweetMode) {
      [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
			     withObject:nil];
    }
  }

  /* 一時停止中 */
  if ([musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
    image = [UIImage imageNamed:@"Play.png"];
    miniImage = [UIImage imageNamed:@"Play_mini.png"];
  }

  [playButton setImage:image forState:UIControlStateNormal];
  [musicSegmentedControl setImage:miniImage forSegmentAtIndex:1];

  [self setMusicArtwork];

  if (self.appDelegate.get_twitterusers_preference) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
			   withObject:nil];
  }
}

/**
 * @brief プレイヤーの音量が変化したときに呼ばれる。
 */
- (void)handle_VolumeChanged:(id)notification {
  
  if (volumeSlider.value != musicPlayer.volume) {
    volumeSlider.value = musicPlayer.volume;
  }
}

/**
 * @brief 再生中の曲が変わったときに呼ばれる。
 */
- (void)handle_NowPlayingItemChanged:(id)notification {

  NSLog(@"Music Item Changed!");
  [self stateLog];

  sent = NO;
  sending = NO;
  updateAfterSafetyTime = NO;

  [self setViewTitleAndMusicArtwork];

  autoTweetMode = self.appDelegate.autotweet_preference;
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (currentItem == nil && listView.superview == nil) {
    [self changeToListview];
  }

  if (self.appDelegate.get_twitterusers_preference) {
    [self performSelectorInBackground:@selector(refreshProfileImages)
			   withObject:nil];
  }

  if (autoTweetMode && 
      [musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
			   withObject:nil];
    sending = YES;
  }
}

@end

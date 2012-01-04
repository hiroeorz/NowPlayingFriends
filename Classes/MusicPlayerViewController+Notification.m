#import "MusicPlayerViewController+Local.h"


@implementation MusicPlayerViewController (Notification)

/**
 * @brief プレイヤーの制御状況が変化したときに呼ばれる。
 */
- (void)handle_PlayBackStateDidChanged:(id)notification {

  NSLog(@"=========================Play State Changed!");
  [self stateLog];
  [self playBackStateDidChanged];
}

- (void)playBackStateDidChanged {
  
  [self setMusicArtwork];
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

  /* アイコンを更新 */
  if (self.appDelegate.get_twitterusers_preference) {
    [self refreshProfileImagesIfChanged];
  }

  [playButton setImage:image forState:UIControlStateNormal];
  [musicSegmentedControl setImage:miniImage forSegmentAtIndex:1];
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

  NSLog(@"------------------------------Music Item Changed!");
  [self stateLog];

  sent = NO;
  sending = NO;
  updateAfterSafetyTime = NO;

  /* iOS5での曲選択時のデバイス側のタイミングに対応する為のコード。 */
  if ([musicPlayer playbackState] != MPMusicPlaybackStatePlaying) {
    self.recentSongTitle = [self.appDelegate nowPlayingTitle];
  }

  [self setViewTitleAndMusicArtwork];

  autoTweetMode = self.appDelegate.autotweet_preference;
  MPMediaItem *currentItem = [musicPlayer nowPlayingItem];

  if (self.appDelegate.get_twitterusers_preference) {
    [self refreshProfileImagesIfChanged];
  }

  if (autoTweetMode && 
      [musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
    [self performSelectorInBackground:@selector(sendAutoTweetAfterTimeLag)
			   withObject:nil];
    sending = YES;
  }
}

@end

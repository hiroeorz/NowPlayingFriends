#import "MusicPlayerViewController.h"

@interface MusicPlayerViewController (Notification)
- (void)handle_PlayBackStateDidChanged:(id)notification;
- (void)handle_VolumeChanged:(id)notification;
- (void)handle_NowPlayingItemChanged:(id)notification;
@end

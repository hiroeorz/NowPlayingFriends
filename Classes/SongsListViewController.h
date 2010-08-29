
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "NowPlayingFriendsAppDelegate.h"

@class MusicPlayerViewController;

@interface SongsListViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate> {

  MPMediaItemCollection *playlist;
  MPMusicPlayerController *musicPlayer;
  MusicPlayerViewController *musicPlayerViewController;
  UITableView *songListView;
}

@property (nonatomic, retain) MPMediaItemCollection *playlist;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MusicPlayerViewController *musicPlayerViewController;
@property (nonatomic, retain) UITableView *songListView;
@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;

- (id)initWithPlaylist:(MPMediaItemCollection *)newPlaylist;

@end

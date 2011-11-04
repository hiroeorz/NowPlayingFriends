
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "NowPlayingFriendsAppDelegate.h"

#define kAlbumListType 0
#define kPlayListType 1

@class MusicPlayerViewController;

@interface SongsListViewController : UIViewController <UITableViewDelegate> {

  MPMediaItemCollection *playlist;
  MPMusicPlayerController *musicPlayer;
  MusicPlayerViewController *musicPlayerViewController;
  UITableView *songListView;
  NSString *playListTitle;
  UIBarButtonItem *leftButtonItem;
}

@property (nonatomic, retain) MPMediaItemCollection *playlist;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain) MusicPlayerViewController *musicPlayerViewController;
@property (nonatomic, retain) UITableView *songListView;
@property (nonatomic, retain, readonly) NowPlayingFriendsAppDelegate *appDelegate;
@property (nonatomic, retain) NSString *playListTitle;
@property (nonatomic, retain) UIBarButtonItem *leftButtonItem;

- (NSInteger)playListType;
- (void)close;

@end

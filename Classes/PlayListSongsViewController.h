//
//  PlayListSongsViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class MusicPlayerViewController;

@interface PlayListSongsViewController : UITableViewController {

  MPMediaItemCollection *playlist;
  MPMusicPlayerController *musicPlayer;
  MusicPlayerViewController *musicPlayerViewController;
}

@property (nonatomic, retain) MPMediaItemCollection *playlist;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;
@property (nonatomic, retain)  MusicPlayerViewController *musicPlayerViewController;

- (id)initWithPlaylist:(MPMediaItemCollection *)newPlaylist;

@end

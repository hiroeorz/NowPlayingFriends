//
//  AlbumSongsViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AlbumSongsViewController : UITableViewController {

  MPMediaItemCollection *album;
  MPMusicPlayerController *musicPlayer;
}

@property (nonatomic, retain) MPMediaItemCollection *album;
@property (nonatomic, retain) MPMusicPlayerController *musicPlayer;

- (id)initWithAlbum:(MPMediaItemCollection *)newAlbum;

@end

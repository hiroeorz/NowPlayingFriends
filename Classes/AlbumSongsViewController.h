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

#import "MusicPlayerViewController.h"
#import "SongsListViewController.h"

@interface AlbumSongsViewController : SongsListViewController {

}


- (id)initWithAlbum:(MPMediaItemCollection *)newAlbum;

@end

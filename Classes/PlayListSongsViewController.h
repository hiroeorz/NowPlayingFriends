//
//  PlayListSongsViewController.h
//  NowPlayingFriends
//
//  Created by Hiroe Shin on 10/08/22.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SongsListViewController.h"

@class MusicPlayerViewController;

@interface PlayListSongsViewController : SongsListViewController 
<UITableViewDataSource> {

}

- (id)initWithPlaylist:(MPMediaItemCollection *)newPlaylist;

@end

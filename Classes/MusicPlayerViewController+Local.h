#import <QuartzCore/QuartzCore.h>

#import "MusicPlayerViewController.h"

#import "AlbumSongsViewController.h"
#import "ITunesStore.h"
#import "MusicPlayerViewController.h"
#import "PlayListSongsViewController.h"
#import "SendTweetViewController.h"
#import "UserAuthenticationViewController.h"
#import "UserInformationViewController.h"
#import "YouTubeClient.h"
#import "YouTubeListViewController.h"


#define kRefreshTypeSong 0
#define kRefreshTypeArtist 1
#define kRefreshTypeAll 2
#define kSubControlRemoteTimeout 6
#define kUpdateAfterSafetyTime 10


@interface MusicPlayerViewController (Local)

- (void)openUserInformationView:(id)sender;
- (void)setMusicArtwork;
- (void)removeDisplaySubview;
- (void)removeDisplaySubviewAfterSecond;
- (BOOL)checkNowPlayingUser:(NSDictionary *)data;
- (UIButton *)nowButton:(SEL)selector frame:(CGRect)frame;
- (UIButton *)playButton:(CGRect)frame;
- (UIButton *)refreshButton:(CGRect)frame;
- (void)closeSettingView;
- (void)addPlayButton;
- (void)addYouTubeButton;
- (void)addRefreshButton;
- (void)openEditView;
- (void)changeToListview;
- (void)changeToSongview;
- (UIControl *)songTitleViewControl;
- (UITextField *)songTitleField;
- (UITextField *)artistNameField;
- (NowPlayingFriendsAppDelegate *)appDelegate;
- (UIButton *)youTubeButton:(CGRect)frame;
- (void)stateLog;
@end

@interface MusicPlayerViewController (AutoTweet)
- (void)continuousTweetStopper;
- (void)sendAutoTweetAfterTimeLag;
- (void)sendAutoTweet;
- (void)sendAutoTweetDetail:(NSString *)message;
- (void)createMessageIncludeITunes:(NSString *)linkUrl;
- (void)createMessageIncludeYouTube:(NSArray *)linkUrlArray;
@end

@interface MusicPlayerViewController (FriendsIcon)
- (BOOL)refreshTimeline;
- (void)releaseNowButtons;
- (void)releaseProfileImageButtons;
- (void)setFriendImageView;
- (BOOL)checkTimelineUpdated:(NSArray *)newArray;
- (void)addProfileImageButton:(NSDictionary *)objects;
- (void)setBackgroundImage:(NSDictionary *)objects;
- (void)setBackgroundApha:(NSDictionary *)objects;
- (void)addNowButton:(NSDictionary *)objects;
@end

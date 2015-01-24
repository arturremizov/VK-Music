//
//  ARAudioItemsViewController.h
//  VK Music
//
//  Created by Artur Remizov on 05.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARViewController.h"
#import "ARServerManager.h"
#import "ARUser.h"
#import "ARAccessToken.h"

extern NSString * const ARAudioItemsViewControllerDidBecomeActiveNotification;

@class ARMusicControlView;
@class ARSearchItems;
@class ARBackwardButton, ARForwardButton;
@class ARRepeatButton, ARShuffleButton, ARBroadcastButton, ARAddSongButton;

@class ARAlbum;

@interface ARAudioItemsViewController : ARViewController

@property (assign, nonatomic) BOOL isActiveController;
@property (assign, nonatomic) BOOL isFirstPlaying;

@property (weak, nonatomic) IBOutlet UISearchBar* searchBar;
@property (strong, nonatomic) UIRefreshControl* refreshControl;

@property (strong, nonatomic) ARMusicControlView* musicControlView;

@property (strong, nonatomic) NSMutableArray* audioItems;
@property (strong, nonatomic) NSIndexPath* selectedIndexPath;
@property (strong, nonatomic) ARSearchItems* searchItems;
@property (strong, nonatomic) NSIndexPath* searchSelectedIndexPath;


@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isSearching;

@property (assign, nonatomic) NSInteger countAllSearchItems;
@property (assign, nonatomic) NSInteger countAllAudioItems;
@property (assign, nonatomic) BOOL isCanLoadMoreItems;

@property (strong, nonatomic) ARAlbum* album;

- (void) actionPlay;

- (void) getAudioItemsFromServer;
- (void) refreshAudioItems;
- (void) searchAudio:(NSString*) text newSearch:(BOOL) newSearch;

- (void) setInfoInFooterViewForItems:(NSInteger) count;

@end

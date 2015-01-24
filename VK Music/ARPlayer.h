//
//  ARPlayer.h
//  VK Music
//
//  Created by Artur Remizov on 18.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ARPlayerDidStartPlayNewItemNotification;
extern NSString * const ARPlayerNewAudioItemUserInfoKey;


@class AVPlayer;
@class AVPlayerItem;
@class ARAudioItem;
@class ARNowPlayingViewController;
@class ARAudioItemsViewController;
@class ARMusicControlView;


typedef enum {
    ARRepeatStateOff,
    ARRepeatStateOn,
    ARRepeatStateOneTrack
    
} ARRepeatState;


@interface ARPlayer : NSObject

@property (strong, nonatomic) AVPlayer* player;
@property (strong, nonatomic) AVPlayerItem* currentItem;
@property (assign, nonatomic) BOOL isNowPlaying;

@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) ARAudioItem* currentAudioItem;
@property (assign, nonatomic) ARRepeatState repeatState;
@property (assign, nonatomic) BOOL isBroadcasting;
@property (assign, nonatomic, setter = setShuffling:) BOOL isShuffling;

@property (assign, nonatomic) BOOL isSeeking;

@property (strong, nonatomic) ARMusicControlView* musicControlView;
@property (strong, nonatomic) ARAudioItemsViewController* activeAudioItemsViewController;
@property (strong, nonatomic) ARNowPlayingViewController* nowPlayingViewController;


+ (ARPlayer*) sharedPlayer;

- (void) playURL:(NSURL*) url;
- (void) playAudioItem:(ARAudioItem*) audioItem;

- (void) play;
- (void) pause;

- (void) getBroadcastFromServer;

@end

//
//  ARMusicControlView.h
//  VK Music
//
//  Created by Artur Remizov on 27.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//


#import <UIKit/UIKit.h>

extern NSString * const ARMusicControlViewActionBackwardNotification;
extern NSString * const ARMusicControlViewActionPlayNotification;
extern NSString * const ARMusicControlViewActionForwardNotification;

extern NSString * const ARMusicControlViewActionAddSongNotification;

@class ARBackwardButton,ARPlayButton, ARForwardButton;
@class MarqueeLabel;
@class MPVolumeView;
@class ARRepeatButton, ARShuffleButton, ARBroadcastButton, ARAddSongButton;

@interface ARMusicControlView : UIView

@property (strong, nonatomic) UIImageView* songArtworkView;

@property (strong, nonatomic) ARBackwardButton *backwardButton;
@property (strong, nonatomic) ARPlayButton *playButton;
@property (strong, nonatomic) ARForwardButton *forwardButton;


@property (strong, nonatomic) UIView *containerView;

@property (strong, nonatomic) UISlider* trackSlider;
@property (strong, nonatomic) UILabel* leftTrackLabel;
@property (strong, nonatomic) UILabel* rightTrackLabel;

@property (strong, nonatomic) MarqueeLabel* songInfoLabel;

@property (strong, nonatomic) MPVolumeView* volumeView;


@property (strong, nonatomic) ARRepeatButton* repeatButton;
@property (strong, nonatomic) ARShuffleButton* shuffleButton;
@property (strong, nonatomic) ARBroadcastButton* broadcastButton;
@property (strong, nonatomic) ARAddSongButton* addSongButton;



@property (assign, nonatomic) BOOL isControlsEnabled;
- (void) controlsEnabled:(BOOL) enabled;
- (void) resetControls;
    

@end

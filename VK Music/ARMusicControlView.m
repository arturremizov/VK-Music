//
//  ARMusicControlView.m
//  VK Music
//
//  Created by Artur Remizov on 27.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARMusicControlView.h"
#import "MarqueeLabel.h"
#import <MediaPlayer/MediaPlayer.h>

#import "ARBackwardButton.h"
#import "ARPlayButton.h"
#import "ARForwardButton.h"

#import "ARRepeatButton.h"
#import "ARShuffleButton.h"
#import "ARBroadcastButton.h"
#import "ARAddSongButton.h"

@implementation ARMusicControlView

NSString * const ARMusicControlViewActionBackwardNotification = @"ARMusicControlViewActionBackwardNotification";
NSString * const ARMusicControlViewActionPlayNotification = @"ARMusicControlViewActionPlayNotification";
NSString * const ARMusicControlViewActionForwardNotification = @"ARMusicControlViewActionForwardNotification";
NSString * const ARMusicControlViewActionAddSongNotification = @"ARMusicControlViewActionAddSongNotification";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        UIImageView* songArtworkView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 20, 35, 35)];
        songArtworkView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        songArtworkView.image = [UIImage imageNamed:@"music_cover.png"];
        [self addSubview:songArtworkView];
        self.songArtworkView = songArtworkView;
        
        
        self.backwardButton = [[ARBackwardButton alloc]initWithFrame:CGRectMake(70, 18, 40, 40)];
        self.backwardButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.backwardButton];
        
        
        
        self.playButton = [[ARPlayButton alloc]initWithFrame:CGRectMake(126, 18, 40, 40)];
        self.playButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.playButton];
        
        
        
        
        self.forwardButton = [[ARForwardButton alloc]initWithFrame:CGRectMake(182, 18, 40, 40)];
        self.forwardButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:self.forwardButton];
        
        
        
        UIView* containerView = [[UIView alloc]initWithFrame:CGRectMake(224, 0, 320, 75)];
        containerView.backgroundColor = [UIColor clearColor];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:containerView];
        self.containerView = containerView;
        
        
        UISlider* trackSlider = [[UISlider alloc]initWithFrame:CGRectMake(48, 4, 225, 34)];
        trackSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleBottomMargin;
        
        UIImage* trackThumbImage = [UIImage imageNamed:@"track_thumb_image.png"];
        [trackSlider setThumbImage:trackThumbImage forState:UIControlStateNormal];
        
        UIImage* trackImage = [UIImage imageNamed:@"track_image.png"];
        [trackSlider setMaximumTrackImage:trackImage forState:UIControlStateNormal];
        [trackSlider setMinimumTrackImage:trackImage forState:UIControlStateNormal];
        
        [containerView addSubview:trackSlider];
        self.trackSlider = trackSlider;
        
        
        
        _leftTrackLabel = [[UILabel alloc] initWithFrame:CGRectMake(-3, 12, 44, 18)];
        _leftTrackLabel.textAlignment = NSTextAlignmentRight;
        _leftTrackLabel.textColor = [UIColor blackColor];
        _leftTrackLabel.font = [UIFont systemFontOfSize:10.f];
        _leftTrackLabel.text = @"--:--";
        [containerView addSubview:_leftTrackLabel];
        
        _rightTrackLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 12, 44, 18)];
        _rightTrackLabel.textAlignment = NSTextAlignmentLeft;
        _rightTrackLabel.textColor = [UIColor blackColor];
        _rightTrackLabel.font = [UIFont systemFontOfSize:10.f];
        _rightTrackLabel.text = @"--:--";
        [containerView addSubview:_rightTrackLabel];
        
        _songInfoLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(30, 30, 260, 16)];
        
        _songInfoLabel.marqueeType = MLContinuous;
        _songInfoLabel.scrollDuration = 15.0;
        _songInfoLabel.continuousMarqueeExtraBuffer = 30.0f;
        _songInfoLabel.animationCurve = UIViewAnimationOptionCurveLinear;
        _songInfoLabel.textAlignment = NSTextAlignmentCenter;
        [containerView addSubview:_songInfoLabel];
        
        
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(48, 53, 224, 40)];
        _volumeView.showsRouteButton = NO;
        _volumeView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _volumeView.tintColor = [UIColor blackColor];
        
        UIImage* thumb = [UIImage imageNamed:@"slider-default7-handle.png"];
        [_volumeView setVolumeThumbImage:thumb forState:UIControlStateNormal];
        
        [_containerView addSubview:_volumeView];
        
        
        UIImage* maxImage = [UIImage imageNamed:@"media_volume_max.png"];
        UIImageView* maxImageView = [[UIImageView alloc]
                                     initWithFrame:CGRectMake(CGRectGetMaxX(_volumeView.frame) + 4,
                                                   51,
                                                   maxImage.size.width * 0.9,
                                                   maxImage.size.height * 0.9)];
        
        maxImageView.image = maxImage;
        maxImageView.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [_containerView addSubview:maxImageView];
        
        UIImage* minImage = [UIImage imageNamed:@"media_volume_min.png"];
        UIImageView* minImageView = [[UIImageView alloc]
                                     initWithFrame:CGRectMake(CGRectGetMinX(_volumeView.frame) - 20,
                                                              51,
                                                              maxImage.size.width * 0.9,
                                                              maxImage.size.height * 0.9)];
        minImageView.image = minImage;
        minImageView.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [_containerView addSubview:minImageView];
        
        
        self.repeatButton = [[ARRepeatButton alloc] initWithFrame:CGRectMake(550, 22, 32, 32)];
        self.repeatButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.repeatButton setContentEdgeInsets:UIEdgeInsetsMake(4, 5, 4, 5)];
        [self addSubview:self.repeatButton];
        
        
        
        self.shuffleButton = [[ARShuffleButton alloc] initWithFrame:CGRectMake(605, 22, 32, 32)];
        self.shuffleButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.shuffleButton setContentEdgeInsets:UIEdgeInsetsMake(4, 3, 4, 3)];
        [self addSubview:self.shuffleButton];
        
        
        
        self.broadcastButton = [[ARBroadcastButton alloc] initWithFrame:CGRectMake(660, 22, 32, 32)];
        self.broadcastButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.broadcastButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 1, 0)];
        [self addSubview:self.broadcastButton];

        
        
        self.addSongButton = [[ARAddSongButton alloc] initWithFrame:CGRectMake(715, 22, 32, 32)];
        self.addSongButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self.addSongButton setContentEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        self.addSongButton.enabled = NO;
        [self addSubview:self.addSongButton];
        
        
        [self controlsEnabled:NO];
        
    }
    return self;
}

- (void) controlsEnabled:(BOOL) enabled {
    
    self.isControlsEnabled = enabled;
    
    self.backwardButton.enabled = enabled;
    self.forwardButton.enabled = enabled;
    self.trackSlider.enabled = enabled;
    
    self.repeatButton.enabled = enabled;
    self.shuffleButton.enabled = enabled;
    self.broadcastButton.enabled = enabled;
    
    
}

- (void) resetControls {
    
    self.leftTrackLabel.text = @"--:--";
    self.rightTrackLabel.text = @"--:--";
    self.trackSlider.value = 0.0;
    self.songInfoLabel.text= nil;
}


@end

//
//  ARNowPlayingViewController.h
//  VK Music
//
//  Created by Artur Remizov on 28.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARAudioItem;
@class MarqueeLabel;
@class ARRepeatButton, ARShuffleButton, ARBroadcastButton, ARAddSongButton;
@class JCRBlurView;
@class ARBackwardButton,ARPlayButton, ARForwardButton;

@protocol ARNowPlayingViewControllerDelegate;

@interface ARNowPlayingViewController : UIViewController

@property (strong, nonatomic) ARAudioItem* currentAudioItem;


@property (strong, nonatomic) UIImageView* artwork;
@property (strong, nonatomic) UITextView* lyricsTextView;
@property (strong, nonatomic) JCRBlurView* blurView;
@property (strong, nonatomic) NSString* lyrics;

@property (strong, nonatomic) MarqueeLabel* titleLabel;
@property (strong, nonatomic) MarqueeLabel* artistLabel;

@property (strong, nonatomic) UISlider* trackSlider;
@property (strong, nonatomic) UILabel* leftTrackLabel;
@property (strong, nonatomic) UILabel* rightTrackLabel;

@property (strong, nonatomic) ARBackwardButton *backwardButton;
@property (strong, nonatomic) ARPlayButton *playButton;
@property (strong, nonatomic) ARForwardButton *forwardButton;


@property (strong, nonatomic) ARRepeatButton* repeatButton;
@property (strong, nonatomic) ARShuffleButton* shuffleButton;
@property (strong, nonatomic) ARBroadcastButton* broadcastButton;
@property (strong, nonatomic) ARAddSongButton* addSongButton;


- (void) setSongTitle:(NSString*) title atrist:(NSString*) artist;

- (void) getLyrics:(NSInteger) lyricsID;

@property (weak, nonatomic) id <ARNowPlayingViewControllerDelegate> delegate;

@end

@protocol ARNowPlayingViewControllerDelegate

- (void)nowPlayingViewControllerWillDismiss;

@end

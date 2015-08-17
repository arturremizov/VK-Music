//
//  ARNowPlayingViewController.m
//  VK Music
//
//  Created by Artur Remizov on 28.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARNowPlayingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ARMusicControlView.h"
#import "MarqueeLabel.h"
#import "ARPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JCRBlurView.h"

#import "ARRepeatButton.h"
#import "ARShuffleButton.h"
#import "ARBroadcastButton.h"
#import "ARAddSongButton.h"

#import "ARBackwardButton.h"
#import "ARPlayButton.h"
#import "ARForwardButton.h"

#import "ARAudioItem.h"
#import "ARServerManager.h"

@interface ARNowPlayingViewController ()

@property (strong, nonatomic) MPVolumeView* volumeView;
@property (strong, nonatomic) UIView* containerView;

@property (strong, nonatomic) ARMusicControlView* musicControlView;



@end

@implementation ARNowPlayingViewController

static CGFloat artworkPortraitSize = 768.f;
static CGFloat artworkViewLandscapeSize = 512.f;

static CGFloat containerViewPortraitWidth = 572.f;
static CGFloat containerViewLandscapeWidth = 410.f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:244/255.f alpha:1.f];
    
    
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, 60, 60)];
    [backButton setImage:[UIImage imageNamed:@"arrow-back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"arrow-back_h.png"] forState:UIControlStateHighlighted];
    [backButton setImageEdgeInsets:UIEdgeInsetsMake(-8, -10, 8, 10)];
    [backButton addTarget:self
                   action:@selector(actionDone:)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    
    
    
    MarqueeLabel* titleLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(self.view.center.x - 512.f/2, 30, 512.f, 25)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    titleLabel.marqueeType = MLContinuous;
    titleLabel.scrollDuration = 15.0;
    titleLabel.continuousMarqueeExtraBuffer = 40.0f;
    titleLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    
    
    MarqueeLabel* artistLabel = [[MarqueeLabel alloc]initWithFrame:CGRectMake(self.view.center.x - 512.f/2, 56, 512.f, 15)];
    
    artistLabel.textAlignment = NSTextAlignmentCenter;
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    artistLabel.marqueeType = MLContinuous;
    artistLabel.scrollDuration = 15.0;
    artistLabel.continuousMarqueeExtraBuffer = 40.0f;
    artistLabel.animationCurve = UIViewAnimationOptionCurveLinear;
    [self.view addSubview:artistLabel];
    self.artistLabel = artistLabel;
    
    self.currentAudioItem = [ARPlayer sharedPlayer].currentAudioItem;

    [self setSongTitle:self.currentAudioItem.title atrist:self.currentAudioItem.artist];
    
    
    
    self.musicControlView = [ARPlayer sharedPlayer].musicControlView;
    
    
    UIView* buttonsContainerView = [[UIView alloc] initWithFrame:
                                    CGRectMake(CGRectGetMidX(self.view.bounds) - 250/2, 70, 250, 60)];
    buttonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:buttonsContainerView];
    
    
    self.repeatButton = [[ARRepeatButton alloc] initWithFrame:CGRectMake(0, 0, 40, 60)];
    [self.repeatButton setContentEdgeInsets:UIEdgeInsetsMake(17, 8, 17, 8)];
    [buttonsContainerView addSubview:self.repeatButton];
    
    [self.repeatButton setRepeatState:self.musicControlView.repeatButton.repeatState];
    [self.repeatButton addTarget:self
                          action:@selector(actionRepeat:)
                forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.shuffleButton = [[ARShuffleButton alloc] initWithFrame:CGRectMake(70, 0, 40, 60)];
    [self.shuffleButton setContentEdgeInsets:UIEdgeInsetsMake(17, 6, 17, 6)];
    [buttonsContainerView addSubview:self.shuffleButton];
    
    [self.shuffleButton setShuffleState:self.musicControlView.shuffleButton.shuffleState];
    [self.shuffleButton addTarget:self
                           action:@selector(actionShuffle:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.broadcastButton = [[ARBroadcastButton alloc] initWithFrame:CGRectMake(140, 0, 40, 60)];
    [self.broadcastButton setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 0)];
    [buttonsContainerView addSubview:self.broadcastButton];
    
    [self.broadcastButton setBroadcastState:self.musicControlView.broadcastButton.broadcastState];
    [self.broadcastButton addTarget:self
                             action:@selector(actionBroadcast:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    
    self.addSongButton = [[ARAddSongButton alloc] initWithFrame:CGRectMake(210, 0, 40, 60)];
    [self.addSongButton setContentEdgeInsets:UIEdgeInsetsMake(21, 11, 21, 11)];
    self.addSongButton.enabled = NO;
    [buttonsContainerView addSubview:self.addSongButton];
    
    [self.addSongButton setAddSongState:self.musicControlView.addSongButton.addSongState];
    [self.addSongButton addTarget:self
                           action:@selector(actionAddSong:)
                 forControlEvents:UIControlEventTouchUpInside];
    
    
    CGFloat artworkSize, containerViewWidth;
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait ||
        self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        artworkSize = artworkPortraitSize;
        containerViewWidth = containerViewPortraitWidth;
    }
    else {
        artworkSize = artworkViewLandscapeSize;
        containerViewWidth = containerViewLandscapeWidth;
    }
    
    UIImageView* artwork = [[UIImageView alloc]initWithFrame:
                            CGRectMake(0, 0, artworkSize, artworkSize)];
    
    artwork.center = self.view.center;
    
    artwork.image = [UIImage imageNamed:@"artwork_default.png"];
    artwork.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |   UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    artwork.userInteractionEnabled = YES;
    [self.view addSubview:artwork];
    self.artwork = artwork;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleTapGesture:)];
    [artwork addGestureRecognizer:tapGesture];
    
    
    UIView* containerView = [[UIView alloc]initWithFrame:CGRectMake(self.view.center.x - containerViewWidth / 2,
                                                                    CGRectGetHeight(self.view.bounds) - 124,
                                                                    containerViewWidth, 124)];
    
    containerView.backgroundColor = [UIColor clearColor];
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    
    
    CGFloat trackSliderWidth = CGRectGetWidth(containerView.bounds) - 38 * 2;
    
    UISlider* trackSlider = [[UISlider alloc]initWithFrame:CGRectMake(38, 0, trackSliderWidth, 34)];
    trackSlider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    UIImage* trackThumbImage = [UIImage imageNamed:@"track_thumb_image.png"];
    [trackSlider setThumbImage:trackThumbImage forState:UIControlStateNormal];
    
    UIImage* trackImage = [UIImage imageNamed:@"track_image.png"];
    [trackSlider setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    [trackSlider setMinimumTrackImage:trackImage forState:UIControlStateNormal];
    
    [containerView addSubview:trackSlider];
    [trackSlider addTarget:self action:@selector(actionSeek:withEvent:) forControlEvents:UIControlEventValueChanged];
    self.trackSlider = trackSlider;
    
    
    UILabel* leftTrackLabel = [[UILabel alloc] initWithFrame:CGRectMake(-50, 8, 44, 18)];
    leftTrackLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    leftTrackLabel.textAlignment = NSTextAlignmentRight;
    leftTrackLabel.textColor = [UIColor blackColor];
    leftTrackLabel.font = [UIFont systemFontOfSize:10.f];
    leftTrackLabel.text = @"--:--";
    [trackSlider addSubview:leftTrackLabel];
    self.leftTrackLabel = leftTrackLabel;
    
   
    
    UILabel* rightTrackLabel = [[UILabel alloc] initWithFrame:
                                CGRectMake(CGRectGetMaxX(trackSlider.bounds) + 6, 8, 44, 18)];
    rightTrackLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    rightTrackLabel.textAlignment = NSTextAlignmentLeft;
    rightTrackLabel.textColor = [UIColor blackColor];
    rightTrackLabel.font = [UIFont systemFontOfSize:10.f];
    rightTrackLabel.text = @"--:--";
    [trackSlider addSubview:rightTrackLabel];
    self.rightTrackLabel = rightTrackLabel;
    
    
   
    UIView* controlButtonsContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMidX(containerView.bounds) - 116, 34, 232, 46)];
    
    controlButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [containerView addSubview:controlButtonsContainerView];
    
    self.backwardButton = [[ARBackwardButton alloc]initWithFrame: CGRectMake(0, 0, 46, 46)];
    [controlButtonsContainerView addSubview:self.backwardButton];
    [self.backwardButton addTarget:self
                            action:@selector(actionBackward:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    
    ARPlayButton* playButton = [[ARPlayButton alloc]initWithFrame:
                            CGRectMake(CGRectGetMidX(buttonsContainerView.bounds) - 32, 0, 46, 46)];
    [controlButtonsContainerView addSubview:playButton];
    [playButton addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton = playButton;
    
    self.forwardButton = [[ARForwardButton alloc]initWithFrame: CGRectMake(186, 0, 46, 46)];
    self.forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleRightMargin;
    [controlButtonsContainerView addSubview:self.forwardButton];
    [self.forwardButton addTarget:self
                           action:@selector(actionForward:)
                 forControlEvents:UIControlEventTouchUpInside];

    
    CGFloat volumeViewWidth = CGRectGetWidth(containerView.bounds) - 40.f * 2;
    
    self.volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(40, 90, volumeViewWidth, 40)];
    self.volumeView.showsRouteButton = NO;
    self.volumeView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    self.volumeView.tintColor = [UIColor blackColor];
    UIImage* thumb = [UIImage imageNamed:@"slider-default7-handle.png"];
    [self.volumeView setVolumeThumbImage:thumb forState:UIControlStateNormal];
    
    [containerView addSubview:self.volumeView];
    
    UIImage* maxImage = [UIImage imageNamed:@"media_volume_max.png"];
    
    UIImageView* maxImageView = [[UIImageView alloc]
                                 initWithFrame:CGRectMake(CGRectGetMaxX(self.volumeView.bounds) + 6, -2,
                                                          maxImage.size.width * 0.9,
                                                          maxImage.size.height * 0.9)];
    
    maxImageView.image = maxImage;
    maxImageView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin;
    
    [self.volumeView addSubview:maxImageView];
    
    
    UIImage* minImage = [UIImage imageNamed:@"media_volume_min.png"];
    UIImageView* minImageView = [[UIImageView alloc]
                                 initWithFrame:CGRectMake(-maxImage.size.width * 0.9, -2,
                                                          maxImage.size.width * 0.9,
                                                          maxImage.size.height * 0.9)];
    minImageView.image = minImage;
    minImageView.autoresizingMask =  UIViewAutoresizingFlexibleRightMargin;
    
    [self.volumeView addSubview:minImageView];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.playButton setSelected:self.musicControlView.playButton.selected];
    self.trackSlider.maximumValue = self.musicControlView.trackSlider.maximumValue;
    self.trackSlider.value = self.musicControlView.trackSlider.value;
    
    self.leftTrackLabel.text = self.musicControlView.leftTrackLabel.text;
    self.rightTrackLabel.text = self.musicControlView.rightTrackLabel.text;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    NSLog(@"ARNowPlayingViewController deallocated");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    CGRect artworkBounds = self.artwork.bounds;
    CGRect containerViewBounds = self.containerView.bounds;
    
    
    BOOL isOrientationPortrait = toInterfaceOrientation == UIInterfaceOrientationPortrait ||
                                 toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    
    if (isOrientationPortrait) {
        artworkBounds.size = CGSizeMake(artworkPortraitSize, artworkPortraitSize);
        containerViewBounds.size.width = containerViewPortraitWidth;
    } else {
        artworkBounds.size = CGSizeMake(artworkViewLandscapeSize, artworkViewLandscapeSize);
        containerViewBounds.size.width = containerViewLandscapeWidth;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         self.artwork.bounds = artworkBounds;
                         self.containerView.bounds = containerViewBounds;
                         
                     }];
}

- (void) setSongTitle:(NSString*) title atrist:(NSString*) artist {
    
    NSDictionary* attributes = nil;
    
    attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.f]};
    self.artistLabel.attributedText = [[NSAttributedString alloc]initWithString:artist
                                                                attributes:attributes];
    
    attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:19.f]};
    self.titleLabel.attributedText = [[NSAttributedString alloc]initWithString:title
                                                               attributes:attributes];
    
}

#pragma mark - Actions

- (void)actionDone:(UIButton*) sender
{
    [sender setHighlighted:YES];
    
    [self.delegate nowPlayingViewControllerWillDismiss];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) actionRepeat:(UIButton*)sender {
    
    switch ([[ARPlayer sharedPlayer] repeatState]) {
            
        case ARRepeatStateOff:
            
            [self.repeatButton setRepeatState:ARRepeatButtonStateSelected];
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateSelected];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOn];
            
            break;
            
        case ARRepeatStateOn:
            [self.repeatButton setRepeatState:ARRepeatButtonStateSelectedOneTrack];
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateSelectedOneTrack];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOneTrack];
            break;
            
        case ARRepeatStateOneTrack:
            [self.repeatButton setRepeatState:ARRepeatButtonStateOff];
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateOff];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOff];
            break;
            
        default:
            break;
    }
    
    
}



- (void) actionShuffle:(UIButton*)sender {
    
    if (![[ARPlayer sharedPlayer] isShuffling]) {
        
        [self.shuffleButton setShuffleState:ARShuffleButtonStateOn];
        [self.musicControlView.shuffleButton setShuffleState:ARShuffleButtonStateOn];
        [[ARPlayer sharedPlayer] setShuffling:YES];
        
    } else {
        
        [self.shuffleButton setShuffleState:ARShuffleButtonStateOff];
        [self.musicControlView.shuffleButton setShuffleState:ARShuffleButtonStateOff];
        [[ARPlayer sharedPlayer] setShuffling:NO];
    }
    
}

- (void) actionBroadcast:(UIButton*)sender {
    
    if (![ARPlayer sharedPlayer].isBroadcasting) {
        [ARPlayer sharedPlayer].isBroadcasting = YES;
        [self.broadcastButton setBroadcastState:ARBroadcastButtonStateOn];
        [self.musicControlView.broadcastButton setBroadcastState:ARBroadcastButtonStateOn];
        
        [[ARPlayer sharedPlayer]getBroadcastFromServer];
        
    } else {
        [ARPlayer sharedPlayer].isBroadcasting = YES;
        [self.broadcastButton setBroadcastState:ARBroadcastButtonStateOff];
        [self.musicControlView.broadcastButton setBroadcastState:ARBroadcastButtonStateOff];
        
    }
    
    
}

- (void) actionAddSong:(UIButton*) sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ARMusicControlViewActionAddSongNotification object:nil];
    
}


- (void) actionBackward:(UIButton*) sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ARMusicControlViewActionBackwardNotification object:nil];
    
}

- (void) actionPlay:(UIButton*) sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ARMusicControlViewActionPlayNotification object:nil];
    
}

- (void) actionForward:(UIButton*) sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ARMusicControlViewActionForwardNotification object:nil];
    
}

- (void)actionSeek:(UISlider *)sender withEvent:(UIEvent*) event {
    
    UITouch* touch = [event.allTouches anyObject];
    
    if (touch.phase != UITouchPhaseMoved && touch.phase != UITouchPhaseBegan) {
        
        CMTime time = CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC);
        
        [[ARPlayer sharedPlayer].player seekToTime:time];
        
        [ARPlayer sharedPlayer].isSeeking = NO;
        
    } else {
        
        if (![ARPlayer sharedPlayer].isSeeking) {
            [ARPlayer sharedPlayer].isSeeking = YES;
        }
        
        NSString* durationString = [self durationStringForTime:sender.value];
        
        self.leftTrackLabel.text = durationString;
        
        NSInteger residuaryDuration = sender.maximumValue - sender.value;
        NSString* residuaryDurationString = [@"-" stringByAppendingString:[self durationStringForTime:residuaryDuration]];
        self.rightTrackLabel.text = residuaryDurationString;
        
    }
    
}

- (NSString*) durationStringForTime:(double) totalSeconds {
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    if (totalSeconds >= 3600) {
        [formatter setDateFormat:@"H:mm:ss"];
    }  else {
        [formatter setDateFormat:@"m:ss"];
    }
    NSString* resultString = [formatter stringFromDate:date];
    
    return resultString;
}

#pragma mark - API

- (void) getLyrics:(NSInteger) lyricsID {
    
    [[ARServerManager sharedManager] getLyrics:lyricsID
                                     onSuccess:^(NSString *text) {
                                         self.lyrics = text;
                                         
                                             if (self.lyricsTextView) {
                                                 self.lyricsTextView.text = text;
                                             }
                                         
                                     }];
}


#pragma mark - Gestures 

- (void) handleTapGesture:(UITapGestureRecognizer*) sender {
    
    NSLog(@"handleTapGesture");
    
    if (self.currentAudioItem.lyricsID) {
        
        if (!self.lyrics) {
            [self getLyrics:self.currentAudioItem.lyricsID];
        }
        
        if (!self.lyricsTextView) {
            [self addLyricsTextView];
            
        } else if (!self.blurView.isHidden) {
            
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.blurView.alpha = 0;
                             } completion:^(BOOL finished) {
                                 self.blurView.hidden = YES;
                             }];
            
            
        } else {
            self.blurView.hidden = NO;
            [self showLyricsTextView];
        }
    }
    
}

- (void) addLyricsTextView {
   
    CGFloat offset = 20.f;
    
    CGRect frame = CGRectMake(offset,offset,
                              CGRectGetWidth(self.artwork.bounds) - 2 * offset,
                              CGRectGetHeight(self.artwork.bounds) - 2 * offset);
    
    self.blurView = [[JCRBlurView alloc]initWithFrame:frame];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurView.layer.cornerRadius = 10.f;
    [self.artwork addSubview:self.blurView];
    
    
    UITextView* lyricsTextView = [[UITextView alloc] initWithFrame:self.blurView.bounds];
    lyricsTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    lyricsTextView.backgroundColor = [UIColor clearColor];
    lyricsTextView.editable = NO;
    lyricsTextView.textAlignment = NSTextAlignmentCenter;
    lyricsTextView.font = [UIFont systemFontOfSize:18.f];
    
    lyricsTextView.text = self.lyrics;
    
    [self.blurView addSubview:lyricsTextView];
    self.lyricsTextView = lyricsTextView;
    [self showLyricsTextView];
    
    
}

- (void) showLyricsTextView {
    
    self.blurView.alpha = 0;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.blurView.alpha = 1;
                     }];
}


@end

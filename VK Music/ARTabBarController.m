//
//  ARTabBarController.m
//  VK Music
//
//  Created by Artur Remizov on 27.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARTabBarController.h"
#import <AVFoundation/AVFoundation.h>
#import "ARMusicControlView.h"
#import "ARAppDelegate.h"

#import "ARPlayer.h"

#import "ARBackwardButton.h"
#import "ARPlayButton.h"
#import "ARForwardButton.h"

#import "ARRepeatButton.h"
#import "ARShuffleButton.h"
#import "ARBroadcastButton.h"
#import "ARAddSongButton.h"

#import "ARServerManager.h"
#import "ARAudioItemsViewController.h"

@interface ARTabBarController ()

@end

@implementation ARTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* tintColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    [[UITabBar appearance] setTintColor: tintColor];
    
    
    CGRect navbarFrame = self.navigationController.navigationBar.frame;
        
    ARMusicControlView* musicControlView = [[ARMusicControlView alloc]initWithFrame:navbarFrame];
    musicControlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    
    musicControlView.backgroundColor = [UIColor clearColor];
    
    [self.navigationController.view addSubview:musicControlView];
    
    
    [musicControlView.backwardButton addTarget:self
                                        action:@selector(actionBackward:)
                              forControlEvents:UIControlEventTouchUpInside];
    
    [musicControlView.playButton addTarget:self
                                    action:@selector(actionPlay:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    [musicControlView.forwardButton addTarget:self
                                       action:@selector(actionForward:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [musicControlView.trackSlider addTarget:self
                                     action:@selector(actionSeek:withEvent:)
                           forControlEvents:UIControlEventValueChanged];
    
    [musicControlView.repeatButton addTarget:self
                                      action:@selector(actionRepeat:)
                            forControlEvents:UIControlEventTouchUpInside];
    
    [musicControlView.shuffleButton addTarget:self
                                       action:@selector(actionShuffle:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    [musicControlView.broadcastButton addTarget:self
                                         action:@selector(actionBroadcast:)
                               forControlEvents:UIControlEventTouchUpInside];
    [musicControlView.addSongButton addTarget:self
                                       action:@selector(actionAddSong:)
                             forControlEvents:UIControlEventTouchUpInside];
    
    self.musicControlView = musicControlView;
    
    [ARPlayer sharedPlayer].musicControlView = musicControlView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectFirstController)
                                                 name:ARServerManagerDidLogoutNotification
                                               object:nil];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) selectFirstController {
    
    [self setSelectedIndex:0];
    
    ARPlayer* player = [ARPlayer sharedPlayer];
    
    if (player.isPlaying) {
        [player pause];
        player.isBroadcasting = NO;
        player.repeatState = ARRepeatStateOff;
        [player setShuffling:NO];
    };
    
    
    [self.musicControlView controlsEnabled:NO];
    [self.musicControlView resetControls];
    
}


#pragma mark - Actions 

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
        
        self.musicControlView.leftTrackLabel.text = durationString;
        
        NSInteger residuaryDuration = sender.maximumValue - sender.value;
        NSString* residuaryDurationString = [@"-" stringByAppendingString:[self durationStringForTime:residuaryDuration]];
        self.musicControlView.rightTrackLabel.text = residuaryDurationString;
       
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


- (void) actionRepeat:(UIButton*)sender {
    
    switch ([[ARPlayer sharedPlayer] repeatState]) {
            
        case ARRepeatStateOff:
            
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateSelected];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOn];
            
            break;
            
        case ARRepeatStateOn:
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateSelectedOneTrack];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOneTrack];
            break;
            
        case ARRepeatStateOneTrack:
            [self.musicControlView.repeatButton setRepeatState:ARRepeatButtonStateOff];
            [[ARPlayer sharedPlayer] setRepeatState:ARRepeatStateOff];
            break;
            
        default:
            break;
    }
    
    
}



- (void) actionShuffle:(UIButton*)sender {
    
    
    if (![[ARPlayer sharedPlayer] isShuffling]) {
        
        [self.musicControlView.shuffleButton setShuffleState:ARShuffleButtonStateOn];
        [[ARPlayer sharedPlayer] setShuffling:YES];
        
    } else {
        
        [self.musicControlView.shuffleButton setShuffleState:ARShuffleButtonStateOff];
        [[ARPlayer sharedPlayer] setShuffling:NO];
    }
    
    
    
}

- (void) actionBroadcast:(UIButton*)sender {
    
    if (![ARPlayer sharedPlayer].isBroadcasting) {
        [ARPlayer sharedPlayer].isBroadcasting = YES;
        [self.musicControlView.broadcastButton setBroadcastState:ARBroadcastButtonStateOn];
        
        [[ARPlayer sharedPlayer]getBroadcastFromServer];
        
    } else {
        [ARPlayer sharedPlayer].isBroadcasting = YES;
        [self.musicControlView.broadcastButton setBroadcastState:ARBroadcastButtonStateOff];
      
    }
    
    
}

- (void) actionAddSong:(UIButton*) sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:ARMusicControlViewActionAddSongNotification object:nil];
    
}



@end

//
//  ARPlayer.m
//  VK Music
//
//  Created by Artur Remizov on 18.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ARServerManager.h"
#import "ARMusicControlView.h"
#import "ARNowPlayingViewController.h"

#import "ARAudioItem.h"
#import "ARPlayButton.h"




NSString * const ARPlayerDidStartPlayNewItemNotification = @"ARPlayerDidStartPlayNewItemNotification";
NSString * const ARPlayerNewAudioItemUserInfoKey = @"ARPlayerNewAudioItemUserInfoKey";

@interface ARPlayer ()

@property (strong, nonatomic) id playbackObserver;

@end


@implementation ARPlayer

+ (ARPlayer*) sharedPlayer {
    
    static ARPlayer* player = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [[ARPlayer alloc]init];
    });
    
    return player;
}
- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(itemDidFinishPlaying)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    return self;
}


- (void) playAudioItem:(ARAudioItem*) audioItem {
    
    self.currentAudioItem = audioItem;
    
    
    NSDictionary* songInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.currentAudioItem.artist,                 MPMediaItemPropertyArtist,
                              self.currentAudioItem.title,                  MPMediaItemPropertyTitle,
                              @(self.currentAudioItem.duration),            MPMediaItemPropertyPlaybackDuration,
                              nil];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    
    
    [self playURL:audioItem.url];
    
}

- (void) playURL:(NSURL*) url; {
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    
    self.currentItem = playerItem;
    
    NSArray* keys = [NSArray arrayWithObjects:@"commonMetadata", nil];
    [self.currentItem.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        NSArray* metadataList = [playerItem.asset commonMetadata];
        
        for (AVMetadataItem* metaItem in metadataList) {
            
            NSLog(@"%@: %@", [metaItem commonKey], [metaItem value]);
        }
    }];
    
    
    
    
    if (!self.player) {
        
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
        [self.player addObserver:self
                      forKeyPath:@"rate"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
        
        
    } else  {
        
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        
    }
    
    
    
    if (self.playbackObserver) {
        [self.player removeTimeObserver:self.playbackObserver];
        self.playbackObserver = nil;
    }
    
    [self.player play];
    
    if (!self.isNowPlaying) {
        self.isNowPlaying = YES;
    }
   
    self.musicControlView.leftTrackLabel.text = @"0:00";
    self.musicControlView.rightTrackLabel.text = [self durationStringForTime:self.currentAudioItem.duration];
    self.musicControlView.trackSlider.value = 0.0;
    self.musicControlView.trackSlider.maximumValue = 0.0;
    
    if (self.nowPlayingViewController) {
        
        self.nowPlayingViewController.leftTrackLabel.text = @"0:00";
        self.nowPlayingViewController.rightTrackLabel.text = [self durationStringForTime:self.currentAudioItem.duration];
        self.nowPlayingViewController.trackSlider.value = 0.0;
        self.nowPlayingViewController.trackSlider.maximumValue = 0.0;
    }
    
    
    NSDictionary* userInfo = @{ARPlayerNewAudioItemUserInfoKey: self.currentAudioItem};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARPlayerDidStartPlayNewItemNotification
                                                        object:nil
                                                      userInfo:userInfo];
    
}
- (void) play
{
    [self.player play];
    
}

- (void) pause
{
    [self.player pause];
}

- (void) getBroadcastFromServer {
    
    ARAudioItem* item = [[ARPlayer sharedPlayer] currentAudioItem];
    
    NSString* audioID = [NSString stringWithFormat:@"%ld_%ld",  (long)item.ownerID, (long)item.audioID];
    
    [[ARServerManager sharedManager] getBroadcast:audioID];
    
}


#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    if ([keyPath isEqualToString:@"rate"]) {
        
        CGFloat rate = [[change objectForKey:@"new"]floatValue];
        
        self.isPlaying = rate;
        
        if (rate == 1) {
            self.musicControlView.playButton.selected = YES;
            
            if (self.nowPlayingViewController) {
                self.nowPlayingViewController.playButton.selected = YES;
            }
            
            double interval = 0.1f;
            
            //CMTime playerDuration = [self playerItemDuration];
            
            AVPlayerItem* playerItem = [[ARPlayer sharedPlayer].player currentItem];
            CMTime playerDuration = [playerItem duration];
            
            if (CMTIME_IS_INVALID(playerDuration)) {
                return;
            }
            
            double duration = CMTimeGetSeconds(playerDuration);
            
            if (isfinite(duration)) {
                
                CGFloat width = 1000;
                interval = 0.5f + duration / width;
                
            }
            
            ARPlayer* weakSelf = self;
            
            self.playbackObserver = [self.player
                                     addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                     queue:NULL
                                     usingBlock:^(CMTime time) {
                                         
                                         [weakSelf syncScrubber];
                                         
                                     }];
            
        } else {
            self.musicControlView.playButton.selected = NO;
            if (self.nowPlayingViewController) {
                self.nowPlayingViewController.playButton.selected = NO;
            }
            
            [self.player removeTimeObserver:self.playbackObserver];
            self.playbackObserver = nil;
        }

        
    }
        
}


- (CMTime) playerItemDuration {
    
    if (self.currentItem.status == AVPlayerStatusReadyToPlay) {
        
        return [self.currentItem duration];
    }
    
    return (kCMTimeInvalid);
}

- (void) syncScrubber {
    
    CMTime playerDuration = [self playerItemDuration];
    
    if (CMTIME_IS_INVALID(playerDuration)) {
        
        self.musicControlView.trackSlider.minimumValue = 0.0;
        
        if (self.nowPlayingViewController) {
            self.nowPlayingViewController.trackSlider.minimumValue = 0.0;
        }
        
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (isfinite(duration) && (duration > 0)) {
        
        self.musicControlView.trackSlider.maximumValue = duration;
        
        if (self.nowPlayingViewController) {
            self.nowPlayingViewController.trackSlider.maximumValue = duration;
        }
        
        int minValue = self.musicControlView.trackSlider.minimumValue;
        int maxValue = self.musicControlView.trackSlider.maximumValue;
        
        int time = CMTimeGetSeconds(self.currentItem.currentTime);
        
        int value = (maxValue - minValue) * time / duration + minValue;
        
        if (!self.isSeeking) {
            
            [self.musicControlView.trackSlider setValue:value animated:YES];
            
            NSString* durationString = [self durationStringForTime:value];
            self.musicControlView.leftTrackLabel.text = durationString;
            
            NSString* residuaryDurationString = [@"-" stringByAppendingString:[self durationStringForTime:duration - value]];
            self.musicControlView.rightTrackLabel.text = residuaryDurationString;
            
            if (self.nowPlayingViewController) {
                [self.nowPlayingViewController.trackSlider setValue:value animated:YES];
                self.nowPlayingViewController.leftTrackLabel.text = durationString;
                self.nowPlayingViewController.rightTrackLabel.text = residuaryDurationString;
            }
            
        }
        
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

#pragma mark - Notifications

- (void) itemDidFinishPlaying {
    
    [self.player removeTimeObserver:self.playbackObserver];
    self.playbackObserver = nil;
}

@end

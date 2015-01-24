//
//  ARAddSongButton.h
//  VK Music
//
//  Created by Artur Remizov on 25.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARButton.h"

typedef enum {
    ARAddSongButtonStateDisable    = 0x00010000,
    ARAddSongButtonStateAvailable  = 0x00020000,
    ARAddSongButtonStateDone       = 0x00030000,
    
} ARAddSongButtonState;

@interface ARAddSongButton : ARButton

@property (assign, nonatomic) ARAddSongButtonState addSongState;

@end

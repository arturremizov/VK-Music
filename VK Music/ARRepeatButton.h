//
//  ARRepeatButton.h
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARButton.h"

typedef enum {
    
    ARRepeatButtonStateDisabled          = 0x00000000,
    ARRepeatButtonStateSelected          = 0x00010000,
    ARRepeatButtonStateSelectedOneTrack  = 0x00020000,
    ARRepeatButtonStateOff               = 0x00030000
    
} ARRepeatButtonState;

@interface ARRepeatButton : ARButton

@property (assign, nonatomic) ARRepeatButtonState repeatState;

@end

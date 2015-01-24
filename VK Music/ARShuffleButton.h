//
//  ARShuffleButton.h
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARButton.h"

typedef enum {
    ARShuffleButtonStateDisabled   = 0x00000000,
    ARShuffleButtonStateOff        = 0x00010000,
    ARShuffleButtonStateOn         = 0x00020000
    
} ARShuffleButtonState;


@interface ARShuffleButton : ARButton

@property (assign, nonatomic) ARShuffleButtonState shuffleState;

@end

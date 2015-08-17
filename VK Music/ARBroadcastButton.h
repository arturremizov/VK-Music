//
//  ARBroadcastButton.h
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARButton.h"

typedef enum {
    
    ARBroadcastButtonStateDisabled   = 0x00000000,
    ARBroadcastButtonStateOn         = 0x00010000,
    ARBroadcastButtonStateOff        = 0x00020000
    
} ARBroadcastButtonState;

@interface ARBroadcastButton : ARButton

@property (assign, nonatomic) ARBroadcastButtonState broadcastState;

@end

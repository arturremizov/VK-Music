//
//  ARBroadcastButton.m
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARBroadcastButton.h"

@implementation ARBroadcastButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"broadcast.png"]
              forState:ARBroadcastButtonStateOff | UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"broadcast_highlighted.png"]
              forState:ARBroadcastButtonStateOff | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"broadcast_selected.png"]
              forState:ARBroadcastButtonStateOn | UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"broadcast_selected_h.png"]
              forState:ARBroadcastButtonStateOn | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"broadcast_highlighted.png"] forState:UIControlStateDisabled | ARBroadcastButtonStateDisabled];
    }
    return self;
}

- (void) setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        [self setBroadcastState:ARBroadcastButtonStateOff];
    } else {
        [self setBroadcastState:ARBroadcastButtonStateDisabled];
    }
    
}

- (void) setBroadcastState:(ARBroadcastButtonState )broadcastState {
    [super setButtonState:broadcastState];
    _broadcastState = broadcastState;
}


@end

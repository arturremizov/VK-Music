//
//  ARAddSongButton.m
//  VK Music
//
//  Created by Artur Remizov on 25.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARAddSongButton.h"

@implementation ARAddSongButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"add_disabled.png"]
              forState:ARAddSongButtonStateDisable | UIControlStateDisabled];
        
        [self setImage:[UIImage imageNamed:@"add_available.png"]
              forState:ARAddSongButtonStateAvailable | UIControlStateNormal];
        
        [self setImage:[UIImage imageNamed:@"add_h.png"]
              forState:ARAddSongButtonStateAvailable | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"done.png"]
              forState:ARAddSongButtonStateDone | UIControlStateDisabled];
        
        
    }
    return self;
}
- (void) setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        [self setAddSongState:ARAddSongButtonStateAvailable];
    } else  {
        [self setAddSongState:ARAddSongButtonStateDisable];
    }
    
}


- (void) setAddSongState:(ARAddSongButtonState)addSongState {
    
    if ((addSongState == ARAddSongButtonStateDisable || addSongState == ARAddSongButtonStateDone) && self.enabled == YES) {
        [super setEnabled:NO];
    } else if (!self.enabled && addSongState == ARAddSongButtonStateAvailable) {
        [super setEnabled:YES];
    }
    
    [super setButtonState:addSongState];
    _addSongState = addSongState;
}

@end

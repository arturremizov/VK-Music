//
//  ARShuffleButton.m
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARShuffleButton.h"

@implementation ARShuffleButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"shuffle.png"]
              forState:UIControlStateNormal | ARShuffleButtonStateOff];
        [self setImage:[UIImage imageNamed:@"shuffle_highlighted.png"]
              forState:UIControlStateHighlighted | ARShuffleButtonStateOff];
        
        [self setImage:[UIImage imageNamed:@"shuffle_selected.png"]
              forState:UIControlStateNormal | ARShuffleButtonStateOn];
        [self setImage:[UIImage imageNamed:@"shuffle_selected_h.png"]
              forState:UIControlStateHighlighted | ARShuffleButtonStateOn];
        
        [self setImage:[UIImage imageNamed:@"shuffle_highlighted.png"] forState:UIControlStateDisabled | ARShuffleButtonStateDisabled];
        
    }
    return self;
}

- (void) setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        [self setShuffleState:ARShuffleButtonStateOff];
    } else {
        [self setShuffleState:ARShuffleButtonStateDisabled];
    }
    
}

- (void) setShuffleState:(ARShuffleButtonState) shuffleState {
    
    [super setButtonState:shuffleState];
    _shuffleState = shuffleState;
}


@end

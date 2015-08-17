//
//  ARRepeatButton.m
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARRepeatButton.h"

@implementation ARRepeatButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"Repeat.png"]
              forState: ARRepeatButtonStateOff | UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"Repeat_highlighted.png"]
              forState: ARRepeatButtonStateOff | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"Repeat_selected.png"]
              forState:ARRepeatButtonStateSelected | UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"Repeat_selected_h.png"]
              forState:ARRepeatButtonStateSelected | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"Repeat_selected_one.png"]
              forState:ARRepeatButtonStateSelectedOneTrack | UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"Repeat_selected_one_h.png"]
              forState:ARRepeatButtonStateSelectedOneTrack | UIControlStateHighlighted];
        
        [self setImage:[UIImage imageNamed:@"Repeat_highlighted.png"] forState:UIControlStateDisabled | ARRepeatButtonStateDisabled];
        
        
        
    }
    return self;
}

- (void) setEnabled:(BOOL)enabled {
    
    [super setEnabled:enabled];
    
    if (enabled) {
        [self setRepeatState:ARRepeatButtonStateOff];
    } else {
        [self setRepeatState:ARRepeatButtonStateDisabled];
    }
    
}

- (void) setRepeatState:(ARRepeatButtonState)repeatState {
    
    [super setButtonState:repeatState];
    _repeatState = repeatState;
    
}

@end

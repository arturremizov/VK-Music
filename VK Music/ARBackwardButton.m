//
//  ARBackwardButton.m
//  VK Music
//
//  Created by Artur Remizov on 15.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARBackwardButton.h"

@implementation ARBackwardButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"media_fast_backward.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"media_fast_backward_h.png"]
                        forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"media_fast_backward_h.png"]
              forState:UIControlStateDisabled];
        
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {
    
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [super setHighlighted:highlighted];
                    }
                    completion:NULL];
}


@end

//
//  ARPlayButton.m
//  VK Music
//
//  Created by Artur Remizov on 20.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARPlayButton.h"

@implementation ARPlayButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal ];
        [self setImage:[UIImage imageNamed:@"play_h.png"] forState:UIControlStateNormal
          |UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"pause_h.png"] forState:UIControlStateHighlighted | UIControlStateSelected];
        
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {
    
    [UIView transitionWithView:self
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [super setHighlighted:highlighted];
                    }
                    completion:NULL];
}



@end

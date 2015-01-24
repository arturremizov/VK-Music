//
//  ARButton.m
//  VK Music
//
//  Created by Artur Remizov on 11.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARButton.h"

@implementation ARButton

static void *kPlaybackStateObservingContext = &kPlaybackStateObservingContext;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addObserver:self forKeyPath:@"buttonState" options:NSKeyValueObservingOptionOld context:kPlaybackStateObservingContext];
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted {
    
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [super setHighlighted:highlighted];
                    }
                    completion:NULL];
}

- (void) setButtonState:(NSInteger)buttonState {
    
    [self willChangeValueForKey:@"buttonState"];
    _buttonState = buttonState;
    [self didChangeValueForKey:@"buttonState"];
    
}

- (UIControlState)state {
    NSInteger returnState = [super state];
    return (returnState | self.buttonState);
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"buttonState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (context == kPlaybackStateObservingContext) {
        NSInteger oldState = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        if (oldState != self.buttonState) {
            [self layoutSubviews];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

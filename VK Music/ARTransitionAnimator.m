//
//  ARTransitionAnimator.m
//  VK Music
//
//  Created by Artur Remizov on 28.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//


#import "ARTransitionAnimator.h"

@implementation ARTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

//http://whoisryannystrom.com/2013/10/01/View-Controller-Transition-Orientation/

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIView* containerView = [transitionContext containerView];
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect toVCEndFrame = containerView.bounds;
    toVCEndFrame.origin = CGPointZero;

    if (self.presenting) {
        
        [transitionContext.containerView addSubview:toVC.view];
        
        toVC.view.frame = containerView.bounds;
        CGRect toVCStartFrame = [self rectForSecondViewController:toVC];
        toVC.view.frame = toVCStartFrame;
        
        
        CGRect fromVCEndFrame = [self rectForFirstViewController:fromVC];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             fromVC.view.frame = fromVCEndFrame;
                             toVC.view.frame = toVCEndFrame;
                         } completion:^(BOOL finished) {
                             
                             [transitionContext completeTransition:YES];
                             [toVC.view didMoveToSuperview];
                         }];
    }
    else {
        
        CGRect toVCStartFrame = [self rectForFirstViewController:toVC];
        toVC.view.frame = toVCStartFrame;
        
        CGRect fromVCEndFrame = [self rectForSecondViewController:fromVC];
        
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             toVC.view.frame = toVCEndFrame;
                             fromVC.view.frame = fromVCEndFrame;
                         } completion:^(BOOL finished) {
                             
                             [transitionContext completeTransition:YES];
                             [toVC.view didMoveToSuperview];
                         }];
        
    }
}

- (CGRect) rectForFirstViewController:(UIViewController*) vc {
    
    CGRect frame = vc.view.frame;
    frame.origin.x = -CGRectGetMaxX(vc.view.frame) / 3;
    return frame;
}


- (CGRect) rectForSecondViewController:(UIViewController*) vc {
    
    CGRect frame = vc.view.frame;
    frame.origin.x = CGRectGetMaxX(vc.view.frame);
    return frame;
}

@end

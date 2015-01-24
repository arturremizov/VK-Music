//
//  ARTransitionAnimator.h
//  VK Music
//
//  Created by Artur Remizov on 28.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end

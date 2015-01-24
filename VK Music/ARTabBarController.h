//
//  ARTabBarController.h
//  VK Music
//
//  Created by Artur Remizov on 27.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARMusicControlView;

@interface ARTabBarController : UITabBarController

@property (strong, nonatomic) ARMusicControlView* musicControlView;

@end

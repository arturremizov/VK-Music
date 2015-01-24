//
//  ARLoginViewController.h
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ARAccessToken;

typedef void (^ARCompletionBlock)(ARAccessToken* token);

@interface ARLoginViewController : UIViewController

- (id)initWithCompletionBlock:(ARCompletionBlock) completionBlock;

@end

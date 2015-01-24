//
//  ARSearchItems.h
//  VK Music
//
//  Created by Artur Remizov on 16.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARAudioItem;

@interface ARSearchItems : NSObject

@property (strong, nonatomic) NSMutableArray* myAudioItems;
@property (strong, nonatomic) NSMutableArray* globalAudioItems;

- (NSInteger) countAllItems;
- (void) removeAllItems;

- (ARAudioItem*) itemAtIndexPath:(NSIndexPath*) indexPath;
- (NSIndexPath*) indexPathForRamdomItem;

@end

//
//  ARSearchItems.m
//  VK Music
//
//  Created by Artur Remizov on 16.12.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARSearchItems.h"
#import "ARAudioItem.h"

@implementation ARSearchItems

- (id)init
{
    self = [super init];
    if (self) {
        self.myAudioItems = [NSMutableArray array];
        self.globalAudioItems = [NSMutableArray array];
    }
    return self;
}


- (NSInteger) countAllItems
{
    NSInteger count = [self.myAudioItems count] + [self.globalAudioItems count];
    return count;
}

- (void) removeAllItems {
    
    [self.myAudioItems removeAllObjects];
    [self.globalAudioItems removeAllObjects];
    
}

- (ARAudioItem*) itemAtIndexPath:(NSIndexPath*) indexPath {
    
    ARAudioItem* audioItem = nil;
    
    if (indexPath.section == 0 && ([self.myAudioItems count] > 0)) {
        audioItem = [self.myAudioItems objectAtIndex:indexPath.row];
    } else {
        audioItem = [self.globalAudioItems objectAtIndex:indexPath.row];
    }
    
    return audioItem;
}

- (NSIndexPath*) indexPathForRamdomItem {
    
    NSIndexPath* indexPath = nil;
    NSInteger index = arc4random() % [self countAllItems];
    
    if ([self.myAudioItems count] >= index && [self.myAudioItems count] > 0) {
        
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    } else if ([self.myAudioItems count] == 0){
        indexPath = [NSIndexPath indexPathForRow:index inSection:1];
    } else {
        indexPath = [NSIndexPath indexPathForRow:index - [self.myAudioItems count] + 1 inSection:1];
    }
    
    return indexPath;
}


@end

//
//  ARAlbum.h
//  VK Music
//
//  Created by Artur Remizov on 05.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARServerObject.h"

@interface ARAlbum : ARServerObject

@property (assign, nonatomic) NSInteger albumID;
@property (assign, nonatomic) NSInteger ownerID;
@property (strong, nonatomic) NSString* title;

@end

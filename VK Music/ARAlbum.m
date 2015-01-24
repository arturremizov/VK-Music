//
//  ARAlbum.m
//  VK Music
//
//  Created by Artur Remizov on 05.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAlbum.h"

@implementation ARAlbum

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.albumID = [[responseObject objectForKey:@"id"]integerValue];
        self.ownerID = [[responseObject objectForKey:@"owner_id"]integerValue];
        self.title = [responseObject objectForKey:@"title"];
        
    }
    return self;
    
}

@end

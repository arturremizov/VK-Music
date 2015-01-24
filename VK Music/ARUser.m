//
//  ARUser.m
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARUser.h"

@implementation ARUser

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.firstName = [responseObject objectForKey:@"first_name"];
        self.lastName = [responseObject objectForKey:@"last_name"];
        
        NSString* stringURL = [responseObject objectForKey:@"photo_100"];
        self.imageURL = [NSURL URLWithString:stringURL];
        
        self.userID = [[responseObject objectForKey:@"id"]integerValue];
        self.online = [[responseObject objectForKey:@"online"]boolValue];
    }
    return self;
    
}

@end

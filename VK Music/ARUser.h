//
//  ARUser.h
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARServerObject.h"

@interface ARUser : ARServerObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSURL* imageURL;
@property (assign, nonatomic) NSInteger userID;
@property (assign, nonatomic) BOOL online;


@end

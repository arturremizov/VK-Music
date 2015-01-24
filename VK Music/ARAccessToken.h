//
//  ARAccessToken.h
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARAccessToken : NSObject

@property (strong, nonatomic) NSString* token;
@property (strong, nonatomic) NSDate* expirationDate;
@property (strong, nonatomic) NSString* userID;

@end

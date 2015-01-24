//
//  ARAudioItem.h
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARServerObject.h"

@interface ARAudioItem : ARServerObject

@property (strong, nonatomic) NSString* artist;
@property (assign, nonatomic) NSTimeInterval duration;
@property (strong, nonatomic) NSString* durationString;
@property (assign, nonatomic) NSInteger audioID;
@property (assign, nonatomic) NSInteger genreID;
@property (assign, nonatomic) NSInteger lyricsID;
@property (assign, nonatomic) NSInteger ownerID;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSURL* url;


@property (assign, nonatomic) BOOL selected;

@end

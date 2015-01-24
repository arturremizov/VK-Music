//
//  ARAudioItem.m
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARAudioItem.h"

@implementation ARAudioItem

- (id) initWithServerResponse:(NSDictionary*) responseObject {
    
    self = [super init];
    if (self) {
        
        self.artist = [responseObject objectForKey:@"artist"];
        
        self.duration = [[responseObject objectForKey:@"duration"]doubleValue];
        self.durationString = [self durationStringFromTimeInterval:_duration];
        
        self.audioID = [[responseObject objectForKey:@"id"]integerValue];
        self.genreID = [[responseObject objectForKey:@"genre_id"]integerValue];
        self.lyricsID = [[responseObject objectForKey:@"lyrics_id"]integerValue];
        self.ownerID = [[responseObject objectForKey:@"owner_id"]integerValue];
        self.title = [responseObject objectForKey:@"title"];
        
        NSString* stringURL = [responseObject objectForKey:@"url"];
        self.url = [NSURL URLWithString:stringURL];
        
    }
    
    return self;
    
}

- (NSString*) durationStringFromTimeInterval:(NSTimeInterval) duration {
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDateComponents* components = [calendar components:NSCalendarUnitSecond
                                    | NSCalendarUnitMinute | NSCalendarUnitHour
                                               fromDate:[NSDate date]
                                                 toDate:[NSDate dateWithTimeIntervalSinceNow:duration]
                                                options:NSCalendarWrapComponents];
    
    NSInteger second = [components second];
    NSInteger minute = [components minute];
    NSInteger hour = [components hour];
    
    NSString* durationString = nil;
    
    if (hour > 0) {
        
        durationString = [NSString stringWithFormat:@"%ld:", (long)hour];
        
        NSString* minuteString = [NSString stringWithFormat:@"%ld", (long)minute];
        if (minute < 10) {
            minuteString = [@"0" stringByAppendingString:minuteString];
        }
        
        NSString* secondString = nil;
        
        if (second > 0 ) {
            if (second < 10) {
                secondString = [NSString stringWithFormat:@":0%ld", (long)second];
            } else {
                secondString = [NSString stringWithFormat:@":%ld", (long)second];
            }
            minuteString = [minuteString stringByAppendingString:secondString];
        }
        
        durationString = [durationString stringByAppendingString:minuteString];
        
    } else {
        
        NSString* minuteString = [NSString stringWithFormat:@"%ld:", (long)minute];
        
        NSString* secondString = [NSString stringWithFormat:@"%ld", (long)second];
        if (second < 10) {
            secondString = [@"0" stringByAppendingString:secondString];
        }
        durationString = [minuteString stringByAppendingString:secondString];
    }
    
    return durationString;
}

@end

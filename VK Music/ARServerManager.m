//
//  ARServerManager.m
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARServerManager.h"
#import "AFNetworking.h"
#import "ARLoginViewController.h"
#import "ARAccessToken.h"

#import "ARUser.h"
#import "ARAudioItem.h"
#import "ARAlbum.h"

NSString * const ARServerManagerDidLogoutNotification = @"ARServerManagerDidLogoutNotification";
NSString * const ARServerManagerDidAutorizeNewUserNotification = @"ARServerManagerDidAutorizeNewUserNotification";


static NSString* kAccessToken = @"kAccessToken";
static NSString* kExpirationDate = @"kExpirationDate";
static NSString* kUserID = @"kUserID";

@interface ARServerManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager* requestOperationManager;


@end

@implementation ARServerManager

+ (ARServerManager*) sharedManager {
    
    static ARServerManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ARServerManager alloc]init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURL* url = [NSURL URLWithString:@"https://api.vk.com/method/"];
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:url];
    }
    return self;
}

- (void) autorizeUser:(void(^)(ARUser* user)) completion {
    
    ARLoginViewController* vc = [[ARLoginViewController alloc]initWithCompletionBlock:^(ARAccessToken *token) {
        
        self.accessToken = token;
        
        if (token) {
            
            [self saveAccessToken];
            
            [self getUser:token.userID
                onSuccess:^(ARUser *user) {
                    
                    self.currentUser = user;
                    
                    if (completion) {
                        
                        completion(user);
                        
                        
                    }
                    
                } onFailure:^(NSError *error, NSInteger statusCode) {
                    if (completion) {
                        completion(nil);
                    }
                }];
            
        } else {
            
            if (completion) {
                completion(nil);
            }
        }
        
       
        
    }];
    
    
    
    UINavigationController* navc = [[UINavigationController alloc]initWithRootViewController:vc];
    
    UIViewController* mainVC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
    
    [mainVC presentViewController:navc animated:NO completion:nil];
    
    
}

- (void) saveAccessToken {
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:self.accessToken.token forKey:kAccessToken];
    [userDefaults setObject:self.accessToken.expirationDate forKey:kExpirationDate];
    [userDefaults setObject:self.accessToken.userID forKey:kUserID];
    
    [userDefaults synchronize];
    
}

- (BOOL)isLoggedIn {
    
    BOOL isLoggedIn = NO;
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
   
    
    if ([userDefaults objectForKey:kAccessToken] ) {
        
        
        ARAccessToken* accessToken = [[ARAccessToken alloc]init];
        
        accessToken.token = [userDefaults stringForKey:kAccessToken];
        accessToken.expirationDate = [userDefaults objectForKey:kExpirationDate];
        accessToken.userID = [userDefaults objectForKey:kUserID];
        
        self.accessToken = accessToken;
        
        if (![self isExpired]) {
            
            [self getUser:accessToken.userID
                onSuccess:^(ARUser *user) {
                    self.currentUser = user;
                    
                }
                onFailure:^(NSError *error, NSInteger statusCode) {
                    
                    
                }];
            isLoggedIn = YES;
            
        };
        
    }
    
    return isLoggedIn;
}

- (BOOL)isExpired {
    
    return  [self.accessToken.expirationDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970];
}

- (void) cancelAllOperations {
    [self.requestOperationManager.operationQueue cancelAllOperations];
}

- (void)logout {
    
    NSHTTPCookieStorage* storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults removeObjectForKey:kAccessToken];
    [userDefaults removeObjectForKey:kExpirationDate];
    [userDefaults removeObjectForKey:kUserID];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ARServerManagerDidLogoutNotification object:nil];
    
    [self autorizeUser:^(ARUser *user) {
       
        [[NSNotificationCenter defaultCenter] postNotificationName:ARServerManagerDidAutorizeNewUserNotification object:nil];
        
    }];
}


- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(ARUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary* parameters = @{@"user_ids": userID,
                                 @"fields":   @"photo_100",
                                 @"name_case": @"non",
                                 @"v":        @"5.27"};
    
    [self.requestOperationManager
     GET:@"users.get"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSArray* dictArray = [responseObject objectForKey:@"response"];
         
         ARUser* user = [[ARUser alloc]initWithServerResponse:[dictArray firstObject]];
         
         if (success) {
             success(user);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure (error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) getAudioItemsByUserID:(NSString*) ownerID
                       albumID:(NSInteger) albumID
                        offset:(NSInteger) offset
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* audioItems, NSInteger count)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure; {
    
    
    
    NSDictionary* parameters = @{@"owner_id":       ownerID,
                                 @"album_id":       @(albumID),
                                 @"offset":         @(offset),
                                 @"count":          @(count),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.get"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSInteger count = [[response objectForKey:@"count"]integerValue];
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* audioItems = [NSMutableArray array];
         
         for (NSDictionary* item in items) {
            
             ARAudioItem* audio = [[ARAudioItem alloc] initWithServerResponse:item];
             [audioItems addObject:audio];
         }
         
         if (success) {
             success(audioItems, count);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
}

- (void)getBroadcast:(NSString*) audioID {
    
    NSDictionary* parameters = @{@"audio":          audioID,
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.setBroadcast"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
     }];

    
}

- (void)getLyrics:(NSInteger) lyricsID
        onSuccess:(void(^)(NSString* text)) success {
    
    NSDictionary* parameters = @{@"lyrics_id":          @(lyricsID),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.getLyrics"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSString* text = [[responseObject objectForKey:@"response"] objectForKey:@"text"];
         
         if (success) {
             success(text);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
     }];
    
}

- (void) searchAudio:(NSString*) text
              offset:(NSInteger) offset
               count:(NSInteger) count
           onSuccess:(void(^)(NSArray* myAudioItems, NSArray* globalAudioItems, NSInteger count)) success
           onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    [self.requestOperationManager.operationQueue cancelAllOperations];
    
    NSDictionary* parameters = @{@"q":              text,
                                 @"auto_complete":  @(1),
                                 @"lyrics":         @(0),
                                 @"performer_only": @(0),
                                 @"sort":           @(2),
                                 @"search_own":     @(1),
                                 @"offset":         @(offset),
                                 @"count":          @(count),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.search"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         NSInteger count = [[response objectForKey:@"count"]integerValue];
         
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* myItems = [NSMutableArray array];
         NSMutableArray* globalItems = [NSMutableArray array];
         
         for (NSDictionary* item in items) {
             
             ARAudioItem* audio = [[ARAudioItem alloc] initWithServerResponse:item];
             
             if (audio.ownerID == self.currentUser.userID) {
                 [myItems addObject:audio];
             } else {
                 [globalItems addObject:audio];
             }
         }
         
         if (success) {
             success(myItems, globalItems, count);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
}

- (void) addAudio:(NSInteger) audioID
          ownerID:(NSInteger) ownerID
        onSuccess:(void(^)(NSInteger audioID)) success {
    
    NSDictionary* parameters = @{@"audio_id":       @(audioID),
                                 @"owner_id":       @(ownerID),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.add"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSInteger audioID = [[responseObject objectForKey:@"response"]integerValue];

         if (success) {
             success(audioID);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];

    
}

- (void) deleteAudio:(NSInteger) audioID
             ownerID:(NSInteger) ownerID
           onSuccess:(void(^)(BOOL deleted)) success {
    
    NSDictionary* parameters = @{@"audio_id":       @(audioID),
                                 @"owner_id":       @(ownerID),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.delete"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         BOOL deleted = [[responseObject objectForKey:@"response"]boolValue];
         
         if (success) {
             success(deleted);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];
    
}

- (void) reorderAudio:(NSInteger) audioID
              ownerID:(NSInteger) ownerID
          beforeAudio:(NSInteger) beforeAudioID
                after:(NSInteger) afterAudioID
            onSuccess:(void(^)(BOOL reordered)) success {
    
    
    NSDictionary* parameters = @{@"audio_id":       @(audioID),
                                 @"owner_id":       @(ownerID),
                                 @"before":         @(beforeAudioID),
                                 @"after":          @(afterAudioID),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.reorder"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         BOOL reordered = [[responseObject objectForKey:@"response"]boolValue];
         
         if (success) {
             success(reordered);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];
    
    
}

- (void) getAlbums:(NSString*) ownerID
            offset:(NSInteger) offset
             count:(NSInteger) count
         onSuccess:(void(^)(NSArray*albums, NSInteger count)) success
         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSDictionary* parameters = @{@"owner_id":       ownerID,
                                 @"offset":         @(offset),
                                 @"count":          @(count),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.getAlbums"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         NSInteger count = [[response objectForKey:@"count"]integerValue];
         
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* albums = [NSMutableArray array];
         
         for (NSDictionary* item in items) {
             ARAlbum* album = [[ARAlbum alloc]initWithServerResponse:item];
             [albums addObject:album];
         }
         
         if (success) {
             success(albums, count);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

- (void) addAlbum:(NSString*) title
        onSuccess:(void(^)(NSInteger albumID)) success {
    
    
    NSDictionary* parameters = @{@"title":          title,
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.addAlbum"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSInteger albumID = [[[responseObject objectForKey:@"response"] objectForKey:@"album_id"]integerValue];
         
         if (success) {
             success(albumID);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];
    
}

- (void) deleteAlbum:(NSInteger) albumID
           onSuccess:(void(^)(NSInteger response)) success {
    
    NSDictionary* parameters = @{@"album_id":       @(albumID),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.deleteAlbum"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSInteger response = [[responseObject objectForKey:@"response"]integerValue];
         
         if (success) {
             success(response);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];
    
    
}

- (void) moveAudioToAlbum:(NSInteger) albumID
                 audioIDs:(NSArray*) audioIDs
                onSuccess:(void(^)(NSInteger response)) success {
    
    NSDictionary* parameters = @{@"album_id":       @(albumID),
                                 @"audio_ids":      audioIDs,
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.moveToAlbum"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSInteger response = [[responseObject objectForKey:@"response"]integerValue];
         
         if (success) {
             success(response);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         
     }];
    
}

- (void) getRecommendationsByUserID:(NSInteger) userID
                             offset:(NSInteger) offset
                              count:(NSInteger) count
                          onSuccess:(void(^)(NSArray* audioItems, NSInteger count)) success
                          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    
    NSDictionary* parameters = @{@"user_id":        @(userID),
                                 @"offset":         @(offset),
                                 @"count":          @(count),
                                 @"shuffle":        @(0),
                                 @"access_token":   self.accessToken.token,
                                 @"v":              @"5.27"};
    
    [self.requestOperationManager
     GET:@"audio.getRecommendations"
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         
         NSLog(@"JSON: %@", responseObject);
         
         NSDictionary* response = [responseObject objectForKey:@"response"];
         
         NSInteger count = [[response objectForKey:@"count"]integerValue];
         NSArray* items = [response objectForKey:@"items"];
         
         NSMutableArray* audioItems = [NSMutableArray array];
         
         for (NSDictionary* item in items) {
             
             ARAudioItem* audio = [[ARAudioItem alloc] initWithServerResponse:item];
             [audioItems addObject:audio];
         }
         
         if (success) {
             success(audioItems, count);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
         
     }];
    
    
    
}

@end

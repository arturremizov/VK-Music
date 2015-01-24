//
//  ARServerManager.h
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ARServerManagerDidLogoutNotification;
extern NSString * const ARServerManagerDidAutorizeNewUserNotification;

@class ARUser;
@class ARAccessToken;

@interface ARServerManager : NSObject

@property (strong, nonatomic) ARUser* currentUser;
@property (strong, nonatomic) ARAccessToken* accessToken;

+ (ARServerManager*) sharedManager;

- (void) autorizeUser:(void(^)(ARUser* user)) completion;

- (BOOL) isLoggedIn;

- (void)logout;

- (void) getUser:(NSString*) userID
       onSuccess:(void(^)(ARUser* user)) success
       onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) getAudioItemsByUserID:(NSString*) ownerID
                       albumID:(NSInteger) albumID
                        offset:(NSInteger) offset
                         count:(NSInteger) count
                     onSuccess:(void(^)(NSArray* audioItems, NSInteger count)) success
                     onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getBroadcast:(NSString*) audioID;

- (void)getLyrics:(NSInteger) lyricsID
        onSuccess:(void(^)(NSString* text)) success;

- (void) searchAudio:(NSString*) text
              offset:(NSInteger) offset
               count:(NSInteger) count
           onSuccess:(void(^)(NSArray* myAudioItems, NSArray* globalAudioItems, NSInteger count)) success
           onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) addAudio:(NSInteger) audioID
          ownerID:(NSInteger) ownerID
        onSuccess:(void(^)(NSInteger audioID)) success;

- (void) deleteAudio:(NSInteger) audioID
             ownerID:(NSInteger) ownerID
           onSuccess:(void(^)(BOOL deleted)) success;

- (void) reorderAudio:(NSInteger) audioID
              ownerID:(NSInteger) ownerID
          beforeAudio:(NSInteger) beforeAudioID
                after:(NSInteger) afterAudioID
            onSuccess:(void(^)(BOOL reordered)) success;

- (void) getAlbums:(NSString*) ownerID
            offset:(NSInteger) offset
             count:(NSInteger) count
         onSuccess:(void(^)(NSArray*albums, NSInteger count)) success
         onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void) addAlbum:(NSString*) title
        onSuccess:(void(^)(NSInteger albumID)) success;

- (void) deleteAlbum:(NSInteger) albumID
           onSuccess:(void(^)(NSInteger response)) success;

- (void) moveAudioToAlbum:(NSInteger) albumID
                 audioIDs:(NSArray*) audioIDs
                onSuccess:(void(^)(NSInteger response)) success;

- (void) getRecommendationsByUserID:(NSInteger) userID
                             offset:(NSInteger) offset
                              count:(NSInteger) count
                          onSuccess:(void(^)(NSArray* audioItems, NSInteger count)) success
                          onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end

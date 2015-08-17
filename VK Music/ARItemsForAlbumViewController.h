//
//  ARItemsForAlbumViewController.h
//  VK Music
//
//  Created by Artur Remizov on 14.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ARItemsForAlbumViewControllerDelegate;

@interface ARItemsForAlbumViewController : UITableViewController

@property (weak, nonatomic) id <ARItemsForAlbumViewControllerDelegate> delegate;

- (IBAction)actionDone:(UIBarButtonItem*)sender;

@end

@protocol ARItemsForAlbumViewControllerDelegate

- (void) didSelectedAudioIDs:(NSArray*) selectedAudioIDs;

@end
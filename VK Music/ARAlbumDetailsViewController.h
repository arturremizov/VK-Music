//
//  ARAlbumDetailsViewController.h
//  VK Music
//
//  Created by Artur Remizov on 13.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAudioItemsViewController.h"

@protocol ARAlbumDetailsViewControllerDelegate;

@interface ARAlbumDetailsViewController : ARAudioItemsViewController

@property (weak, nonatomic) id <ARAlbumDetailsViewControllerDelegate> delegate;

@end

@protocol ARAlbumDetailsViewControllerDelegate

- (void) shouldDeleteAlbum:(ARAlbum*) album;

@end
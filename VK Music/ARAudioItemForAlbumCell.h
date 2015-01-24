//
//  ARAudioItemForAlbumCell.h
//  VK Music
//
//  Created by Artur Remizov on 14.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARAudioItemForAlbumCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView* addImage;

- (void) setAddedToAlbumStyle:(BOOL) added;

@end

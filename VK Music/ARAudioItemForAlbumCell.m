//
//  ARAudioItemForAlbumCell.m
//  VK Music
//
//  Created by Artur Remizov on 14.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAudioItemForAlbumCell.h"

@implementation ARAudioItemForAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) setAddedToAlbumStyle:(BOOL) added {
    
    UIColor* color = nil;
    UIImage* image = nil;
    
    if (!added) {
        color = [UIColor blackColor];
        image = [UIImage imageNamed:@"add.png"];
    } else {
        color = [UIColor lightGrayColor];
        image = [UIImage imageNamed:@"added.png"];
    }
    [self.titleLabel setTextColor:color];
    [self.artistLabel setTextColor:color];
    [self.addImage setImage:image];
}

@end

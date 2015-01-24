//
//  ARAudioItemCell.h
//  VK Music
//
//  Created by Artur Remizov on 14.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCSEQVisualizer;

@interface ARAudioItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* titleLabel;
@property (weak, nonatomic) IBOutlet UILabel* artistLabel;
@property (weak, nonatomic) IBOutlet UILabel* durationLabel;
@property (weak, nonatomic) IBOutlet PCSEQVisualizer* visualizer;

@end

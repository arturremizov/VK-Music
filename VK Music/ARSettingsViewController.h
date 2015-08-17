//
//  ARSettingsViewController.h
//  VK Music
//
//  Created by Artur Remizov on 18.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARSettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView* userImage;
@property (weak, nonatomic) IBOutlet UILabel* userNameLabel;

- (IBAction)actionLogout:(UIButton*)sender;

@end

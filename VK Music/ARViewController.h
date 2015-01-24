//
//  ARViewController.h
//  VK Music
//
//  Created by Artur Remizov on 04.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARViewController : UIViewController

@property (strong, nonatomic) UINavigationBar* navBar;
@property (strong, nonatomic) UINavigationItem* navItem;

@property (weak, nonatomic) IBOutlet UITableView* tableView;

@property (weak, nonatomic) UIButton* nowPlayingButton;

@property (strong, nonatomic) UILabel *songsCountLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicatorView;


- (void) addCustomNavigationBar;
- (void) addNowPlayingButtonAnimated:(BOOL) animated;

@end

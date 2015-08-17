//
//  ARAlbumDetailsViewController.m
//  VK Music
//
//  Created by Artur Remizov on 13.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAlbumDetailsViewController.h"
#import "ARItemsForAlbumViewController.h"
#import "ARServerManager.h"
#import "ARAlbum.h"

@interface ARAlbumDetailsViewController () <ARItemsForAlbumViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UINavigationItem* secondNavItem;
@property (strong, nonatomic) UIPopoverController* popover;

@end

@implementation ARAlbumDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 139, CGRectGetWidth(self.view.bounds), 40);
    UINavigationBar* navbar = [[UINavigationBar alloc]initWithFrame:frame];
    navbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navbar.tintColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    [self.view addSubview:navbar];
    
    UINavigationItem* navItem = [[UINavigationItem alloc]init];
    navbar.items = @[navItem];
    self.secondNavItem = navItem;
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    
    
    
    [editButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                              forState:UIControlStateNormal];
    
    self.secondNavItem.leftBarButtonItem = editButton;
    
    [self addDeleteButton];
    
}

- (void) addDeleteButton {
    UIBarButtonItem* deleteAlbumButton = [[UIBarButtonItem alloc]initWithTitle:@"Delete"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(actionDelete:)];
    [deleteAlbumButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}
                                     forState:UIControlStateNormal];
    
    [self.secondNavItem setRightBarButtonItem:deleteAlbumButton animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void) actionEdit:(UIBarButtonItem*) sender {
    
    BOOL isEditing = self.tableView.editing;
    [self.tableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem editItem = UIBarButtonSystemItemEdit;
  
    if (self.tableView.editing) {
        editItem = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:editItem
                                                                               target:self
                                                                               action:@selector(actionEdit:)];
    [editButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                              forState:UIControlStateNormal];
    
    [self.secondNavItem setLeftBarButtonItem:editButton animated:YES];
    
    if (self.tableView.editing) {
        UIBarButtonItem* addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(actionAdd:)];
        [addButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}
                                 forState:UIControlStateNormal];
        [self.secondNavItem setRightBarButtonItem:addButton animated:YES];
    } else {
        [self addDeleteButton];
    }
   
    
}

- (void) actionDelete:(UIBarButtonItem*) sender {
    
    UIViewController* vc = [[UIViewController alloc]init];
    vc.preferredContentSize = CGSizeMake(280, 42);
    
    NSLog(@"%@", NSStringFromCGRect(vc.view.bounds));
    
    UIButton* deleteAlbumButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 280, 42)];
    
    NSDictionary* attr = @{NSFontAttributeName: [UIFont systemFontOfSize:20.f],
                           NSForegroundColorAttributeName: [UIColor redColor]};
    
    NSAttributedString* title = [[NSAttributedString alloc]initWithString:@"Delete Album" attributes:attr];
    [deleteAlbumButton setAttributedTitle:title forState:UIControlStateNormal];
    UIColor* color = [UIColor colorWithWhite:0.9 alpha:1];
    [deleteAlbumButton setBackgroundImage:[self imageWithColor:color] forState:UIControlStateHighlighted];
    [deleteAlbumButton addTarget:self action:@selector(actionDeleteAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:deleteAlbumButton];
    
    
    UIPopoverController* popover = [[UIPopoverController alloc]initWithContentViewController:vc];
    
    [popover presentPopoverFromBarButtonItem:sender
                    permittedArrowDirections:UIPopoverArrowDirectionUp
                                    animated:YES];
    
    popover.delegate = self;
    self.popover = popover;
}

- (void) actionDeleteAlbum:(UIButton*) sender {
    
    [self.delegate shouldDeleteAlbum:self.album];
    [self.popover dismissPopoverAnimated:NO];
    
    
}

- (UIImage*)imageWithColor:(UIColor*) color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void) actionAdd:(UIBarButtonItem*) sender {
    
    ARItemsForAlbumViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ARItemsForAlbumViewController"];
    vc.delegate = self;
    UINavigationController* navc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popover = nil;
}

#pragma mark - API

- (void) moveAudioToAlbum:(NSArray*) audioIDs {
    
    [[ARServerManager sharedManager]
     moveAudioToAlbum:self.album.albumID
     audioIDs:audioIDs
     onSuccess:^(NSInteger response) {
         
         if (response) {
             [self refreshAudioItems];
         }
         
         
     }];
}

#pragma mark - ARItemsForAlbumViewControllerDelegate

- (void) didSelectedAudioIDs:(NSArray*) selectedAudioIDs {
    
    [self actionEdit:nil];
    
    [self moveAudioToAlbum:selectedAudioIDs];
    
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.isSearching ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}




@end

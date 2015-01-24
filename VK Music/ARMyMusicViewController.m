//
//  ARMyMusicViewController.m
//  VK Music
//
//  Created by Artur Remizov on 15.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARMyMusicViewController.h"
#import "PCSEQVisualizer.h"
#import "ARMusicControlView.h"
#import "ARPlayer.h"
#import "ARAudioItemCell.h"
#import "ARAudioItem.h"

@interface ARMyMusicViewController ()

@end

@implementation ARMyMusicViewController

- (void)viewDidLoad
{
    [self addCustomNavigationBar];
    [super viewDidLoad];
    
    [self.tableView setContentOffset:CGPointMake(0, -76) animated:YES];
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    
    self.navItem.leftBarButtonItem = editButton;
    self.navItem.title = @"My Music";
    
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
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing) {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:item
                                                                              target:self
                                                                              action:@selector(actionEdit:)];
    [self.navItem setLeftBarButtonItem:editButton animated:YES];
    
    
}


- (void) actionPlay {
    
    if (!self.musicControlView.isControlsEnabled && [self.audioItems count] > 0) {
        
        [self.musicControlView controlsEnabled:YES];
        
        self.isActiveController = YES;
        [ARPlayer sharedPlayer].activeAudioItemsViewController = self;
        self.isFirstPlaying = NO;
        [self addNowPlayingButtonAnimated:YES];
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        ARAudioItemCell* cell = (ARAudioItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cell.visualizer.hidden = NO;
        [cell.visualizer start];
        self.selectedIndexPath = indexPath;
        
        ARAudioItem* item = [self.audioItems objectAtIndex:indexPath.row];
        [[ARPlayer sharedPlayer]playAudioItem:item];
        
    } else {
        [super actionPlay];
    }
}



@end

//
//  ARRecommendationsViewController.m
//  VK Music
//
//  Created by Artur Remizov on 18.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARRecommendationsViewController.h"

@interface ARRecommendationsViewController ()

@end

@implementation ARRecommendationsViewController

static NSInteger audioCount = 1000;

- (void)viewDidLoad
{
    [self addCustomNavigationBar];
    [super viewDidLoad];
	[self.tableView setContentOffset:CGPointMake(0, -76) animated:YES];
    self.navItem.title = @"Recommendations";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void) getAudioItemsFromServer {
    
    [[ARServerManager sharedManager]
     getRecommendationsByUserID:[[ARServerManager sharedManager].accessToken.userID integerValue]
     offset:[self.audioItems count]
     count:audioCount
     onSuccess:^(NSArray *audioItems, NSInteger count) {
         
         [self.audioItems addObjectsFromArray:audioItems];
         self.countAllAudioItems = count;
         [self setInfoInFooterViewForItems:count];
         
         self.isLoading = NO;
         [self.tableView reloadData];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
     }];
    
}

- (void) refreshAudioItems {
    
    [self.refreshControl beginRefreshing];
    
    [[ARServerManager sharedManager]
     getRecommendationsByUserID:[[ARServerManager sharedManager].accessToken.userID integerValue]
     offset:0
     count:MAX(audioCount, [self.audioItems count])
     onSuccess:^(NSArray *audioItems, NSInteger count) {
         
         [self.audioItems removeAllObjects];
         [self.audioItems addObjectsFromArray:audioItems];
         
         self.countAllAudioItems = count;
         [self setInfoInFooterViewForItems:count];
         self.isLoading = NO;
         
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         [self.refreshControl endRefreshing];
     }];
    
}

#pragma mark - UITableViewDelegate 

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end

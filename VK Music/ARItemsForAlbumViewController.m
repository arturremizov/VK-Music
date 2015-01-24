//
//  ARItemsForAlbumViewController.m
//  VK Music
//
//  Created by Artur Remizov on 14.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARItemsForAlbumViewController.h"
#import "ARServerManager.h"
#import "ARAccessToken.h"
#import "ARSearchItems.h"
#import "ARAudioItemForAlbumCell.h"
#import "ARAudioItem.h"

@interface ARItemsForAlbumViewController ()

@property (strong, nonatomic) NSMutableArray* audioItems;
@property (strong, nonatomic) ARSearchItems* searchItems;
@property (strong, nonatomic) UILabel *songsCountLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicatorView;

@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) NSInteger countAllAudioItems;
@property (assign, nonatomic) BOOL isCanLoadMoreItems;

@property (strong, nonatomic) NSMutableArray* selectedAudioIDs;

@end

@implementation ARItemsForAlbumViewController

static NSInteger audioCount = 500;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    
    UIView* footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = footerView.center;
    indicator.hidesWhenStopped = YES;
    [footerView addSubview:indicator];
    [indicator startAnimating];
    indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.loadingIndicatorView = indicator;
    
    UILabel* songsCountLabel = [[UILabel alloc]initWithFrame:footerView.bounds];
    songsCountLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    songsCountLabel.backgroundColor = [UIColor clearColor];
    songsCountLabel.font = [UIFont systemFontOfSize:20.f];
    songsCountLabel.textColor = [UIColor colorWithRed:151/255.f green:151/255.f blue:151/255.f alpha:151/255.f];
    songsCountLabel.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:songsCountLabel];
    self.songsCountLabel = songsCountLabel;
    
    self.tableView.tableFooterView = footerView;
    
    self.audioItems = [NSMutableArray array];
    self.searchItems = [[ARSearchItems alloc]init];
    self.selectedAudioIDs = [NSMutableArray array];
    [self getAudioItemsFromServer];
    
}

- (void) dealloc {
    NSLog(@"ARItemsForAlbumViewController deallocated");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)actionDone:(UIBarButtonItem*)sender {
    
    [self.delegate didSelectedAudioIDs:self.selectedAudioIDs];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - API

- (void) getAudioItemsFromServer {
    
    [[ARServerManager sharedManager]
     getAudioItemsByUserID:[ARServerManager sharedManager].accessToken.userID
     albumID:0
     offset:[self.audioItems count]
     count:audioCount
     onSuccess:^(NSArray *audioItems, NSInteger count) {
         
         [self.audioItems addObjectsFromArray:audioItems];
         
         self.countAllAudioItems = count;
         [self setInfoInFooterViewForItems:count];
         
         self.isLoading = NO;
         [self.tableView reloadData];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
         
     }];
    
}

- (void) setInfoInFooterViewForItems:(NSInteger) count {
    
    if ([self.audioItems count] == count) {
        
        self.isCanLoadMoreItems = NO;
        [self.loadingIndicatorView stopAnimating];
        
        if (count >= 20) {
            self.songsCountLabel.hidden = NO;
            self.songsCountLabel.text = [NSString stringWithFormat:@"%ld Songs", (long)count];
            
        }
    } else {
        [self.loadingIndicatorView startAnimating];
        self.songsCountLabel.hidden = YES;
        self.isCanLoadMoreItems = YES;
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.audioItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ((indexPath.row == [self.audioItems count]-1) && !self.isLoading && self.isCanLoadMoreItems) {
        self.isLoading = YES;
        [self getAudioItemsFromServer];
    }
   
    
    static NSString* identifier = @"ARAudioItemForAlbumCell";
    ARAudioItemForAlbumCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    ARAudioItem* audioItem = [self.audioItems objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = audioItem.title;
    cell.artistLabel.text = audioItem.artist;
    
    [cell setAddedToAlbumStyle:audioItem.selected];
    
    return cell;
}

#pragma mark - UITableViewDelegate 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ARAudioItem* audioItem = audioItem = [self.audioItems objectAtIndex:indexPath.row];
    
    if (!audioItem.selected) {
        audioItem.selected = YES;
    }
    
    [self.selectedAudioIDs addObject:@(audioItem.audioID)];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
}

@end

//
//  ARAudioItemsViewController.m
//  VK Music
//
//  Created by Artur Remizov on 05.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAudioItemsViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ARMusicControlView.h"

#import "ARBackwardButton.h"
#import "ARForwardButton.h"

#import "ARRepeatButton.h"
#import "ARShuffleButton.h"
#import "ARBroadcastButton.h"
#import "ARAddSongButton.h"

#import "ARSearchItems.h"

#import "ARAudioItem.h"
#import "ARPlayer.h"
#import "ARNowPlayingViewController.h"
#import "ARAudioItemCell.h"
#import "PCSEQVisualizer.h"
#import "MarqueeLabel.h"
#import "JCRBlurView.h"

#import "ARAlbum.h"

NSString * const ARAudioItemsViewControllerDidBecomeActiveNotification = @"ARAudioItemsViewControllerDidBecomeActiveNotification";


@interface ARAudioItemsViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>


@end

static NSInteger audioCount = 500;
static NSInteger searchAudioCount = 200;

@implementation ARAudioItemsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchBar.delegate = self;
    
    self.isFirstPlaying = YES;
	
    UIColor* tintColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:tintColor];
    
    self.musicControlView = [ARPlayer sharedPlayer].musicControlView;
    

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionBackward)
                                                 name:ARMusicControlViewActionBackwardNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionPlay)
                                                 name:ARMusicControlViewActionPlayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(actionForward)
                                                 name:ARMusicControlViewActionForwardNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addAudioNotification)
                                                 name:ARMusicControlViewActionAddSongNotification
                                               object:nil];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartPlayNewItem:)
                                                 name:ARPlayerDidStartPlayNewItemNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemDidFinishPlaying)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newAudioItemsViewControllerDidBecomeActive)
                                                 name:ARAudioItemsViewControllerDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogout)
                                                 name:ARServerManagerDidLogoutNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAudioItemsFromServer)
                                                 name:ARServerManagerDidAutorizeNewUserNotification
                                               object:nil];
    
    UIRefreshControl* refresh = [[UIRefreshControl alloc]init];
    refresh.backgroundColor = [UIColor whiteColor];
    [refresh addTarget:self action:@selector(refreshAudioItems) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    self.refreshControl = refresh;
    
    
    
    self.audioItems = [NSMutableArray array];
    self.searchItems = [[ARSearchItems alloc]init];
    
    self.isSearching = NO;
    
    if (![[ARServerManager sharedManager]isLoggedIn]) {
        
        [[ARServerManager sharedManager] autorizeUser:^(ARUser *user) {
            
            NSLog(@"User %@ %@ autorized", user.firstName, user.lastName);
            [self getAudioItemsFromServer];
            
        }];
        
    } else {
        
        [self getAudioItemsFromServer];
        
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"ARAudioItemsViewController deallocated");
   
}

#pragma mark - Audio Methods

- (void) playSongWithShuffling {
    
    NSIndexPath* indexPath = 0;
    if (self.selectedIndexPath) {
        NSInteger index = arc4random() % [self.audioItems count];
        indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
    } else if (self.searchSelectedIndexPath) {
        indexPath = [self.searchItems indexPathForRamdomItem];
    }
    [self playSongAtIndexPath:indexPath];
    
}

- (void) playNextSearchAudioItem {
    
    if ([self.searchItems.myAudioItems count] > 0) {
        
        if (self.searchSelectedIndexPath.section == 0) {
            
            if (self.searchSelectedIndexPath.row != ([self.searchItems.myAudioItems count] - 1)) {
                
                [self playSongAtIndexPath:[NSIndexPath indexPathForRow:self.searchSelectedIndexPath.row + 1
                                                             inSection:self.searchSelectedIndexPath.section]];
                
            } else if ([self.searchItems.globalAudioItems count] > 0){
                
                [self playSongAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                
            }
            
        } else if (self.searchSelectedIndexPath.section == 1 && (self.searchSelectedIndexPath.row != ([self.searchItems.globalAudioItems count]-1)) ) {
            
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:self.searchSelectedIndexPath.row + 1
                                                         inSection:self.searchSelectedIndexPath.section]];
            
        }
        
        
    } else if (self.searchSelectedIndexPath.row != ([self.searchItems.globalAudioItems count] - 1)) {
        
        [self playSongAtIndexPath:[NSIndexPath indexPathForRow:self.searchSelectedIndexPath.row + 1
                                                     inSection:self.searchSelectedIndexPath.section]];
        
    }
    
}

- (void) playLastAudioItem {
    
    NSInteger sections = [self numberOfSectionsInTableView:self.tableView];
    NSIndexPath* indexPath = nil;
    
    if (sections == 1) {
        NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:0];
        indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:0];
        
    } else if (sections == 2){
        
        NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:1];
        indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:1];
        
    }
    
    [self playSongAtIndexPath:indexPath];
    
}

- (void) playSongAtIndexPath:(NSIndexPath*) indexPath
{
    ARAudioItem* item = nil;
    
    if (self.searchSelectedIndexPath) {
        
        item = [self.searchItems itemAtIndexPath:indexPath];
        self.searchSelectedIndexPath = indexPath;
        
    } else {
        item = [self.audioItems objectAtIndex:indexPath.row];
        self.selectedIndexPath = indexPath;
    }
    
    [[ARPlayer sharedPlayer] playAudioItem:item];
    
    ARAudioItemCell* cell = (ARAudioItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.visualizer.hidden = NO;
    [cell.visualizer start];
    
    [self.tableView reloadData];
    
    
}


- (void) setInfoInFooterViewForItems:(NSInteger) count {
    
    if (([self.audioItems count] == count) && !self.isSearching) {
        
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

#pragma mark - API

- (void) getAudioItemsFromServer {
    
    [[ARServerManager sharedManager]
     getAudioItemsByUserID:[ARServerManager sharedManager].accessToken.userID
     albumID:self.album.albumID
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

- (void) refreshAudioItems {
    
    [self.refreshControl beginRefreshing];
    
    [[ARServerManager sharedManager]
     getAudioItemsByUserID:[ARServerManager sharedManager].accessToken.userID
     albumID:self.album.albumID
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
     
     } onFailure:^(NSError *error, NSInteger statusCode) {
         [self.refreshControl endRefreshing];
     }];
    
    
}

- (void) addAudio {
    
    ARAudioItem* item = [ARPlayer sharedPlayer].currentAudioItem;
    
    [[ARServerManager sharedManager] addAudio:item.audioID
                                      ownerID:item.ownerID
                                    onSuccess:^(NSInteger audioID) {
                                        
                                        item.ownerID = [ARServerManager sharedManager].currentUser.userID;
                                        item.audioID = audioID;
                                        [self.audioItems insertObject:item atIndex:0];
                                        [self setInfoInFooterViewForItems:self.countAllAudioItems + 1];
                                        
                                        [self.musicControlView.addSongButton setAddSongState:ARAddSongButtonStateDone];
                                        if ([ARPlayer sharedPlayer].nowPlayingViewController) {
                                            [[ARPlayer sharedPlayer].nowPlayingViewController.addSongButton setAddSongState:ARAddSongButtonStateDone];
                                        }
                                    }];
    
}

- (void) deleteAudio:(ARAudioItem*) item {
    
    [[ARServerManager sharedManager] deleteAudio:item.audioID
                                         ownerID:item.ownerID
                                       onSuccess:^(BOOL deleted) {
                                           
                                           if (deleted) {
                                               [self setInfoInFooterViewForItems:self.countAllAudioItems-1];
                                           }
                                           
                                       }];
}

- (void) reorderAudioAtIndex:(NSInteger) sourceIndex toIndex:(NSInteger) destinationIndex {
    
    
    ARAudioItem* audioItem = [self.audioItems objectAtIndex:sourceIndex];
    
    ARAudioItem* beforeAudioItem = nil;
    ARAudioItem* afterAudioItem = nil;
    
    if (sourceIndex > destinationIndex) {
        beforeAudioItem = [self.audioItems objectAtIndex:destinationIndex];
    } else {
        afterAudioItem = [self.audioItems objectAtIndex:destinationIndex];
        
    }
    
    
    [[ARServerManager sharedManager] reorderAudio:audioItem.audioID
                                          ownerID:audioItem.ownerID
                                      beforeAudio:beforeAudioItem.audioID
                                            after:afterAudioItem.audioID
                                        onSuccess:^(BOOL reordered) {
                                            
                                            if (reordered) {
                                                [self.audioItems removeObject:audioItem];
                                                [self.audioItems insertObject:audioItem atIndex:destinationIndex];
                                            }
                                            
                                        }];
}

- (void) searchAudio:(NSString*) text newSearch:(BOOL) newSearch {
    
    CGFloat offset = 0.f;
    
    if (!newSearch) {
        offset = [self.searchItems countAllItems];
    }
    
    [[ARServerManager sharedManager]
     searchAudio:text
     offset:offset
     count:searchAudioCount
     onSuccess:^(NSArray* myAudioItems, NSArray* globalAudioItems, NSInteger count) {
         
         if (newSearch) {
             [self.searchItems removeAllItems];
         }
         
         [self.searchItems.myAudioItems addObjectsFromArray:myAudioItems];
         [self.searchItems.globalAudioItems addObjectsFromArray:globalAudioItems];
         self.countAllSearchItems = count;
         
         if ([myAudioItems count] == 0 && [globalAudioItems count] == 0) {
             self.isCanLoadMoreItems = NO;
             [self.loadingIndicatorView stopAnimating];
         } else {
             [self setInfoInFooterViewForItems:count];
         }
         
         
         
         self.isLoading = NO;
         
         [self.tableView reloadData];
         
         
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         
         self.isLoading = NO;
     }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isSearching && ([self.searchItems.myAudioItems count] > 0)) {
        return 2;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString* title = nil;
    
    if (self.isSearching && !(section == 0 && ([self.searchItems.myAudioItems count] > 0))) {
        title = @"Global search";
    }
    return title;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isSearching) {
        
        if (section == 0 && ([self.searchItems.myAudioItems count] > 0)) {
            return [self.searchItems.myAudioItems count];
        } else {
            return [self.searchItems.globalAudioItems count];
        }
    }
    
    return [self.audioItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isSearching) {
        
        if ((indexPath.row == [self.audioItems count]-1) && !self.isLoading && self.isCanLoadMoreItems) {
            self.isLoading = YES;
            [self getAudioItemsFromServer];
        }
    } else {
        if ((indexPath.row == [self.searchItems.globalAudioItems count]-1) && !self.isLoading && self.isCanLoadMoreItems) {
            self.isLoading = YES;
            [self searchAudio:self.searchBar.text newSearch:NO];
        }
    }
    
    static NSString* identifier = @"AudioItemCell";
    ARAudioItemCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    ARAudioItem* audioItem = nil;
    
    if (self.isSearching) {
        audioItem = [self.searchItems itemAtIndexPath:indexPath];
    } else {
        audioItem = [self.audioItems objectAtIndex:indexPath.row];
    }
    
    cell.titleLabel.text = audioItem.title;
    cell.artistLabel.text = audioItem.artist;
    cell.durationLabel.text = audioItem.durationString;
    
    
    if (!(audioItem.audioID == [ARPlayer sharedPlayer].currentAudioItem.audioID && self.isActiveController)|| !self.isActiveController) {
        
        if (!cell.visualizer.isHidden) {
            [cell.visualizer stop];
            cell.visualizer.hidden = YES;
        }
        
    } else if (cell.visualizer.isHidden ) {
        cell.visualizer.hidden = NO;
        
        if ([ARPlayer sharedPlayer].isPlaying) {
             [cell.visualizer start];
        } else {
            [cell.visualizer pause];
        }
        
       
    }
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.isSearching ? NO : YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    
    [self reorderAudioAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ARAudioItem* item = [self.audioItems objectAtIndex:indexPath.row];
        [self deleteAudio:item];
        [self.audioItems removeObject:item];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.isActiveController) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ARAudioItemsViewControllerDidBecomeActiveNotification
                                                            object:nil];
        
        
        self.isActiveController = YES;
        [ARPlayer sharedPlayer].activeAudioItemsViewController = self;
        
        self.isFirstPlaying = YES;

    }
    
    if (!self.musicControlView.isControlsEnabled) {
        [self.musicControlView controlsEnabled:YES];
        [self addNowPlayingButtonAnimated:YES];
    }
    
    ARAudioItem* audioItem = nil;
    
    if (self.isSearching) {
        audioItem = [self.searchItems itemAtIndexPath:indexPath];
    } else {
        audioItem = [self.audioItems objectAtIndex:indexPath.row];
    }    
    
    if ((audioItem.audioID != [ARPlayer sharedPlayer].currentAudioItem.audioID) || self.isFirstPlaying) {
        
        if (self.isFirstPlaying) {
            self.isFirstPlaying = NO;
        }
        
        [[ARPlayer sharedPlayer] playAudioItem:audioItem];
        
        ARAudioItemCell* cell = (ARAudioItemCell*)[tableView cellForRowAtIndexPath:indexPath];
        
        cell.visualizer.hidden = NO;
        [cell.visualizer start];
        
        if (self.isSearching) {
            if (self.selectedIndexPath) {
                self.selectedIndexPath = nil;
            }
            
            self.searchSelectedIndexPath = indexPath;
      
        } else  {
            
            if (self.searchSelectedIndexPath) {
                self.searchSelectedIndexPath = nil;
            }
            
            self.selectedIndexPath = indexPath;
         
        }
        
        [self.tableView reloadData];
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.isSearching && !(section == 0 && ([self.searchItems.myAudioItems count] > 0))) {
        return 35.f;
    }
    return 0.f;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView* view = nil;
    
    if (self.isSearching && !(section == 0 && ([self.searchItems.myAudioItems count] > 0))) {
        
        CGFloat height = [self tableView:self.tableView heightForHeaderInSection:section];
        
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), height);
        view = [[UIView alloc] initWithFrame:rect];
        view.backgroundColor = [UIColor colorWithWhite:246/255.f alpha:1.f];;
        
        CGRect labelRect = CGRectMake(10, 5, CGRectGetWidth(tableView.frame) - 2*10, height - 2*5);
        UILabel* label = [[UILabel alloc] initWithFrame:labelRect];
        label.backgroundColor = [UIColor clearColor];
        
        NSMutableAttributedString* string = [[NSMutableAttributedString alloc]
                                             initWithString:@"Global Search"
                                             attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.f]}];
        
        
        
        NSAttributedString* countString =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%ld)", (long)self.countAllSearchItems]                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17.f],
                                                                                                                                                                NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        
        [string appendAttributedString:countString];
        
        label.attributedText = string;
        [view addSubview:label];
    }
    
    return view;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.isSearching ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.isSearching ? NO : YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    NSLog(@"searchText = %@", searchText);
    
    if (searchText.length > 0) {
        self.isSearching = YES;
        [self searchAudio:searchText newSearch:YES];
        
    } else {
        self.isSearching = NO;
        [self setInfoInFooterViewForItems:self.countAllAudioItems];
        [self.tableView reloadData];
    }
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    self.isSearching = NO;
    [self setInfoInFooterViewForItems:self.countAllAudioItems];
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"searchBarSearchButtonClicked");
    if (searchBar.text.length > 0) {
        self.isSearching = YES;
        [self searchAudio:searchBar.text newSearch:YES];
        [searchBar resignFirstResponder];
    }
    
    
}



#pragma mark - Notifications

- (void) actionBackward {
    
    if (self.isActiveController) {
        
        if ([[ARPlayer sharedPlayer] isShuffling]) {
            [self playSongWithShuffling];
            return;
        }
        
        if (self.selectedIndexPath.row != 0) {
            NSInteger index = self.selectedIndexPath.row - 1;
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            return;
            
        } else if (self.searchSelectedIndexPath) {
            
            if (self.searchSelectedIndexPath.row != 0) {
                
                [self playSongAtIndexPath:[NSIndexPath indexPathForRow:self.searchSelectedIndexPath.row - 1
                                                             inSection:self.searchSelectedIndexPath.section]];
                
                
            } else if (self.searchSelectedIndexPath.section == 1 && self.searchSelectedIndexPath.row == 0) {
                
                NSInteger index = [self tableView:self.tableView numberOfRowsInSection:0];
                [self playSongAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0]];
                
            }
            
            
        }
        
        if ([ARPlayer sharedPlayer].repeatState == ARRepeatStateOn) {
            
            [self playLastAudioItem];
            
        }
        
    }
    
    
}

- (void) actionPlay {
    
    if (self.isActiveController) {
        if (![ARPlayer sharedPlayer].isPlaying)
        {
            [[ARPlayer sharedPlayer] play];
            ARAudioItemCell* cell = (ARAudioItemCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
            
            if (cell.visualizer.isOnPause) {
                [cell.visualizer start];
            }
        }
        else
        {
            [[ARPlayer sharedPlayer] pause];
            
            ARAudioItemCell* cell = (ARAudioItemCell*)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
            [cell.visualizer pause];
            
        }
    }
    
}

- (void) actionForward {
    
    if (self.isActiveController) {
        
        if ([[ARPlayer sharedPlayer] isShuffling]) {
            [self playSongWithShuffling];
            return;
        }
        
        if (self.selectedIndexPath && (self.selectedIndexPath.row != ([self.audioItems count] - 1)))
        {
            NSInteger index = self.selectedIndexPath.row + 1;
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            return;
            
        } else if (self.searchSelectedIndexPath) {
            
            [self playNextSearchAudioItem];
            
            
        }
        
        if ([ARPlayer sharedPlayer].repeatState == ARRepeatStateOn) {
            
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        }
        
        
    }
    
    
}

- (void) addAudioNotification {
    
    if (self.isActiveController) {
        [self addAudio];
    }
    
}

- (void) itemDidFinishPlaying
{
    if (self.isActiveController) {
        
        if ([[ARPlayer sharedPlayer] repeatState] == ARRepeatStateOneTrack) {
            
            AVPlayer* player = [[ARPlayer sharedPlayer] player];
            
            [player pause];
            
            CMTime time = CMTimeMake(0, NSEC_PER_SEC);
            [player seekToTime:time];
            [player play];
            
            
        } else if ([ARPlayer sharedPlayer].isShuffling) {
            
            [self playSongWithShuffling];
            return;
            
        } else if (self.selectedIndexPath && (self.selectedIndexPath.row < [self.audioItems count] - 1)) {
            
            NSInteger index  = self.selectedIndexPath.row + 1;
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            return;
            
        } else if (self.searchSelectedIndexPath) {
            
            [self playNextSearchAudioItem];
            
        }
        
        if ([ARPlayer sharedPlayer].repeatState == ARRepeatStateOn) {
            
            [self playSongAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
        }
    }
    
    
}

- (void) didStartPlayNewItem:(NSNotification*) notification {
    
    if (self.isActiveController) {
        
        ARAudioItem* audioItem = [notification.userInfo objectForKey:ARPlayerNewAudioItemUserInfoKey];
        
        
        if ([ARPlayer sharedPlayer].isBroadcasting) {
            [[ARPlayer sharedPlayer] getBroadcastFromServer];
        }
        
        NSString* artistString = [NSString stringWithFormat:@"%@ - ", audioItem.artist];
        NSMutableAttributedString* songInfoString = [[NSMutableAttributedString alloc]
                                                     initWithString:artistString
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f]}];
        
        NSAttributedString* titleString = [[NSAttributedString alloc]
                                           initWithString:audioItem.title
                                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:13.f]}];
        
        [songInfoString appendAttributedString:titleString];
        
        
        self.musicControlView.songInfoLabel.attributedText = songInfoString;
        
        NSInteger userID = [ARServerManager sharedManager].currentUser.userID;
        
        if (audioItem.ownerID != userID) {
            
            if (!self.musicControlView.addSongButton.enabled) {
                self.musicControlView.addSongButton.enabled = YES;
                
                if ([ARPlayer sharedPlayer].nowPlayingViewController) {
                    [ARPlayer sharedPlayer].nowPlayingViewController.addSongButton.enabled = YES;
                }
            }
            
        } else if (self.musicControlView.addSongButton.enabled || (self.musicControlView.addSongButton.addSongState == ARAddSongButtonStateDone)) {
            [self.musicControlView.addSongButton setAddSongState:ARAddSongButtonStateDisable];
            if ([ARPlayer sharedPlayer].nowPlayingViewController) {
                [[ARPlayer sharedPlayer].nowPlayingViewController.addSongButton setAddSongState:ARAddSongButtonStateDisable];
            }
        }
        
        
        if ([ARPlayer sharedPlayer].nowPlayingViewController) {
            
            ARNowPlayingViewController* vc = [ARPlayer sharedPlayer].nowPlayingViewController;
            
            vc.currentAudioItem = [ARPlayer sharedPlayer].currentAudioItem;
            [vc setSongTitle:audioItem.title atrist:audioItem.artist];
            
            if (audioItem.lyricsID) {
                
                if ([ARPlayer sharedPlayer].nowPlayingViewController.lyrics) {
                    [ARPlayer sharedPlayer].nowPlayingViewController.lyrics = nil;
                }
                [[ARPlayer sharedPlayer].nowPlayingViewController getLyrics:audioItem.lyricsID];
            } else if (vc.lyricsTextView) {
                
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     vc.blurView.alpha = 0;
                                 } completion:^(BOOL finished) {
                                     [vc.blurView removeFromSuperview];
                                     vc.blurView = nil;
                                     vc.lyricsTextView = nil;
                                 }];
                
            }
            
        }

    }
    
}


- (void) newAudioItemsViewControllerDidBecomeActive {
    
    if (self.isActiveController) {
        self.isActiveController = NO;
        self.selectedIndexPath = nil;
        [self.tableView reloadData];
        [ARPlayer sharedPlayer].activeAudioItemsViewController = nil;
        
    }
    
}

- (void) didLogout {
    
    self.isActiveController = NO;
    if (self.isSearching) {
        self.isSearching = NO;
        self.searchBar.text = nil;
    }
    
    self.selectedIndexPath = nil;
    self.searchSelectedIndexPath = nil;
    [self.searchItems removeAllItems];
    [self.audioItems removeAllObjects];
    self.isFirstPlaying = YES;
    [ARPlayer sharedPlayer].isNowPlaying = NO;
    if (self.nowPlayingButton) {
        [self.nowPlayingButton removeFromSuperview];
    }
    [self.tableView reloadData];
    
}


@end

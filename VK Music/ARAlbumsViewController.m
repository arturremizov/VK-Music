//
//  ARAlbumsViewController.m
//  VK Music
//
//  Created by Artur Remizov on 04.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARAlbumsViewController.h"
#import "ARPlayer.h"
#import "ARServerManager.h"
#import "ARAccessToken.h"
#import "ARNewPlaylistCell.h"
#import "ARAlbumCell.h"
#import "ARAlbum.h"
#import "ARAlbumDetailsViewController.h"
#import "ARItemsForAlbumViewController.h"
#import "ARUser.h"

@interface ARAlbumsViewController () <UIAlertViewDelegate, UINavigationBarDelegate, UITableViewDataSource, UITableViewDelegate, ARItemsForAlbumViewControllerDelegate, ARAlbumDetailsViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray* albums;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL isCanLoadMoreItems;

@property (strong, nonatomic) NSIndexPath* selectedIndexPath;

@end

@implementation ARAlbumsViewController

static NSInteger albumsCount = 50;

- (void)viewDidLoad
{
    [self addCustomNavigationBar];
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navItem.title = @"Albums";
    
    self.albums = [NSMutableArray array];
    self.isLoading = YES;
    [self getAlbumsFromServer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLogout)
                                                 name:ARServerManagerDidLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAlbumsFromServer)
                                                 name:ARServerManagerDidAutorizeNewUserNotification
                                               object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setInfoInFooterViewForItems:(NSInteger) count {
    
    if ([self.albums count] == count) {
        
        self.isCanLoadMoreItems = NO;
        [self.loadingIndicatorView stopAnimating];
        
        if (count >= 20) {
            self.songsCountLabel.hidden = NO;
            self.songsCountLabel.text = [NSString stringWithFormat:@"%ld Albums", (long)count];
            
        }
    } else {
        [self.loadingIndicatorView startAnimating];
        self.songsCountLabel.hidden = YES;
        self.isCanLoadMoreItems = YES;
    }
    
    
}




#pragma mark - API

- (void) getAlbumsFromServer {
    
    [[ARServerManager sharedManager] getAlbums:[ARServerManager sharedManager].accessToken.userID
                                        offset:[self.albums count]
                                         count:albumsCount
                                     onSuccess:^(NSArray *albums, NSInteger count) {
                                         
                                         [self.albums addObjectsFromArray:albums];
                                         self.isLoading = NO;
                                         [self.tableView reloadData];
                                         [self setInfoInFooterViewForItems:count];
                                         
                                     } onFailure:^(NSError *error, NSInteger statusCode) {
                                         
                                         
                                     }];
    
    
}

- (void) addNewAlbum:(NSString*) title {
    
    [[ARServerManager sharedManager]
     addAlbum:title
    onSuccess:^(NSInteger albumID) {
                                        
        if (albumID) {
            
            ARAlbum* album = [[ARAlbum alloc]init];
            album.albumID = albumID;
            album.title = title;
            album.ownerID = [ARServerManager sharedManager].currentUser.userID;
            [self.albums insertObject:album atIndex:0];
           
            
            ARItemsForAlbumViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ARItemsForAlbumViewController"];
            vc.delegate = self;
            UINavigationController* navc = [[UINavigationController alloc] initWithRootViewController:vc];
            
            [self presentViewController:navc animated:YES completion:nil];
            
        }
        
    }];

}

- (void) deleteAlbum:(ARAlbum*) album {
    
    [[ARServerManager sharedManager] deleteAlbum:album.albumID
                                       onSuccess:^(NSInteger response) {
                                           
                                       }];
    
    
}

- (void) moveAudioToAlbum:(NSArray*) audioIDs {
    
     ARAlbum* album = [self.albums objectAtIndex:0];
    
    [[ARServerManager sharedManager]
     moveAudioToAlbum:album.albumID
     audioIDs:audioIDs
     onSuccess:^(NSInteger response) {
         
         ARAlbumDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ARAlbumDetailsViewController"];
         vc.album = album;
         vc.navigationItem.title = album.title;
         vc.delegate = self;
         self.navBar.delegate = self;
         [self.navigationController pushViewController:vc animated:YES];
         [self.navBar pushNavigationItem:vc.navigationItem animated:YES];
             
         
     }];
    
}

#pragma mark - ARItemsForAlbumViewControllerDelegate

- (void) didSelectedAudioIDs:(NSArray*) selectedAudioIDs {
    
    [self.tableView reloadData];
    
    [self moveAudioToAlbum:selectedAudioIDs];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.albums count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((indexPath.row == [self.albums count]) && !self.isLoading && self.isCanLoadMoreItems) {
        self.isLoading = YES;
        [self getAlbumsFromServer];
    }
    
    if (indexPath.row == 0) {
        
        static NSString* identifier = @"ARNewPlaylistCell";
        ARNewPlaylistCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        return cell;
        
    } else {
        
        static NSString* identifier = @"ARAlbumCell";
        ARAlbumCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        ARAlbum* album = [self.albums objectAtIndex:indexPath.row - 1];
        cell.albumTitleLabel.text = album.title;
        return cell;
        
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        ARAlbum* album = [self.albums objectAtIndex:indexPath.row - 1];
        [self deleteAlbum:album];
        [self.albums removeObject:album];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"New Album"
                                                           message:@"Enter a name for this album."
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:@"Save", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeSentences;
        alertView.delegate = self;
        [alertView show];
        
    } else {
        
        
        ARAlbum* album = [self.albums objectAtIndex:indexPath.row - 1];
        
        ARAlbumDetailsViewController* vc = (ARAlbumDetailsViewController*)[ARPlayer sharedPlayer].activeAudioItemsViewController;
        
        if (vc.album.albumID != album.albumID) {
            
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ARAlbumDetailsViewController"];
            vc.album = album;
            vc.delegate = self;
            vc.navigationItem.title = album.title;
            
        }
        
        self.navBar.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
        [self.navBar pushNavigationItem:vc.navigationItem animated:YES];
        
    }
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath.row == 0 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

#pragma mark - ARAlbumDetailsViewControllerDelegate

- (void) shouldDeleteAlbum:(ARAlbum*) album {
    
    [self deleteAlbum:album];
    [self.albums removeObject:album];
    [self.tableView reloadData];
    [self.navBar popNavigationItemAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UINavigationBarDelegate

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    [self.navigationController popToRootViewControllerAnimated:YES];
    return YES;
}



#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        UITextField* textField = [alertView textFieldAtIndex:0];
        [self addNewAlbum:textField.text];
    }
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    UITextField* textField = [alertView textFieldAtIndex:0];
    return textField.text.length > 0 ? YES : NO;
}

#pragma mark - Segue

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"ARAlbumDetailsViewController"]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Notifications 

- (void) didLogout {
    
    self.selectedIndexPath = nil;
    [self.albums removeAllObjects];
    if (self.nowPlayingButton) {
        [self.nowPlayingButton removeFromSuperview];
    }
    [self.tableView reloadData];
}


@end

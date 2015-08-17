//
//  ARSettingsViewController.m
//  VK Music
//
//  Created by Artur Remizov on 18.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARSettingsViewController.h"
#import "ARServerManager.h"
#import "ARAccessToken.h"
#import "UIKit+AFNetworking.h"
#import "ARUser.h"
#import "ARPlayer.h"

@interface ARSettingsViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) UINavigationItem* navItem;

@end

@implementation ARSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UINavigationBar* navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 94.3, CGRectGetWidth(self.navigationController.view.bounds), 44)];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.navigationController.view addSubview:navBar];
    
    UINavigationItem* navItem = [[UINavigationItem alloc]initWithTitle:@"Settings"];
    navBar.items = @[navItem];
    self.navItem = navItem;
    
    
    if (![ARServerManager sharedManager].currentUser) {
        [self getUserFromServer];
    } else {
        [self setUserInfo:[ARServerManager sharedManager].currentUser];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUserFromServer)
                                                 name:ARServerManagerDidAutorizeNewUserNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setUserInfo:(ARUser*) user {
    
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:user.imageURL];
    
    [self.userImage setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       self.userImage.image = image;
                                       self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
                                       self.userImage.layer.masksToBounds = YES;
                                       
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       
                                   }];
    
    
}

#pragma mark - API

- (void) getUserFromServer {
    
    [[ARServerManager sharedManager]
     getUser:[ARServerManager sharedManager].accessToken.userID
     onSuccess:^(ARUser *user) {
         
         [self setUserInfo:user];
         
     }
     onFailure:^(NSError *error, NSInteger statusCode) {
         
         
     }];
    
}

#pragma mark - Action

- (IBAction)actionLogout:(UIButton*)sender {
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Logout"
                                                       message:@"Are you sure to logout?"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Logout", nil];
    alertView.delegate = self;
    [alertView show];
    
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [[ARServerManager sharedManager] logout];
    }
    
}


@end

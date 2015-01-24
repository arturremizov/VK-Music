//
//  ARViewController.m
//  VK Music
//
//  Created by Artur Remizov on 04.01.15.
//  Copyright (c) 2015 Artur Remizov. All rights reserved.
//

#import "ARViewController.h"
#import "ARPlayer.h"
#import "ARNowPlayingViewController.h"
#import "ARTransitionAnimator.h"

@interface ARViewController () <UIViewControllerTransitioningDelegate, ARNowPlayingViewControllerDelegate>

@end

@implementation ARViewController

- (void) addCustomNavigationBar {
    
    UINavigationBar* navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 94.3, CGRectGetWidth(self.navigationController.view.bounds), 44)];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIColor* tintColor = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    navBar.tintColor = tintColor;
    [self.navigationController.view addSubview:navBar];
    self.navBar = navBar;
    
    
    UINavigationItem* navItem = [[UINavigationItem alloc]init];
    self.navBar.items = @[navItem];
    self.navItem = navItem;
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    if ([ARPlayer sharedPlayer].isNowPlaying) {
        [self addNowPlayingButtonAnimated:NO];
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if ([ARPlayer sharedPlayer].isNowPlaying && !self.navItem.rightBarButtonItem) {
        [self addNowPlayingButtonAnimated:NO];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addNowPlayingButtonAnimated:(BOOL) animated {
    
    UIView* containerView = [[UIView alloc]init];
    
    UIBarButtonItem* item= [[UIBarButtonItem alloc] initWithCustomView:containerView];
    containerView.bounds = CGRectMake(0, 0, 170, 40);
    
    UIButton* nowPlayingButton = [[UIButton alloc] initWithFrame:containerView.bounds];
    nowPlayingButton.adjustsImageWhenHighlighted = NO;
    UIColor* color = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
    NSDictionary* attr = @{NSFontAttributeName: [UIFont systemFontOfSize:17.f],
                           NSForegroundColorAttributeName: color};
    
    NSAttributedString* title = [[NSAttributedString alloc]initWithString:@"Now Playing" attributes:attr];
    [nowPlayingButton setAttributedTitle:title forState:UIControlStateNormal];
    
    
    attr = @{NSFontAttributeName: [UIFont systemFontOfSize:17.f],
             NSForegroundColorAttributeName: [color colorWithAlphaComponent:0.2f]};
    title = [[NSAttributedString alloc]initWithString:@"Now Playing" attributes:attr];
    
    [nowPlayingButton setAttributedTitle:title forState:UIControlStateHighlighted];
    
    
    [nowPlayingButton setImage:[UIImage imageNamed:@"arrow-foward.png"] forState:UIControlStateNormal];
    [nowPlayingButton setImage:[UIImage imageNamed:@"arrow-foward_h.png"] forState:UIControlStateHighlighted];
    [nowPlayingButton setImageEdgeInsets:UIEdgeInsetsMake(0, 125, 0, -125)];
    
    
    [nowPlayingButton addTarget:self action:@selector(actionNowPlaying:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:nowPlayingButton];
    
    if (self.navItem) {
        [self.navItem setRightBarButtonItem:item animated:animated];
    } else {
        [self.navigationItem setRightBarButtonItem:item animated:animated];
    }
    self.nowPlayingButton = nowPlayingButton;
    
    
}

- (void) actionNowPlaying:(UIButton*) sender {
    
    [sender setHighlighted:YES];
    
    ARNowPlayingViewController* vc = [[ARNowPlayingViewController alloc]init];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    [ARPlayer sharedPlayer].nowPlayingViewController = vc;
    
}

#pragma mark - ARNowPlayingViewControllerDelegate

- (void)nowPlayingViewControllerWillDismiss {
    [ARPlayer sharedPlayer].nowPlayingViewController = nil;
}


#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    ARTransitionAnimator* animator = [ARTransitionAnimator new];
    animator.presenting = YES;
    
    return animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    ARTransitionAnimator* animator = [ARTransitionAnimator new];
    return animator;
}


@end

//
//  ARLoginViewController.m
//  VK Music
//
//  Created by Artur Remizov on 13.11.14.
//  Copyright (c) 2014 Artur Remizov. All rights reserved.
//

#import "ARLoginViewController.h"
#import "ARAccessToken.h"

@interface ARLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) UIWebView* webView;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (copy, nonatomic) ARCompletionBlock completionBlock;

@end

@implementation ARLoginViewController

- (id)initWithCompletionBlock:(void(^)(ARAccessToken* token)) completionBlock
{
    self = [super init];
    if (self) {
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIColor* tintColor = [UIColor colorWithRed:63/255.f green:104/255.f blue:157/255.f alpha:1.f];
    
    self.navigationController.navigationBar.barTintColor = tintColor;
    
    NSDictionary* attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    self.navigationItem.title = @"Log In";
    
    
    CGRect rect = self.view.bounds;
    rect.origin = CGPointZero;
    
    UIWebView* webView = [[UIWebView alloc]initWithFrame:rect];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    NSURL* url = [NSURL URLWithString:@"https://oauth.vk.com/authorize?"
                  "client_id=4621089&"
                  "scope=1032&" // +8 +1024
                  "redirect_uri=https://oauth.vk.com/blank.html&"
                  "display=mobile&"
                  "v=5.27&"
                  "response_type=token"];
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    self.webView = webView;
    
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.webView addSubview:self.activityIndicator];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", [[request URL] description]);
    
    if ([[[request URL] description] rangeOfString:@"#access_token="].location != NSNotFound) {
        
        ARAccessToken* token = [[ARAccessToken alloc]init];
        
        NSString* query = [[request URL]description];
        NSArray* array = [query componentsSeparatedByString:@"#"];
        
        if ([array count] > 1) {
            query = [array lastObject];
            NSArray* pairs = [query componentsSeparatedByString:@"&"];
            
            for (NSString* pair in pairs) {
                NSArray* values = [pair componentsSeparatedByString:@"="];
                
                if ([values count] == 2) {
                    NSString* key = [values firstObject];
                    
                    if ([key isEqualToString:@"access_token"]) {
                        
                        token.token = [values lastObject];
                        
                    } else if ([key isEqualToString:@"expires_in"]) {
                        
                        NSTimeInterval interval = [[values lastObject]doubleValue];
                        token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                        
                    } else if ([key isEqualToString:@"user_id"]) {
                        token.userID = [values lastObject];
                    }
                }
            }
        }
        
        if (self.completionBlock) {
            self.completionBlock(token);
            
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return NO;
    }
    
    
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}

@end

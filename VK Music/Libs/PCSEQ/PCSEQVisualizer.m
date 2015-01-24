//
//  HNHHEQVisualizer.m
//  HNHH
//
//  Created by Dobango on 9/17/13.
//  Copyright (c) 2013 RC. All rights reserved.
//

#import "PCSEQVisualizer.h"
#import "UIImage+Color.h"

#define kWidth 4 //12
#define kHeight 16 //50
#define kPadding 1

@interface PCSEQVisualizer ()


@end


@implementation PCSEQVisualizer
{
    NSTimer* timer;
    NSArray* barArray;
}
- (id)initWithNumberOfBars:(int)numberOfBars
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kPadding*numberOfBars+(kWidth*numberOfBars), kHeight);
        [self setupVisualizerWithNumberOfBars:numberOfBars];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupVisualizerWithNumberOfBars:3];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}

- (void) setupVisualizerWithNumberOfBars:(NSInteger) numberOfBars {
    
    NSMutableArray* tempBarArray = [[NSMutableArray alloc]initWithCapacity:numberOfBars];
    
    for(int i=0;i<numberOfBars;i++){
        
        UIImageView* bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kWidth+i*kPadding, 0, kWidth, 1)];
        //bar.image = [UIImage imageWithColor:self.barColor];
        
        UIColor* color = [UIColor colorWithRed:255/255.f green:51/255.f blue:102/255.f alpha:1.f];
        bar.image = [UIImage imageWithColor:color];
        [self addSubview:bar];
        [tempBarArray addObject:bar];
        
    }
    
    barArray = [[NSArray alloc]initWithArray:tempBarArray];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2*2);
    self.transform = transform;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:@"stopTimer" object:nil];
    
}


-(void)start{
    self.isOnPause = NO;
    self.hidden = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:.35 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


-(void)stop{
    
    [timer invalidate];
    timer = nil;
    
}

- (void) pause {
    
    self.isOnPause = YES;
    [self stop];
    
    [UIView animateWithDuration:.35 animations:^{
        
        for(UIImageView* bar in barArray){
            
            CGRect rect = bar.frame;
            rect.size.height = 2;
            bar.frame = rect;
            
        }
        
    }];
    
}

-(void)ticker{
   
    
    [UIView animateWithDuration:.35 animations:^{
        
        for(UIImageView* bar in barArray){
            
            CGRect rect = bar.frame;
            rect.size.height = arc4random() % kHeight + 1;
            bar.frame = rect;
            
            
        }
    
    }];
}

@end

//
//  AddAnimationController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/22.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "AddAnimationController.h"

@interface AddAnimationController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *animationSelectSegment;

- (IBAction)addVideoClick:(UIButton *)sender;
- (IBAction)videoOutputClick:(UIButton *)sender;

@end

@implementation AddAnimationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SuperClass Method

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 星星Image
    UIImage *animationImage = [UIImage imageNamed:@"star"];
    
    // 图层A
    CALayer *overlayLayerA = [CALayer layer];
    [overlayLayerA setContents:(id)[animationImage CGImage]];
    [overlayLayerA setFrame:CGRectMake(size.width / 2 - 64, size.height / 2 + 200, 120, 120)];
    [overlayLayerA setMasksToBounds:YES];
    
    // 图层B
    CALayer *overlayLayerB = [CALayer layer];
    [overlayLayerB setContents:(id)[animationImage CGImage]];
    [overlayLayerB setFrame:CGRectMake(size.width / 2 - 64, size.height / 2 - 200, 128, 128)];
    [overlayLayerB setMasksToBounds:YES];
    
    // 旋转
    if (self.animationSelectSegment.selectedSegmentIndex == 0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [animation setDuration:2.0];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        
        // 从0到360旋转
        [animation setFromValue:[NSNumber numberWithFloat:0.0]];
        [animation setToValue:[NSNumber numberWithFloat:(2 * M_PI)]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerA addAnimation:animation forKey:@"rotation"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [animation setDuration:2.0];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        
        // 从0到360旋转
        [animation setFromValue:[NSNumber numberWithFloat:0]];
        [animation setToValue:[NSNumber numberWithFloat:(2 * M_PI)]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerB addAnimation:animation forKey:@"rotation"];
        
    } else if (self.animationSelectSegment.selectedSegmentIndex == 1) {     // 逐渐变淡
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setDuration:3.0];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        
        // 从看到变到看不到
        [animation setFromValue:[NSNumber numberWithFloat:1]];
        [animation setToValue:[NSNumber numberWithFloat:0]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerA addAnimation:animation forKey:@"animateOpacity"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setDuration:3];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        
        // 从看不到到看到
        [animation setFromValue:[NSNumber numberWithFloat:1]];
        [animation setToValue:[NSNumber numberWithFloat:0]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerB addAnimation:animation forKey:@"animateOpacity"];
        
    } else {    // 闪烁
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setDuration:0.5];
        [animation setRepeatCount:10];
        [animation setAutoreverses:YES];
        
        // 从一半尺寸变到全尺寸
        [animation setFromValue:[NSNumber numberWithFloat:0.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerA addAnimation:animation forKey:@"scale"];
        
        animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [animation setDuration:1];
        [animation setRepeatCount:5];
        [animation setAutoreverses:YES];
        // 从一半尺寸变到全尺寸
        [animation setFromValue:[NSNumber numberWithFloat:0.5]];
        [animation setToValue:[NSNumber numberWithFloat:1]];
        [animation setBeginTime:AVCoreAnimationBeginTimeAtZero];
        [overlayLayerB addAnimation:animation forKey:@"scale"];
    }
    
    // 视频图层
    CALayer *videoLayer = [CALayer layer];
    [videoLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // 父图层
    CALayer *parentLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayerA];
    [parentLayer addSublayer:overlayLayerB];
    
    // AVMutableVideoComposition
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

#pragma mark - User Action

- (IBAction)addVideoClick:(UIButton *)sender
{
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (IBAction)videoOutputClick:(UIButton *)sender
{
    [self videoOutput];
}

@end

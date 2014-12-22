//
//  AddTiltController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/22.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "AddTiltController.h"

@interface AddTiltController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *tiltSegment;

- (IBAction)addVideoClick:(UIButton *)sender;
- (IBAction)videoOutputClick:(UIButton *)sender;

@end

@implementation AddTiltController

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
    // 视频图层
    CALayer *videoLayer = [CALayer layer];
    [videoLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // 父图层
    CALayer *parentLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [parentLayer addSublayer:videoLayer];
    
    // 设置CATransform3D
    CATransform3D identityTransform = CATransform3DIdentity;
    
    // 判断形变方向
    if (self.tiltSegment.selectedSegmentIndex == 0) {
        identityTransform.m34 = 1.0 / 1000;
    } else {
        identityTransform.m34 = 1.0 / -1000;
    }
    
    // 旋转
    videoLayer.transform = CATransform3DRotate(identityTransform, M_PI / 6.0, 1.0, 0.0, 0.0);

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

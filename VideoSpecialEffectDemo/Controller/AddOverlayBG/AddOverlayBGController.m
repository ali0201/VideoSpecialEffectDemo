//
//  AddOverLayerController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/22.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "AddOverlayBGController.h"

@interface AddOverlayBGController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *frameSelectSegment;

- (IBAction)addVideoClick:(UIButton *)sender;
- (IBAction)videoOutputClick:(UIButton *)sender;

@end

@implementation AddOverlayBGController

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
    // 选择背景图片，背景图层
    CALayer *overlayBGLayer = [CALayer layer];
    UIImage *overlayBGImage;
    
    switch (self.frameSelectSegment.selectedSegmentIndex) {
        case 0:
            overlayBGImage = [UIImage imageNamed:@"Frame-1"];
            break;
        case 1:
            overlayBGImage = [UIImage imageNamed:@"Frame-2"];
            break;
        case 2:
            overlayBGImage = [UIImage imageNamed:@"Frame-3"];
            break;
        default:
            break;
    }
    
    [overlayBGLayer setContents:(id)[overlayBGImage CGImage]];
    [overlayBGLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [overlayBGLayer setMasksToBounds:YES];
    
    // 视频图层
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);

    // 父图层
    CALayer *parentLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayBGLayer];
    
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

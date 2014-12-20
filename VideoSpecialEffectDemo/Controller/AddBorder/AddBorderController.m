//
//  AddBorderController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/19.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "AddBorderController.h"

@interface AddBorderController ()
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
>

@property (weak, nonatomic) IBOutlet UISlider *widthBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegment;

- (IBAction)addVideoClick:(UIButton *)sender;
- (IBAction)videoOutputClick:(UIButton *)sender;

@end

@implementation AddBorderController

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
    UIImage *borderImage;
    
    switch (self.colorSegment.selectedSegmentIndex) {
        case 0:
            borderImage = [self imageWithColor:[UIColor blueColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
            break;
        case 1:
            borderImage = [self imageWithColor:[UIColor redColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
            break;
        case 2:
            borderImage = [self imageWithColor:[UIColor greenColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
            break;
        case 3:
            borderImage = [self imageWithColor:[UIColor whiteColor] rectSize:CGRectMake(0, 0, size.width, size.height)];
            break;
        default:
            break;
    }
    
    CALayer *backgroundLayer = [CALayer layer];
    [backgroundLayer setContents:(id)[borderImage CGImage]];
    backgroundLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [backgroundLayer setMasksToBounds:YES];
    
    CALayer *videoLayer = [CALayer layer];
    CGFloat videoLayerX = self.widthBar.value;
    CGFloat videoLayerY = self.widthBar.value;
    CGFloat videoLayerW = size.width - (self.widthBar.value * 2);
    CGFloat videoLayerH = size.height - (self.widthBar.value * 2);
    videoLayer.frame = CGRectMake(videoLayerX, videoLayerY, videoLayerW, videoLayerH);

    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:backgroundLayer];
    [parentLayer addSublayer:videoLayer];
   
    composition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

#pragma mark - Private Method

- (UIImage *)imageWithColor:(UIColor *)color rectSize:(CGRect)imageSize
{
    CGRect rect = imageSize;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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

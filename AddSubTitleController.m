//
//  AddSubTitleController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/22.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "AddSubTitleController.h"

@interface AddSubTitleController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *subTitleTextField;

- (IBAction)addVideoClick:(UIButton *)sender;
- (IBAction)videoOutputClick:(UIButton *)sender;

@end

@implementation AddSubTitleController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.subTitleTextField resignFirstResponder];
}

#pragma mark - SuperClass Method

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 设置子标题图层
    CATextLayer *subTitle = [CATextLayer layer];
    [subTitle setFont:@"Helvetica-Bold"];
    [subTitle setFontSize:36];
    [subTitle setFrame:CGRectMake(0, 0, size.width, 100)];
    [subTitle setString:self.subTitleTextField.text];
    [subTitle setAlignmentMode:kCAAlignmentCenter];
    [subTitle setForegroundColor:[[UIColor whiteColor] CGColor]];
    
    // 设置覆盖图层，添加子标题图层
    CALayer *overlayLayer = [CALayer layer];
    [overlayLayer addSublayer:subTitle];
    [overlayLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [overlayLayer setMasksToBounds:YES];
    
    // 视频图层
    CALayer *videoLayer = [CALayer layer];
    [videoLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    
    // 父图层
    CALayer *parentLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
   
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

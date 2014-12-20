//
//  CommonVideoController.h
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/19.
//  Copyright (c) 2014年 HGG. All rights reserved.
//
//  父类
//

#import <UIKit/UIKit.h>
@import MobileCoreServices;
@import AssetsLibrary;
@import AVFoundation;

@interface CommonVideoController : UIViewController
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIAlertViewDelegate
>

@property (nonatomic, strong) AVAsset *videoAsset;

/**
 *  判断是从哪个VC操作
 *
 *  @param controller UIViewController
 *  @param delegate   delegate
 *
 *  @return BOOL
 */
- (void)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate;

/**
 *  加载特效到视频
 *
 *  @param composition AVMutableVideoComposition
 *  @param size        CGSize
 */
- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size;

/**
 *  完成输出视频
 *
 *  @param session AVAssetExportSession
 */
- (void)exportDidFinish:(AVAssetExportSession *)session;

/**
 *  视频输出
 */
- (void)videoOutput;

@end

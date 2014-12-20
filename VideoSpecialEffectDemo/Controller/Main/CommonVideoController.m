//
//  CommonVideoController.m
//  VideoSpecialEffectDemo
//
//  Created by Kevin on 14/12/19.
//  Copyright (c) 2014年 HGG. All rights reserved.
//

#import "CommonVideoController.h"
#import <SVProgressHUD.h>

@interface CommonVideoController ()

@property (nonatomic, strong) UIViewController *subVC;
@property (nonatomic, weak) id delegate;

@end

@implementation CommonVideoController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Method

- (void)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate
{
    self.subVC = controller;
    self.delegate = delegate;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"hello" message:@"视频从相册选择还是自拍？" delegate:self cancelButtonTitle:@"相册" otherButtonTitles:@"自拍", nil];
    [alert show];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 子类去重写
}

- (void)videoOutput
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    // 判断是否选择了一段视频
    if (!self.videoAsset) {
        [SVProgressHUD showErrorWithStatus:@"先选择一段视频" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    // AVMutableComposition
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // AVMutableCompositionTrack
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange ranges = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    AVAssetTrack *ofTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [videoTrack insertTimeRange:ranges ofTrack:ofTrack atTime:kCMTimeZero error:nil];
    
    // AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation = UIImageOrientationUp;
    
    BOOL isVideoAssetPortrait = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation = UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation = UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation = UIImageOrientationDown;
    }
    [videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    // add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction, nil];
    
    // mainCompositionInst
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    CGSize naturalSize;
    if (isVideoAssetPortrait) {
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth,renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 得到导出视频的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *randomStr = [NSString stringWithFormat:@"FinalVideo-%d.mov",arc4random() % 1000];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:randomStr];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 导出视频
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession *)session
{
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error) {
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:@"保存失败" maskType:SVProgressHUDMaskTypeBlack];
                    } else {
                        [SVProgressHUD showSuccessWithStatus:@"保存成功" maskType:SVProgressHUDMaskTypeBlack];
                    }
                });
                
            }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // mediaType
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 处理选择的视频
    if (CFStringCompare((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        self.videoAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        [SVProgressHUD showSuccessWithStatus:@"视频已加载" maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 验证
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO || self.delegate == nil || self.subVC == nil) {
        return;
    }
    
    // UIImagePickerController
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    if (buttonIndex == 0) {
        mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        mediaUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self.delegate;
    
    [self.subVC presentViewController:mediaUI animated:YES completion:nil];
}

@end

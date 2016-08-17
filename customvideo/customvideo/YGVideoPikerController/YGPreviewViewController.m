//
//  YGPreviewViewController.m
//  customvideo
//
//  Created by zhangkaifeng on 16/7/4.
//  Copyright © 2016年 ccyouge. All rights reserved.
//

#import "YGPreviewViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface YGPreviewViewController ()

@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;//视频播放控制器

@end

@implementation YGPreviewViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [_moviePlayer stop];
    //点x说明不要 删掉
    [[NSFileManager defaultManager]removeItemAtPath:[_videoFileURL path] error:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
}

-(void)configUI
{
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = YES;
    //视频
    _moviePlayer = [[MPMoviePlayerController alloc]initWithContentURL:_videoFileURL];
    _moviePlayer.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width *(480.0/360.0));
    _moviePlayer.view.backgroundColor = [UIColor clearColor];
    _moviePlayer.controlStyle = MPMovieControlStyleNone;
    _moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer play];
    
    //x号
    //关闭按钮
    UIButton *xButton = [[UIButton alloc]init];
    [xButton setBackgroundImage:[UIImage imageNamed:@"xianzhi_luzhi_quxiao.png"] forState:UIControlStateNormal];
    [xButton sizeToFit];
    xButton.frame = CGRectMake(20, 0, xButton.frame.size.width, xButton.frame.size.height);
    xButton.center =  CGPointMake(xButton.center.x, _moviePlayer.view.frame.origin.y + _moviePlayer.view.frame.size.height + (self.view.frame.size.height - _moviePlayer.view.frame.origin.y - _moviePlayer.view.frame.size.height)/2);
    [xButton addTarget:self action:@selector(xButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:xButton];
    
    //确认按钮
    UIButton *yesButton = [[UIButton alloc]init];
    [yesButton setBackgroundImage:[UIImage imageNamed:@"xianzhi_luzhi_right.png"] forState:UIControlStateNormal];
    [yesButton sizeToFit];
    yesButton.frame = CGRectMake(self.view.frame.size.width - yesButton.frame.size.width - xButton.frame.origin.x, 0, yesButton.frame.size.width, yesButton.frame.size.height);
    yesButton.center =  CGPointMake(yesButton.center.x, xButton.center.y);
    [yesButton addTarget:self action:@selector(yesButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:yesButton];
}

-(void)xButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)yesButtonClick
{
    NSString *MP4PathString = [NSTemporaryDirectory() stringByAppendingPathComponent:@"ygtempmovie.mp4"];
    //先把上次的删了
    [[NSFileManager defaultManager] removeItemAtPath:MP4PathString error:nil];
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSLog(@"%@",compatiblePresets);
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality])
    {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = [NSURL fileURLWithPath:MP4PathString];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     
                     NSLog(@"AVAssetExportSessionStatusUnknown");
                     
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     
                     NSLog(@"AVAssetExportSessionStatusWaiting");
                     
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     
                     NSLog(@"AVAssetExportSessionStatusExporting");
                     
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     
                     //跳回主线程
                     [self performSelectorOnMainThread:@selector(completeConventWithPathString:) withObject:MP4PathString waitUntilDone:NO];
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     
                     NSLog(@"AVAssetExportSessionStatusFailed");
                     
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     NSLog(@"AVAssetExportSessionStatusCancelled");
                     
                     break;
             }
             
         }];
        
        
    }
}

-(void)completeConventWithPathString:(NSString *)MP4PathString
{
    //显示缩略图
    UIImage *thumbImage = [self getImage:MP4PathString];
    //执行代理
    [_delegate YGPreviewViewController:self didPressYesButtonWithMP4FilePath:MP4PathString thumbImage:thumbImage];
}

//缩略图
-(UIImage *)getImage:(NSString *)videoURL
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return thumb;
}

@end

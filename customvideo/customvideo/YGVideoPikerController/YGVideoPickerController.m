//
//  ViewController.m
//  customvideo
//
//  Created by zhangkaifeng on 16/7/2.
//  Copyright © 2016年 ccyouge. All rights reserved.
//

#import "YGVideoPickerController.h"
#import "YGPreviewViewController.h"

@interface YGVideoPickerController ()<AVCaptureFileOutputRecordingDelegate,YGPreviewViewControllerDelegate>

@property (strong,nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong,nonatomic) AVCaptureDeviceInput *cameraDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureDeviceInput *audioDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic) AVCaptureMovieFileOutput *movieFileOutPut;//movie的文件输出
@property (strong,nonatomic) UILabel *stateLabel;//状态label
@property (strong,nonatomic) UILabel *timeLabel; //秒数Label

@end

@implementation YGVideoPickerController
{
    //进度条
    UIProgressView *_videoProgressView;
    //时钟
    NSTimer *_timer;
    //闪光灯
    UIButton *_flashButton;
    //时间够不够
    BOOL _enoughTime;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSFileManager defaultManager]removeItemAtPath:[_movieFileOutPut.outputFileURL path] error:nil];;
    [self configSettings];
    
    [self configCamera];
    
    [self configCameraUI];
}

//初始化属性
-(void)configSettings
{
    //如果没给最大时间
    if (_maxVideoTime == 0)
    {
        _maxVideoTime = 7.0;
    }
    
    //如果没给质量
}

//初始化摄像头麦克风
-(void)configCamera
{
    self.navigationController.navigationBarHidden = YES;
    //获得后置摄像头
    AVCaptureDevice *backCameraCaptureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    //初始化摄像头输入设备
    _cameraDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:backCameraCaptureDevice error:nil];
    //获得麦克风
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //初始化麦克风设备
    _audioDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:nil];
    //初始化movie输出
    _movieFileOutPut = [[AVCaptureMovieFileOutput alloc]init];
    
    //初始化会话
    _captureSession = [[AVCaptureSession alloc]init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium])
    {//设置分辨率
        _captureSession.sessionPreset=AVCaptureSessionPresetMedium;
    }
    //将输入输出设备添加到会话中
    if ([_captureSession canAddInput:_cameraDeviceInput])
    {
        [_captureSession addInput:_cameraDeviceInput];
    }
    if ([_captureSession canAddInput:_audioDeviceInput])
    {
        [_captureSession addInput:_audioDeviceInput];
    }
    if ([_captureSession canAddOutput:_movieFileOutPut])
    {
        [_captureSession addOutput:_movieFileOutPut];
    }
    
    //创建一个预览涂层
    AVCaptureVideoPreviewLayer *preLayer =[AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    preLayer.backgroundColor = [UIColor blackColor].CGColor;
    //设置图层的大小
    preLayer.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.width *(480.0/360.0));
    //添加到view上
    [self.view.layer addSublayer:preLayer];
    //开始会话
    [_captureSession startRunning];
    
}

//初始化摄像头UI
-(void)configCameraUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    //闪光灯按钮
    _flashButton= [[UIButton alloc]init];
    [_flashButton setImage:[UIImage imageNamed:@"xianzhi_luzhi_shanguang.png"] forState:UIControlStateNormal];
    [_flashButton setImage:[UIImage imageNamed:@"xianzhi_luzhi_shanguang_yellow.png"] forState:UIControlStateSelected];
    [_flashButton sizeToFit];
    _flashButton.center = CGPointMake(0, 44/2);
    _flashButton.frame= CGRectMake(10, _flashButton.frame.origin.y, _flashButton.frame.size.width, _flashButton.frame.size.height);
    [_flashButton addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    
    //切换前后按钮
    UIButton *switchCameraButton = [[UIButton alloc]init];
    [switchCameraButton setImage:[UIImage imageNamed:@"xianzhi_luzhi_fanzhuan.png"] forState:UIControlStateNormal];
    [switchCameraButton sizeToFit];
    switchCameraButton.center = CGPointMake(0, 44/2);
    switchCameraButton.frame= CGRectMake(self.view.frame.size.width - _flashButton.frame.origin.x - switchCameraButton.frame.size.width, switchCameraButton.frame.origin.y, switchCameraButton.frame.size.width, switchCameraButton.frame.size.height);
    [switchCameraButton addTarget:self action:@selector(switchCameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchCameraButton];
    
    //状态label
    _stateLabel = [[UILabel alloc]initWithFrame:CGRectMake(_flashButton.frame.origin.x + _flashButton.frame.size.width, 0, self.view.frame.size.width -(_flashButton.frame.origin.x + _flashButton.frame.size.width) *2, 20)];
    _stateLabel.text = @"按住白色按钮来拍摄";
    _stateLabel.font = [UIFont systemFontOfSize:14];
    _stateLabel.textColor = [UIColor whiteColor];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.center = CGPointMake(self.view.frame.size.width/2, _flashButton.center.y);
    [self.view addSubview:_stateLabel];
    
    //进度条
    _videoProgressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.width *(480.0/360.0) + 44, self.view.frame.size.width, 5)];
    _videoProgressView.tintColor = [UIColor
                                    colorWithRed:((float)((0x32be5a & 0xFF0000) >> 16))/255.0 \
                                    green:((float)((0x32be5a & 0xFF00) >> 8))/255.0 \
                                    blue:((float)(0x32be5a & 0xFF))/255.0 alpha:1];
    _videoProgressView.trackTintColor = [UIColor clearColor];
    _videoProgressView.transform = CGAffineTransformMakeScale(1.0f,2.0f);
    [self.view addSubview:_videoProgressView];
    
    //录像按钮
    UIButton *videoButton = [[UIButton alloc]init];
    [videoButton setBackgroundImage:[UIImage imageNamed:@"xianzhi_luzhi_dianji.png"] forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(videoButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [videoButton addTarget:self action:@selector(videoButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [videoButton sizeToFit];
    videoButton.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height - _videoProgressView.frame.origin.y - _videoProgressView.frame.size.height) / 2 + _videoProgressView.frame.origin.y + _videoProgressView.frame.size.height);
    [self.view addSubview:videoButton];
    
    //关闭按钮
    UIButton *xButton = [[UIButton alloc]init];
    [xButton setBackgroundImage:[UIImage imageNamed:@"xianzhi_luzhi_quxiao.png"] forState:UIControlStateNormal];
    [xButton sizeToFit];
    xButton.frame = CGRectMake(20, 0, xButton.frame.size.width, xButton.frame.size.height);
    xButton.center =  CGPointMake(xButton.center.x, videoButton.center.y);
    [xButton addTarget:self action:@selector(xButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:xButton];
    
    //秒数label
    _timeLabel = [[UILabel alloc]init];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.text = @"0.00秒";
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(self.view.frame.size.width - _timeLabel.frame.size.width - 20, 0, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    _timeLabel.center = CGPointMake(_timeLabel.center.x, xButton.center.y);
    [self.view addSubview:_timeLabel];
}

-(void)xButtonClick
{
    [_captureSession stopRunning];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//闪光灯按钮点击
-(void)flashButtonClick:(UIButton *)button
{
    //选中状态改变
    button.selected = !button.selected;
    //调用开启关闭闪光灯方法
    [self flashlight:button.selected];
}

//切换摄像头按钮点击
-(void)switchCameraButtonClick:(UIButton *)button
{
    //选中状态改变
    button.selected = !button.selected;
    //调用切换摄像头方法
    [self cameraSwitch:button.selected];
    //如果变成前置摄像头了
    if (button.selected == YES)
    {
        //闪光灯变成非选中状态
        _flashButton.selected = NO;
    }
    
    //闪光灯的隐藏状态取决于前后摄像头
    _flashButton.hidden = button.selected;
    
}

//闪光灯开启关闭
-(void)flashlight:(BOOL)on
{
    //拿到摄像头input的device
    AVCaptureDevice *backCameraCaptureDevice = _cameraDeviceInput.device;
    //如果这个device有闪光灯（后置摄像头input的device就没有闪光灯）
    if ([backCameraCaptureDevice hasTorch])
    {
        
        [backCameraCaptureDevice lockForConfiguration:nil];
        if (on)
        {
            [backCameraCaptureDevice setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [backCameraCaptureDevice setTorchMode:AVCaptureTorchModeOff];
        }
        [backCameraCaptureDevice unlockForConfiguration];
    }
}

//前后摄像头切换
-(void)cameraSwitch:(BOOL)frontCamera
{
    //会话开始设置
    [_captureSession beginConfiguration];
    //先移除原来的摄像头input
    [_captureSession removeInput:_cameraDeviceInput];
    //新建一个摄像头device
    AVCaptureDevice *newCamera;
    if (frontCamera)
    {
        newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    }
    
    else
    {
        newCamera = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    //根据摄像头device初始化新的摄像头input
    _cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    //加进去
    [_captureSession addInput:_cameraDeviceInput];
    //提交更改
    [_captureSession commitConfiguration];
}

//录像键按下
-(void)videoButtonTouchDown
{
    //初始化timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(videoButtonTouchDownTimer) userInfo:nil repeats:YES];
    //开始录制
    [_movieFileOutPut startRecordingToOutputFileURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"ygtempmovie.mov"]]        recordingDelegate:self];
}

//录像键抬起
-(void)videoButtonTouchUpInside
{
    //如果松手的时候时间不够
    if ([[_timeLabel.text stringByReplacingOccurrencesOfString:@"秒" withString:@""] floatValue] < _minVideoTime)
    {
        _enoughTime = NO;
        NSLog(@"录制时间小于最小时间");
        _stateLabel.text = [NSString stringWithFormat:@"录像时间不能小于%.0f秒哦",_minVideoTime];
    }
    else
    {
        _enoughTime = YES;
        _stateLabel.text = @"按住白色按钮来拍摄";
    }
    //停止录制
    [_movieFileOutPut stopRecording];
    //松手就关掉timer，进度回到0
    [self formatCamera];
}

//录像键按下timer
-(void)videoButtonTouchDownTimer
{
    //更改秒数
    NSString *timeString = [_timeLabel.text stringByReplacingOccurrencesOfString:@"秒" withString:@""];
    _timeLabel.text = [NSString stringWithFormat:@"%.2f秒",timeString.floatValue + _timer.timeInterval];
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(self.view.frame.size.width - _timeLabel.frame.size.width - 20, _timeLabel.frame.origin.y, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
    
    //更改进度条进度
    [_videoProgressView setProgress: _videoProgressView.progress + 1.0/(_maxVideoTime /_timer.timeInterval) animated:YES];
    //如果进度条满了
    if (_videoProgressView.progress >=1.0)
    {
        [self videoButtonTouchUpInside];
        NSLog(@"到达最大时间");
    }
    
}

//格式化摄像头进图条到初始值
-(void)formatCamera
{
    [_timer invalidate];
    _timer = nil;
    _videoProgressView.progress = 0.0;
    _timeLabel.text = @"0.00秒";
    [_timeLabel sizeToFit];
    _timeLabel.frame = CGRectMake(self.view.frame.size.width - _timeLabel.frame.size.width - 20, _timeLabel.frame.origin.y, _timeLabel.frame.size.width, _timeLabel.frame.size.height);
}

//开始录制回调
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"start record video");
    _stateLabel.text = @"正在录制";
}

//录制完成回调
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"error:%@",error.localizedDescription);
    
    //如果时间不够
    if (!_enoughTime)
    {
        //录像时间不够删掉
        [[NSFileManager defaultManager]removeItemAtPath:[_movieFileOutPut.outputFileURL path] error:nil];
        return;
    }
    
    //跳转 
    YGPreviewViewController *previewController = [[YGPreviewViewController alloc]init];
    previewController.videoFileURL = outputFileURL;
    previewController.delegate = self;
    [self.navigationController pushViewController:previewController animated:YES];
}

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras)
    {
        if ([camera position]==position)
        {
            return camera;
        }
    }
    return nil;
}

-(void)YGPreviewViewController:(YGPreviewViewController *)controller didPressYesButtonWithMP4FilePath:(NSString *)path thumbImage:(UIImage *)thumbImage
{
    [_captureSession stopRunning];
    //执行代理
    [_delegate YGVideoPickerController:self didPressYesButtonWithMP4FilePath:path thumbImage:thumbImage];
    
    //关闭自己
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

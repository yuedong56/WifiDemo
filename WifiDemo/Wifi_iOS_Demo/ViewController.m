//
//  ViewController.m
//  Wifi_iOS_Demo
//
//  Created by yuedongkui on 16/8/3.
//  Copyright © 2016年 LY. All rights reserved.
//


#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIAlertView+Common.h"
#import "SocketViewController.h"

static const char *kScanQRCodeQueueName = "ScanQRCodeQueue";

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) UIView *sanFrameView;
@property (strong, nonatomic) UIButton *startButton;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _sanFrameView = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth-200)/2, 100, 200, 200)];
    _sanFrameView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_sanFrameView];
    
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_startButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    _startButton.frame = CGRectMake(ScreenWidth/2-80, ScreenHeight - 100, 160, 50);
    [_startButton addTarget:self action:@selector(startScanner:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
}

#pragma mark - 
- (void)startScanner:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"开始扫描"]) {
        [self startReading];
    } else {
        [self stopReading];
    }
}

#pragma mark -
- (BOOL)startReading
{
    [_startButton setTitle:@"停止" forState:UIControlStateNormal];
    // 获取 AVCaptureDevice 实例
    NSError * error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    // 初始化输出流
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:captureMetadataOutput];
    
    // 创建dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create(kScanQRCodeQueueName, NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // 设置元数据类型 AVMetadataObjectTypeQRCode
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // 创建输出对象
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_sanFrameView.layer.bounds];
    [_sanFrameView.layer addSublayer:_videoPreviewLayer];
    // 开始会话
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReading
{
    [_startButton setTitle:@"开始扫描" forState:UIControlStateNormal];
    // 停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
}

#pragma AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
      fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        NSString *result;
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            result = metadataObj.stringValue;
        } else {
            NSLog(@"不是二维码");
        }
        [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:result waitUntilDone:NO];
    }
}

- (void)reportScanResult:(NSString *)result
{
    [self stopReading];
    
    [UIAlertView alertWithTitle:[NSString stringWithFormat:@"扫描成功 : %@", result] msg:@"是否连接到电脑？" btnTitle:@"取消" otherBtnTitle:@"连接" block:^(NSInteger buttonIndex)
     {
         if (buttonIndex == 1) {
             NSArray *resultArr = [result componentsSeparatedByString:@":"];
             SocketViewController *v = [[SocketViewController alloc] initWithIP:resultArr[0] port:[resultArr[1] integerValue]];
             [self.navigationController pushViewController:v animated:YES];
         }
    }];
}


#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

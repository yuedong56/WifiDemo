//
//  SocketViewController.m
//  WifiDemo
//
//  Created by yuedongkui on 16/8/3.
//  Copyright © 2016年 LY. All rights reserved.
//

#import "SocketViewController.h"
#import "MBProgressHUD.h"
#import "GCDAsyncSocket.h"

@interface SocketViewController ()
{
    NSString *_host_ip;
    NSInteger _port;
    
    UITextView *_textView;
    UIButton *_sendButton;
    MBProgressHUD *_progressHUD;
}

@property (strong, nonatomic) GCDAsyncSocket * clientSocket;

@end



@implementation SocketViewController

- (instancetype)initWithIP:(NSString *)ip port:(NSInteger)port
{
    self = [super init];
    if (self) {
        _host_ip = ip;
        _port = port;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    //创建socket
    self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    //连接
    NSError *error = nil;
    [self.clientSocket connectToHost:_host_ip onPort:_port error:&error];
    NSLog(@"error ----- %@, %@, %ld", error, _host_ip, _port);
    //
    [self creatUI];
}

- (void)creatUI {
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.labelText = @"正在连接...";
    [self.view addSubview:_progressHUD];
    [_progressHUD show:YES];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 78, ScreenWidth-30, 80)];
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.layer.cornerRadius = 8;
    _textView.text = @"输入要发送的内容";
    _textView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    [self.view addSubview:_textView];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(ScreenWidth - 80, _textView.frame.origin.y+_textView.frame.size.height+10, 80, 44);
    [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.view addSubview:_sendButton];
    [_sendButton addTarget:self action:@selector(sendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 
- (void)sendButtonClick:(id)sender
{
    [self.clientSocket writeData:[_textView.text dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    _textView.text = nil;
}

#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
//    SocketManager * socketManager = [SocketManager sharedSocketManager];
//    socketManager.mySocket = sock;
    _progressHUD.labelText = @"连接成功";
    [_progressHUD hide:YES afterDelay:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接断开了");
}

//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    NSString *receive = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    _textView.text = nil;
//}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end




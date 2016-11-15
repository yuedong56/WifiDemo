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
#import "NSString+IP.h"

@interface SocketViewController ()
{
    NSString *_ip;
    NSInteger _port;
    
    NSString *_server_ip;
    NSInteger _server_port;
    
    UITextView *_textView;
    UIButton *_sendButton;
    UITextView *_logLabel;
    MBProgressHUD *_progressHUD;
}

@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

@end



@implementation SocketViewController

- (instancetype)initWithIP:(NSString *)ip port:(NSInteger)port
{
    self = [super init];
    if (self) {
        _ip = ip;
        _port = port;
        
        _server_ip = [NSString getIpLocally:@"ios_wifi" ipVersion:4];
        //随机取 11000 - 15000 的值作为 wifi 监听端口
        _server_port = 11000 + arc4random_uniform(4000);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    {
        //创建客户端socket
        self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //连接
        NSError *error = nil;
        [self.clientSocket connectToHost:_ip onPort:_port error:&error];
        NSLog(@"连接...error ----- %@, %@, %ld", error, _ip, _port);
    }
    
    {
        //创建服务端socket
        self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //监听
        NSError *error = nil;
        [self.serverSocket acceptOnPort:_server_port error:&error];
        NSLog(@"监听...error ----- %@, %@, %ld", error, _server_ip, _server_port);
    }
    
    [self creatUI];
}

- (void)creatUI {
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    _progressHUD.labelText = @"正在连接...";
    [self.view addSubview:_progressHUD];
    [_progressHUD show:YES];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 78, ScreenWidth-30, 40)];
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.layer.cornerRadius = 8;
    _textView.text = @"输入要发送的内容";
    _textView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    [self.view addSubview:_textView];
    
    
    _logLabel = [[UITextView alloc] initWithFrame:CGRectMake(15, 120, ScreenWidth-20, 60)];
    _logLabel.textColor = [UIColor whiteColor];
    _logLabel.font = [UIFont systemFontOfSize:10];
    _logLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_logLabel];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendButton.frame = CGRectMake(ScreenWidth - 80, _textView.frame.origin.y+_textView.frame.size.height+10+70, 80, 44);
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
    NSLog(@"连接成功！！！");
    _progressHUD.labelText = @"连接成功";
    [_progressHUD hide:YES afterDelay:1];
    
    //
    _textView.text = [NSString stringWithFormat:@"%@:%ld", _server_ip, (long)_server_port];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接断开❎❎❎❎❎❎❎❎， error:%@", err);
}

#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    self.clientSocket = newSocket;
    [self.clientSocket readDataWithTimeout:0 tag:888];
    NSLog(@"有新的socket接入 %s", __FUNCTION__);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"data === %@", data);
    NSString *receive = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到新消息 ==== %@", receive);
    _logLabel.text = [NSString stringWithFormat:@"%@\n收到消息：%@", _logLabel.text, receive];
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




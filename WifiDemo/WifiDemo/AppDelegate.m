//
//  AppDelegate.m
//  WifiDemo
//
//  Created by yuedongkui on 16/8/2.
//  Copyright © 2016年 LY. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "QREncoder.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface AppDelegate ()<GCDAsyncSocketDelegate>
{
    NSTextField *phoneIPTextField;
    NSTextField *macIPTextField;
}

@property (weak) IBOutlet NSWindow *window;

@property (strong, nonatomic) GCDAsyncSocket *serverSocket;
@property (strong, nonatomic) GCDAsyncSocket *clientSocket;

@property (strong, nonatomic) NSImageView *qrImageView;
@property (assign, nonatomic) u_int32_t port;

@end



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //创建二维码
    [self createQRView];
    [self creatIpTextLabel];
    
    //创建一个socket:
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //监听端口
    NSError * error = nil;
    [self.serverSocket acceptOnPort:self.port error:&error];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

// create QR code that contains sfp address
- (void)createQRView
{
    NSString *ip = [self getIpLocally:@"ios_wifi" ipVersion:4];
    NSLog(@"ip=%@", ip);
    //随机取 11000 - 15000 的值作为 wifi 监听端口
    _port = 11000 + arc4random_uniform(4000);
    NSLog(@"wifi listening port=%d", _port);
    NSString *sfpString = [NSString stringWithFormat:@"%@:%d",ip, _port];
    DataMatrix *qrMatrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_H version:QR_VERSION_AUTO string:sfpString];
    NSImage *qrcodeImage = [QREncoder renderDataMatrix:qrMatrix imageDimension:512 withBgColor:0xFFFFFFFF withCodeColor:0xFF000000];
    self.qrImageView = [[NSImageView alloc] initWithFrame:NSMakeRect((self.window.contentView.frame.size.width-200)/2, (self.window.contentView.frame.size.height-200)/2, 200, 200)];
    [self.qrImageView setImageFrameStyle:NSImageFrameNone];
    [self.qrImageView setImage:qrcodeImage];
    
    self.qrImageView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [self.window.contentView addSubview:self.qrImageView];
    
    //
}

- (void)creatIpTextLabel
{
    phoneIPTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, self.window.contentView.bounds.size.height-40, self.window.contentView.bounds.size.width, 40)];
    phoneIPTextField.stringValue = @"--";
    phoneIPTextField.font = [NSFont systemFontOfSize:20];
    phoneIPTextField.alignment = NSTextAlignmentCenter;
    phoneIPTextField.editable = NO;
    phoneIPTextField.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [self.window.contentView addSubview:phoneIPTextField];
    
    macIPTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, self.window.contentView.bounds.size.width, 40)];
    macIPTextField.stringValue = [NSString stringWithFormat:@"Mac端 ：%@:%d", [self getIpLocally:@"ios_wifi" ipVersion:4], _port];
    macIPTextField.font = [NSFont systemFontOfSize:20];
    macIPTextField.alignment = NSTextAlignmentCenter;
    macIPTextField.editable = NO;
    macIPTextField.autoresizingMask = NSViewWidthSizable | NSViewMaxYMargin;
    [self.window.contentView addSubview:macIPTextField];
}

#pragma mark- GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //连接成功，可查看newSocket.connectedHost和newSocket.connectedPort等参数
    self.clientSocket = newSocket;
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
    
    NSLog(@"有新的socket接入 %s", __FUNCTION__);
    phoneIPTextField.stringValue = [NSString stringWithFormat:@"手机连接成功！"];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receive = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到新消息 ==== %@", receive);
    phoneIPTextField.stringValue = [NSString stringWithFormat:@"手机端 : %@", receive];
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
{
    NSLog(@"连接失败 %s", __FUNCTION__);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"已经发送消息 didWriteDataWithTag -- %ld",tag);
}

#pragma mark -// get IP adress
-(NSString *)getIpLocally:(NSString *)networkInterface ipVersion:(int)ipVersion
{
    if(ipVersion != 4 && ipVersion != 6)
    {
        NSLog(@"getIpLocally unknown version of IP: %i",ipVersion);
        return nil;
    }
    
    NSString *networkInterfaceRef;
    
    if ([networkInterface isEqualToString: @"ios_cellular"])
    {
        networkInterfaceRef = @"pdp_ip0";
    }
    else if([networkInterface isEqualToString: @"ios_wifi"])
    {
        networkInterfaceRef = @"en0"; //en1 on simulator if mac on wifi
    }
    else
    {
        NSLog(@"getIpLocally unknown interface: %@",networkInterface);
        return nil;
    }
    
    NSMutableArray *add = [NSMutableArray array];
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    struct sockaddr_in *s4;
    struct sockaddr_in6 *s6;
    char buf[64];
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if( (ipVersion == 4 && temp_addr->ifa_addr->sa_family == AF_INET) ||
               (ipVersion == 6 &&  temp_addr->ifa_addr->sa_family == AF_INET6))
            {
                NSLog(@"Network Interface: %@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
                [add addObject:add];
                
                if(ipVersion == 4)
                {
                    s4 = (struct sockaddr_in *)temp_addr->ifa_addr;
                    
                    if (inet_ntop(temp_addr->ifa_addr->sa_family, (void *)&(s4->sin_addr), buf, sizeof(buf)) == NULL)
                    {
                        NSLog(@"%s: inet_ntop failed for v4!\n", temp_addr->ifa_name);
                    }
                    else{
                        NSString *newaddress = [NSString stringWithUTF8String:buf];
                        [add addObject:newaddress];
                    }
                }
                if (ipVersion == 6)
                {
                    s6 = (struct sockaddr_in6 *)(temp_addr->ifa_addr);
                    
                    if (inet_ntop(temp_addr->ifa_addr->sa_family, (void *)&(s6->sin6_addr), buf, sizeof(buf)) == NULL)
                    {
                        NSLog(@"%s: inet_ntop failed for v6!\n",temp_addr->ifa_name);
                    }
                    else{
                        NSString *newaddress = [NSString stringWithUTF8String:buf];
                        [add addObject:newaddress];
                    }
                }
                
                
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:networkInterfaceRef])
                {
                    address = [add lastObject];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    if (address ==nil) {
        address = [add lastObject];
    }
    
    return address;
}


@end

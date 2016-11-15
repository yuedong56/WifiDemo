//
//  NSString+IP.m
//  SmartFinder
//
//  Created by yuedongkui on 2016/11/8.
//  Copyright © 2016年 Smartisan. All rights reserved.
//

#import "NSString+IP.h"
#import <ifaddrs.h>
#import <arpa/inet.h>


@implementation NSString (IP)

+ (NSString *)getIpLocally:(NSString *)networkInterface ipVersion:(int)ipVersion
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

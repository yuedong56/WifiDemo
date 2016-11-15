//
//  NSString+IP.h
//  SmartFinder
//
//  Created by yuedongkui on 2016/11/8.
//  Copyright © 2016年 Smartisan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (IP)

+ (NSString *)getIpLocally:(NSString *)networkInterface ipVersion:(int)ipVersion;

@end

//
//  UIAlertView+Common.h
//  LYUniversalProject
//
//  Created by 老岳 on 14-12-23.
//  Copyright (c) 2014年 老岳. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef  void(^FinishBlock)(NSInteger buttonIndex);

@interface UIAlertView (Common)

+ (void)alertWithMsg:(NSString *)msg
            btnTitle:(NSString *)btnTitle
               block:(FinishBlock)block;

+ (void)alertWithMsg:(NSString *)msg
            btnTitle:(NSString *)btnTitle
       otherBtnTitle:(NSString *)otherBtnTitle
               block:(FinishBlock)block;

+ (void)alertWithTitle:(NSString *)title
                   msg:(NSString *)msg
              btnTitle:(NSString *)btnTitle
         otherBtnTitle:(NSString *)otherBtnTitle
                 block:(FinishBlock)block;

@end

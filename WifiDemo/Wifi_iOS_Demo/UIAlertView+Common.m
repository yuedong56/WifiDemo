//
//  UIAlertView+Common.m
//  LYUniversalProject
//
//  Created by 老岳 on 14-12-23.
//  Copyright (c) 2014年 老岳. All rights reserved.
//

#import "UIAlertView+Common.h"
#import <objc/runtime.h>

@implementation UIAlertView (Common)

#pragma mark - Init Method
+ (void)alertWithMsg:(NSString *)msg
            btnTitle:(NSString *)btnTitle
               block:(FinishBlock)block
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:btnTitle, nil];
    [alertView showAlertWithBlock:block];
}

+ (void)alertWithMsg:(NSString *)msg
            btnTitle:(NSString *)btnTitle
       otherBtnTitle:(NSString *)otherBtnTitle
               block:(FinishBlock)block
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:btnTitle, otherBtnTitle, nil];
    [alertView showAlertWithBlock:block];
}

+ (void)alertWithTitle:(NSString *)title
                   msg:(NSString *)msg
              btnTitle:(NSString *)btnTitle
         otherBtnTitle:(NSString *)otherBtnTitle
                 block:(FinishBlock)block
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:btnTitle, otherBtnTitle, nil];
    [alertView showAlertWithBlock:block];
}

#pragma mark -
static char key;
- (void)showAlertWithBlock:(FinishBlock)block
{
    if (block) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        self.delegate = self;
    }
    [self show];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    FinishBlock block = objc_getAssociatedObject(self, &key);
    if (block) {
        block(buttonIndex);
    }
}

@end

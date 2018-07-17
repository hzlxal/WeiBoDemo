//
//  UITapGestureRecognizer+HXAdd.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "UITapGestureRecognizer+HXAdd.h"
#import <objc/runtime.h>

const void *kHXTAPTAG;

@implementation UITapGestureRecognizer (HXAdd)

- (NSNumber *)tag{
    return objc_getAssociatedObject(self, &kHXTAPTAG);
}

- (void)setTag:(NSNumber *)tag{
    objc_setAssociatedObject(self, &kHXTAPTAG, tag, OBJC_ASSOCIATION_ASSIGN);
}

@end

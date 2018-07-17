//
//  UILabel+HXAdd.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "UILabel+HXAdd.h"
#import "HXTextLayout.h"
#import <objc/runtime.h>

const void *kHXTextLayout;

@implementation UILabel (HXAdd)

- (void)setTextLayout:(HXTextLayout *)textLayout{
    self.font = textLayout.font;
    self.textColor = textLayout.color;
    self.frame = textLayout.frame;
    self.text = textLayout.text;
    objc_setAssociatedObject(self, &kHXTextLayout, textLayout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HXTextLayout *)textLayout{
    return objc_getAssociatedObject(self, &kHXTextLayout);
}

@end

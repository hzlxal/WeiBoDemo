//
//  HXLayout.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXTextLayout.h"

@implementation HXTextLayout

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color fontSize:(CGFloat)size text:(NSString *)text{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.color = color;
        self.font = [UIFont systemFontOfSize:size];
        self.text = text;
    }
    return self;
}

@end

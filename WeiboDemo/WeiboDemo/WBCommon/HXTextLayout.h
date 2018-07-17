//
//  HXLayout.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HXTextLayout : NSObject

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, copy) NSString *text;

- (instancetype)initWithFrame:(CGRect)frame color:(UIColor *)color fontSize:(CGFloat)size text:(NSString *)text;

@end

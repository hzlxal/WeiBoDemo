//
//  UIView+HXAdd.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HXAdd)

- (UIImage *)snapshotImage;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize  size;

@end

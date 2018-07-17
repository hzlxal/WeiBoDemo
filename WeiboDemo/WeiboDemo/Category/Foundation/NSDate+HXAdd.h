//
//  NSDate+HXAdd.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HXAdd)

/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear;
/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday;
/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday;

@end

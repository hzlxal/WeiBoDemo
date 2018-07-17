//
//  WBHomePageHelper.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>


// 和主页强相关的业务类
@interface WBHomePageHelper : NSObject

/**
 * 转换为微博日期的友好显示
 */
+ (NSString *)formatDateStringWithDateString:(NSString *)dateStr;


/**
 * 转换为来自xxx形式的显示
 */
+ (NSString *)formatSourceString:(NSString *)source;


/**
 * 将text中的全文或者话题提取出来
 */
//+ (NSAttributedString *)formatTextString:(NSString *)textStr;

/**
 * 缩短转发的字长
 */
+ (NSString *)shortedNumberDesc:(NSUInteger)number;


@end

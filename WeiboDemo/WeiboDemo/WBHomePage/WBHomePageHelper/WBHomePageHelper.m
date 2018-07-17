//
//  WBHomePageHelper.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBHomePageHelper.h"
#import "NSDate+HXAdd.h"

@implementation WBHomePageHelper

+ (NSString *)formatDateStringWithDateString:(NSString *)dateStr{
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
//    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    fmt.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    // 微博的创建日期
    NSDate *creatDate = [fmt dateFromString:dateStr];
    // 当前时间
    NSDate *now = [NSDate date];
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    //计算两个日期之间的差值
    NSDateComponents *component = [calender components:unit fromDate:creatDate toDate:now options:0];
    
    
    if ([creatDate isThisYear]) { // 今年
        if ([creatDate isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:creatDate];
        } else if ([creatDate isToday]) { // 今天
            if (component.hour >= 1) {
                return [NSString stringWithFormat:@"%ld小时前", (long)component.hour];
            } else if (component.minute >= 1) {
                return [NSString stringWithFormat:@"%ld分钟前", (long)component.minute];
            } else {
                return @"刚刚";
            }
        } else { // 今年的其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:creatDate];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:creatDate];
    }
}


+ (NSString *)formatSourceString:(NSString *)source
{
    NSRange range;
    range.location = [source rangeOfString:@">"].location + 1;
    range.length = (NSInteger)[source rangeOfString:@"</"].location - range.location;
    source = [NSString stringWithFormat:@"来自%@", [source substringWithRange:range]];
    return source;
}


+ (NSString *)shortedNumberDesc:(NSUInteger)number {
    // should be localized
    if (number <= 9999) return [NSString stringWithFormat:@"%d", (int)number];
    if (number <= 9999999) return [NSString stringWithFormat:@"%d万", (int)(number / 10000)];
    return [NSString stringWithFormat:@"%d千万", (int)(number / 10000000)];
}


@end

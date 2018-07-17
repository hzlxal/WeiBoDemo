//
//  WBAccountTool.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBAccountTool.h"

#define HXAccountPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"hxaccount.data"]

@implementation WBAccountTool

+ (void)saveAccount:(WBAccount *)account
{
    // 写到沙盒里
    [NSKeyedArchiver archiveRootObject:account toFile:HXAccountPath];
}


+ (WBAccount *)account
{
    // 加载模型
    WBAccount *account = [NSKeyedUnarchiver unarchiveObjectWithFile:HXAccountPath];
    
    // 过期的秒数
    long long expires_in = [account.expiresIn longLongValue];
    // 获得过期时间
    NSDate *expiresTime = [account.createdTime dateByAddingTimeInterval:expires_in];
    // 获得当前时间
    NSDate *now = [NSDate date];
    
    NSComparisonResult result = [expiresTime compare:now];
    if (result != NSOrderedDescending) {
        return nil;
    }
    
    return account;
}

@end

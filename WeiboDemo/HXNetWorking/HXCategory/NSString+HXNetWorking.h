//
//  NSString+HXNetWorking.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/27.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HXNetWorking)
/**
 拼接字符串

 @param host 主机域名
 @param path 文件路径
 @param apiVersion api版本号
 @return 拼接好的字符串
 */
+ (NSString *)hx_urlStringWithHost:(nonnull NSString *)host path:(nonnull NSString *)path apiVersion:(nonnull NSString *)apiVersion;

// 将传入数据按MD5编码
+ (NSString *)hx_md5WithData:(nonnull NSData *)inputData;

@end

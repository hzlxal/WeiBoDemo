//
//  HXURLRequestGenerator.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXURLRequestGenerator : NSObject
/**
 按照GET的方式生成NSURLRequest实例

 @param params 传入参数
 @param isUseJSON 是否使用JSON来序列化数据
 @param host 目的主机域名
 @param path 请求的文件路径
 @param apiVersion api版本号
 @return NSURLRequest实例
 */
+ (NSURLRequest *)generatorGETRequestWithParams:(NSDictionary *)params
                                        useJSON:(BOOL)isUseJSON
                                           host:(NSString *)host
                                           path:(NSString *)path
                                     apiVersion:(NSString *)apiVersion;
/**
 按照POST的方式生成NSURLRequest实例
 
 @param params 传入参数
 @param isUseJSON 是否使用JSON来序列化数据
 @param host 目的主机域名
 @param path 请求的文件路径
 @param apiVersion api版本号
 @return NSURLRequest实例
 */
+ (NSURLRequest *)generatorPOSTRequestWithParams:(NSDictionary *)params
                                         useJSON:(BOOL)isUseJSON
                                            host:(NSString *)host
                                            path:(NSString *)path
                                      apiVersion:(NSString *)apiVersion;

@end

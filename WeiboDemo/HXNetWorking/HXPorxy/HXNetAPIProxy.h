//
//  HXNetAPIProxy.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HXURLResponse, HXURLResponseError;

// 用于执行响应成功 or 失败时的回调
typedef void(^HXNetAPIProxySuccessBlock)(HXURLResponse *response);
typedef void(^HXNetAPIProxyFailBlock)(HXURLResponseError *error);

@interface HXNetAPIProxy : NSObject

// 单例方法
+ (instancetype)shareInstance;

// 测试网络可达性
- (BOOL)isReachable;



/**
 发起GET请求

 @param params 参数字典
 @param isUseJSON 是否使用JSON
 @param host 主机域名
 @param path 文件路径
 @param apiVersion api版本号
 @param successBlk 成功时的回调
 @param failBlk 失败时的回调
 @return requestID号
 */
- (NSUInteger)requestByGETWithParams:(NSDictionary *)params
                             useJSON:(BOOL)isUseJSON
                                host:(NSString *)host
                                path:(NSString *)path
                          apiVersion:(NSString *)apiVersion
                             success:(HXNetAPIProxySuccessBlock)successBlk
                                fail:(HXNetAPIProxyFailBlock)failBlk;



/**
 发起POST请求
 
 @param params 参数字典
 @param isUseJSON 是否使用JSON
 @param host 主机域名
 @param path 文件路径
 @param apiVersion api版本号
 @param successBlk 成功时的回调
 @param failBlk 失败时的回调
 @return requestID号
 */
- (NSUInteger)requestByPOSTWithParams:(NSDictionary *)params
                              useJSON:(BOOL)isUseJSON
                                 host:(NSString *)host
                                 path:(NSString *)path
                           apiVersion:(NSString *)apiVersion
                              success:(HXNetAPIProxySuccessBlock)successBlk
                                 fail:(HXNetAPIProxyFailBlock)failBlk;


// 按照requestID取消未发起请求
- (void)cancleRequestWithRequestID:(NSUInteger)requestID;
// 按照requestID的数组取消未发起请求
- (void)cancleRequestWithRequestIDArray:(NSArray *)array;





@end

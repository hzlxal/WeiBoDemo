//
//  HXURLRequestGenerator.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXURLRequestGenerator.h"
#import "NSString+HXNetWorking.h"
#import "NSURLRequest+HXNetWorking.h"
#import "HXNetWorkingLogger.h"
#import "HXNetWorkingConfiguration.h"
#import <AFNetworking.h>

@implementation HXURLRequestGenerator

#pragma mark - public method

+ (NSURLRequest *)generatorGETRequestWithParams:(NSDictionary *)params useJSON:(BOOL)isUseJSON host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion{
    
    return [self generatorRequestWithParams:params usJSON:isUseJSON host:host path:path apiVersion:apiVersion method:@"GET"];
}


+ (NSURLRequest *)generatorPOSTRequestWithParams:(NSDictionary *)params useJSON:(BOOL)isUseJSON host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion{
    
    return [self generatorRequestWithParams:params usJSON:isUseJSON host:host path:path apiVersion:apiVersion method:@"POST"];
}


#pragma mark - private method
// 生成请求
+ (NSURLRequest *)generatorRequestWithParams:(NSDictionary *)params usJSON:(BOOL)isUseJSON host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion method:(NSString *)method{
    
    
    if (![method isEqualToString:@"GET"] && ![method isEqualToString:@"POST"]) {
        [HXNetWorkingLogger logErrorInfo:[NSString stringWithFormat:@"[%@]:<%s>未知请求方法",NSStringFromClass([self class]),__func__]];
        return nil;
    }
    
    NSString *urlString = [NSString hx_urlStringWithHost:host path:path apiVersion:apiVersion];
    NSError *error = nil;
    
    AFHTTPRequestSerializer *serializer = isUseJSON ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
    serializer.timeoutInterval = kHXNetworkingTimeoutSeconds;
    
    NSMutableURLRequest *mutableRequest = [serializer requestWithMethod:method URLString:urlString parameters:params error:&error];
    mutableRequest.hx_requestParams = params;
    
    
    // DEBUG处理
    if (error) {
        [HXNetWorkingLogger logErrorInfo:[error localizedDescription]];
        return nil;
    }
    
    [HXNetWorkingLogger logDebugInfoWithRequest:[mutableRequest copy] path:path isJSON:isUseJSON params:params requestType:method];
    
    return mutableRequest;
}


@end

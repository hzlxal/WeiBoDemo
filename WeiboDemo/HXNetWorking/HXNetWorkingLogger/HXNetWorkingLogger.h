//
//  HXNetWorkingLogger.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
//
//#define NEED_DEBUG_LOGGER
//#define NEED_RESPONSE_LOGGER
#define NEED_INFO_LOGGER

@interface HXNetWorkingLogger : NSObject

+ (void)logDebugInfoWithRequest:(NSURLRequest *)request
                           path:(NSString *)path
                         isJSON:(BOOL)isJSON
                         params:(NSDictionary *)requestParams
                    requestType:(NSString *)type;

+ (void)logResponseInfoWithRequest:(NSURLRequest *)request
                              path:(NSString *)path
                            params:(NSDictionary *)requestParams
                          response:(NSString *)response;


+ (void)logInfo:(NSString *)message;
+ (void)logInfo:(NSString *)message label:(NSString *)label;
+ (void)logErrorInfo:(NSString *)errorMessage;

@end

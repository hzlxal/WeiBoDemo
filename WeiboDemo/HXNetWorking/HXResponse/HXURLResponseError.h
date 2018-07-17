//
//  HXURLResponseError.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXURLResponseError : NSError

// 请求号
@property (nonatomic, assign, readonly) NSUInteger requestID;
// 错误信息
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, copy) NSDictionary *response;

/**
 用于生成HXURLResponseError实例

 @param message 错误信息
 @param code 错误编码
 @param requestID 请求号
 @return HXURLResponseError实例
 */
+ (HXURLResponseError *)errorWithMessage:(NSString *)message
                                    code:(NSInteger)code
                               requestID:(NSUInteger)requestID;

@end

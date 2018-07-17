//
//  HXURLResponse.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

// 响应状态的枚举
typedef NS_ENUM(NSUInteger, HXResponseStatus) {
    HXResponseStatusSuccess,
    HXResponseStatusCancel,
    HXResponseStatusErrorTimeout,
    HXResponseStatusErrorUnknown
};


@interface HXURLResponse : NSObject

@property (nonatomic, assign) HXResponseStatus responseStatus;
// responseData编码后的字符串(UTF-8)
@property (nonatomic, copy, readonly) NSString *responseString;
// responseData转换为的json对象
@property (nonatomic, assign, readonly) NSUInteger requestID;
@property (nonatomic, copy, readonly) NSURLRequest *request;
@property (nonatomic, copy, readonly) NSURLResponse *response;
@property (nonatomic, copy, readonly) NSData *responseData;
// 是为缓存数据
@property (nonatomic, assign, readonly) BOOL isCache;
@property (nonatomic, copy) NSDictionary *requestParams;


/**
 用缓冲区中的数据初始化

 @param data 缓冲区的数据
 @return HXURLResponse实例
 */
- (instancetype)initWithData:(NSData *)data;


/**
 直接初始化

 @param responseStatus 响应状态
 @param responseString 响应的字符串
 @param request 请求
 @param response 响应
 @param responseData 响应数据
 @return HXURLResponse实例
 */
- (instancetype)initWithResponseStatus:(HXResponseStatus)responseStatus
                        responseString:(NSString *)responseString
                               request:(NSURLRequest *)request
                             requestID:(NSUInteger)requestID
                              response:(NSURLResponse *)response
                          responseData:(NSData *)responseData;

@end

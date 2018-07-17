//
//  HXBaseAPIManager.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXNetWorkingLogger.h"
#import "HXNetWorkingConfiguration.h"
@class HXBaseAPIManager, HXURLResponseError, HXURLResponse;

// 请求类型的枚举
typedef NS_ENUM(NSInteger, HXRequestType){
    HXRequestTypeGET,
    HXRequestTypePOST
};

// 对响应的状态做更细致的划分
typedef NS_ENUM(NSInteger, HXAPIManagerResponseStatus){
    HXAPIManagerResponseStatusDefault = -1,             //没有产生过API请求，默认状态。
    HXAPIManagerResponseStatusTimeout = 101,            //请求超时
    HXAPIManagerResponseStatusNoNetwork = 102,          //网络不通
    HXAPIManagerResponseStatusSuccess = 200,            //API请求成功且返回数据正确
    HXAPIManagerResponseStatusParsingError = 201,       //API请求成功但返回数据不正确
    HXAPIManagerResponseStatusTokenExpired = 300,       //token过期
    HXAPIManagerResponseStatusNeedLogin = 301,          //认证信息无效
    HXAPIManagerResponseStatusRequestError = 400,       //请求出错，参数或方法错误
    HXAPIManagerResponseStatusTypeServerCrash = 500,    //服务器出错
    HXAPIManagerResponseStatusTypeServerMessage = 600,  //服务器自定义消息
};

// 调用成功后可以通过这个key从params取出requestID
extern NSString *const kHXBaseAPIManagerRequestID;


// 用于构造请求的数据源协议，子类必须遵循此协议
@protocol HXAPIManager <NSObject>
@required
- (nonnull NSString *)path;
- (nonnull NSString *)apiVersion;

@optional
- (HXRequestType)requestType;
- (BOOL)isResponseJSONable;
- (BOOL)isRequestUsingJSON;
- (BOOL)shouldCache;
- (NSUInteger)cacheExpirationTime; /*返回0则为永不超时*/
@end

@protocol HXAPIManagerDataSource <NSObject>
@required
- (nonnull NSDictionary *)paramsForAPIManager:(HXBaseAPIManager *)manager;
@end

// 请求后的回调
@protocol HXAPIManagerDelegate <NSObject>
@required
- (void)apiManagerLoadDataSuccess:(HXBaseAPIManager *)manager;
- (void)apiManager:(HXBaseAPIManager *)apiManager loadDataFail:(HXURLResponseError *)error;

@optional
- (void)apiManagerLoadDataDidCancle:(HXBaseAPIManager *)manager;
@end


// 将数据格式化为特定形式
@protocol HXAPIManagerDataReformer <NSObject>
@required
- (id)apiManager:(HXBaseAPIManager *)manager reformData:(NSDictionary *)dataDic;
@end


// 拦截器方法
@protocol HXAPIManagerInterceptorDelegate <NSObject>
@optional
- (BOOL)apiManager:(HXBaseAPIManager *)manager beforePerformSuccessWithResponse:(HXURLResponse *)response;
- (void)apiManager:(HXBaseAPIManager *)manager afterPerformSuccessWithResponse:(HXURLResponse *)response;

- (BOOL)apiManager:(HXBaseAPIManager *)manager beforePerformFailWithResponseError:(HXURLResponseError *)error;
- (void)apiManager:(HXBaseAPIManager *)manager afterPerformFailWithResponseError:(HXURLResponseError *)error;

- (void)afterPerformCancel:(HXBaseAPIManager *)manager;


- (BOOL)apiManager:(HXBaseAPIManager *)manager shouldInitiateRequestWithParams:(NSDictionary *)params;
- (void)apiManager:(HXBaseAPIManager *)manager afterInitiateRequestWithParams:(NSDictionary *)params;
@end


@interface HXBaseAPIManager : NSObject

// 显示是否处于请求状态，用于配合决定撤销or等待策略
@property (nonatomic, assign, readonly) BOOL isLoading;
// 用于控制依赖的信号量（这里为互斥量）
@property (nonatomic, readonly) dispatch_semaphore_t continueMutex;
@property (nonatomic, weak) id<HXAPIManagerDelegate> delegate;
@property (nonatomic, weak) id<HXAPIManagerDataSource> dataSource;
@property (nonatomic, weak) id<HXAPIManagerInterceptorDelegate> interceptorDelegate;


/*提供给外部使用的api*/
- (void)addDependency:(HXBaseAPIManager *)apiManager;
- (void)removeDependency:(HXBaseAPIManager *)apiManager;

// 若要发起请求则调用这个方法
- (NSUInteger)loadData;
- (NSUInteger)loadDataWithoutCache;

- (void)cancleRequestWithRequestID:(NSUInteger)requestID;
- (void)cancleAllRequests;

// 若数据可JSON解析，此方法会返回原始的JSON序列，否则返回原始的请求数据
- (id)fetchData;
- (id)fetchDataWithModel:(id)model;
- (id)fetchDataWithReform:(id<HXAPIManagerDataReformer>) reformer;


/**
 用于向请求中新添参数，由子类继承实现
 不需要调用[super reformParams:]

 @param params 现有的参数的字典
 @return 新参数的字典
 */
- (NSDictionary *)reformParams:(NSDictionary *)params;


/*用于给子类重写*/
- (nonnull NSString *)host; // 默认若实现了wholeUrlForAPIManager:方法则为返回的完整url否则为kServerURL
- (HXRequestType)requestType; // 默认为HXRequestTypeGET
- (NSTimeInterval)cacheExpirationTime; // 默认为kHXCacheExpirationTimeDefault

- (BOOL)isReachable; // 默认为HXNetAPIProxy的isReachable实现
- (BOOL)shouldCache; // 默认为YES
- (BOOL)isResponseJSONable; // 默认为YES
- (BOOL)isRequestUsingJSON; // 默认为YES


/*内部继承使用的拦截器方法*/
- (BOOL)beforePerformSuccessWithResponse:(HXURLResponse *)response;
- (void)afterPerformSuccessWithResponse:(HXURLResponse *)response;

- (BOOL)beforePerformFailWithResponseError:(HXURLResponseError *)error;
- (void)afterPerformFailWithResponseError:(HXURLResponseError *)error;

- (void)afterPerformCancel;

- (BOOL)shouldInitiateRequestWithParams:(NSDictionary *)params;
- (void)afterInitiateRequestWithParams:(NSDictionary *)params;

// 判断响应数据的正确性，由子类实现
- (BOOL)isResponseDataCorrect:(HXURLResponse *)response;

@end


//
//  HXBaseAPIManager.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXBaseAPIManager.h"
#import "HXNetAPIProxy.h"
#import "HXCacheAPIProxy.h"
#import "HXURLResponse.h"
#import "HXURLResponseError.h"
#import <YYModel.h>
#import <pthread.h>

#define HXURLResponseErrorWithMsg(Msg)  [HXURLResponseError errorWithMessage:Msg code:status requestID:requestID];

#define HXRequest(REQUEST_METHOD, REQUEST_ID)                                                  \
{\
__weak typeof(self) weakSelf = self;\
REQUEST_ID = [[HXNetAPIProxy shareInstance] requestBy##REQUEST_METHOD##WithParams:apiParams useJSON:self.isRequestUsingJSON host:self.host path:self.child.path apiVersion:self.child.apiVersion success:^(HXURLResponse *response) {\
__strong typeof(weakSelf) strongSelf = weakSelf;\
[strongSelf dataDidLoadWithResponse:response];\
} fail:^(HXURLResponseError *error) {\
__strong typeof(weakSelf) strongSelf = weakSelf;\
[strongSelf dataLoadFail:error];\
}];\
self.requestIDMap[@(REQUEST_ID)]= @(REQUEST_ID);\
}\


NSString *const kHXBaseAPIManagerRequestID = @"hx.kHXBaseAPIManagerRequestID";

static void thread_safe_execute(dispatch_block_t block){
    static pthread_mutex_t lock;
    pthread_mutex_lock(&lock);
    block();
    pthread_mutex_unlock(&lock);
}

@interface HXBaseAPIManager()

@property (nonatomic, assign) BOOL isforceUpdate;
@property (nonatomic, assign, readwrite) BOOL isLoading;

@property (nonatomic, readwrite) dispatch_semaphore_t continueMutex;

@property (nonatomic, strong) id rawData;

// 用于配合计算超时时间
@property (nonatomic, assign) NSTimeInterval createTime;

// 用于添加依赖的集合
@property (nonatomic, strong) NSMutableSet *dependecySet;

// 由于内部的requestID与外部的requestID不同，这里保存了他们的对应关系
@property (nonatomic, strong) NSMutableDictionary *requestIDMap;

// 通过这个属性来从父类调用子类继承的方法
@property (nonatomic, weak) HXBaseAPIManager<HXAPIManager> *child;

@end

@implementation HXBaseAPIManager

#pragma mark - life cycle
- (instancetype)init{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(HXAPIManager)]) {
            self.child = (id<HXAPIManager>)self;
            self.continueMutex = dispatch_semaphore_create(0);
            self.isforceUpdate = NO;
        }else{
            NSException *exception = [NSException exceptionWithName:@"HXBaseAPIManager init failed" reason:@"Subclass of HXBaseAPIManager should implement <HXPageAPIManager>" userInfo:nil];
            @throw exception;
        }
        
    }
    return self;
}

#pragma mark - call api
// 添加依赖
- (void)addDependency:(HXBaseAPIManager *)apiManager{
    if (!apiManager) {
        return;
    }
    thread_safe_execute(^{
        // 强引用apiManager，使被依赖的apiManager会在所有依赖它的其他apiManager释放后才释放
        [self.dependecySet addObject:apiManager];
    });
}

// 删除依赖
- (void)removeDependency:(HXBaseAPIManager *)apiManager{
    if (!apiManager) {
        return;
    }
    thread_safe_execute(^{
        [self.dependecySet removeObject:apiManager];
    });
}


- (NSUInteger)loadData{
    
    static NSInteger requestIndex = 0;
    
    __block NSInteger openRequestID;
    thread_safe_execute(^{
        requestIndex++;
        openRequestID = requestIndex;
    });
    
    // 添加的依赖请求全部完成后才开始请求数据
    [self waitForDependency:^{
        NSDictionary *params = [self.dataSource paramsForAPIManager:self];
        NSInteger requestID = [self loadDataWithParams:params];
        self.requestIDMap[@(openRequestID)] = @(requestID);
    }];
    
    return openRequestID;
}


- (NSUInteger)loadDataWithoutCache{
    self.isforceUpdate = YES;
    return [self loadData];
}


- (void)cancleAllRequests{
    [[HXNetAPIProxy shareInstance] cancleRequestWithRequestIDArray:self.requestIDMap.allValues];
}


- (void)cancleRequestWithRequestID:(NSUInteger)requestID{
    NSNumber *realRequestID = self.requestIDMap[@(requestID)];
    [self.requestIDMap removeObjectForKey:@(requestID)];
    [[HXNetAPIProxy shareInstance] cancleRequestWithRequestID:[realRequestID unsignedIntegerValue]];
}


- (id)fetchData{
    return [self fetchDataWithReform:nil];
}

- (id)fetchDataWithModel:(Class)clazz{
    return [clazz yy_modelWithJSON:[self fetchData]];
}

- (id)fetchDataWithReform:(id<HXAPIManagerDataReformer>)reformer{
    
    if ([reformer respondsToSelector:@selector(apiManager:reformData:)]) {
        return [reformer apiManager:self reformData:self.rawData];
    }else{
        return [self.rawData mutableCopy];
    }
}

#pragma mark - private method
- (NSUInteger)loadDataWithParams:(NSDictionary *)params{
    NSUInteger requestID = 0;
    NSDictionary *apiParams = [self reformParams:params];
    if ([self shouldInitiateRequestWithParams:params]) {
        
        if (!self.isforceUpdate && [self shouldCache] && [self tryloadCacheWithParams:params]){
            return 0;
        }
        
        if ([[HXNetAPIProxy shareInstance] isReachable]) {
            self.isLoading = YES;
            switch (self.child.requestType) {
                case HXRequestTypeGET:
                    HXRequest(GET, requestID);
                    break;
                    
                case HXRequestTypePOST:
                    HXRequest(POST, requestID);
                    break;
                default:
                    break;
            }
        }
    
        NSMutableDictionary *params = [apiParams mutableCopy];
        params[kHXBaseAPIManagerRequestID] = @(requestID);
        [self afterInitiateRequestWithParams:params];
        return requestID;
    }else{
        [self dataLoadFail:
         [HXBaseAPIManager errorWithRequestId:requestID
                                       status:HXAPIManagerResponseStatusNoNetwork]];
        return requestID;
    }
    
    return requestID;
}

// 查询缓存中的数据
- (BOOL)tryloadCacheWithParams:(NSDictionary *)params{
    NSData *cacheData = [[HXCacheAPIProxy shareInstance] cacheForParams:params host:self.host path:self.child.path apiVersion:self.child.apiVersion];
    if (!cacheData) {
        return NO;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        HXURLResponse *response = [[HXURLResponse alloc] initWithData:cacheData];
        [self dataDidLoadWithResponse:response];
        [HXNetWorkingLogger logInfo:@"从Cache中加载数据成功"];
    });
    
    return YES;
}


#pragma mark - response handler method
- (void)dataDidLoadWithResponse:(HXURLResponse *)response{
    self.isLoading = NO;
    [self.requestIDMap removeObjectForKey:@(response.requestID)];
    
    // 对数据进行序列化
    if ([self isResponseJSONable]) {
        NSError *error = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:response.responseData options:NSJSONReadingMutableLeaves error:&error];
        if (error) {
            HXURLResponseError *hxError = [HXBaseAPIManager errorWithRequestId:response.requestID status:HXAPIManagerResponseStatusParsingError];
            hxError.response = jsonDic;
            [HXNetWorkingLogger logErrorInfo:hxError.message];
            [self dataLoadFail:hxError];
            return;
        }
        self.rawData = jsonDic;
    
    }else{
        self.rawData = [response.responseData copy];
    }
    
    
    // 对数据的合法性进行检查
    if ([self isResponseDataCorrect:response]) {
        
        if ([self beforePerformSuccessWithResponse:response]) {
            [HXNetWorkingLogger logInfo:@"数据加载完毕" label:@"load success"];
            [self.delegate apiManagerLoadDataSuccess:self];
        }
        
        if ([self shouldCache] && !response.isCache) {
            [[HXCacheAPIProxy shareInstance] setCacheWithData:response.responseData params:response.requestParams host:self.host path:self.child.path apiVersion:self.child.apiVersion cacheExpirationTime:self.child.cacheExpirationTime];
        }
       
        // 释放互斥锁（即给依赖此apiManager的对象发出完成信号)
        dispatch_semaphore_signal(self.continueMutex);
        
        [self afterPerformSuccessWithResponse:response];
    }else{
        [self dataLoadFail:[HXBaseAPIManager errorWithRequestId:response.requestID status:HXAPIManagerResponseStatusParsingError]];
    }
    
    self.isforceUpdate = NO;
}


- (void)dataLoadFail:(HXURLResponseError *)error{
    // 将requestId更改为对外的requestId
    __block NSUInteger openRequestID = 0;
    [self.requestIDMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj unsignedShortValue] == error.requestID) {
            openRequestID = [key unsignedIntegerValue];
        }
    }];
    
    error = [HXURLResponseError errorWithMessage:error.message code:error.code requestID:openRequestID];
    
    if(error.code == HXResponseStatusCancel) {
        // 处理请求被取消
        if([self.delegate respondsToSelector:@selector(apiManagerLoadDataDidCancle:)]) {
            [self.delegate apiManagerLoadDataDidCancle:self];
        }
        [self afterPerformCancel];
        return;
    }
    
    
    if ([self beforePerformFailWithResponseError:error]) {
        [self.requestIDMap removeObjectForKey:@(error.requestID)];
        if ([self.delegate respondsToSelector:@selector(apiManager:loadDataFail:)]) {
            [self.delegate apiManager:self loadDataFail:error];
        }
        [self afterPerformFailWithResponseError:error];
    }
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

#pragma mark - private method
- (void)waitForDependency:(dispatch_block_t)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (HXBaseAPIManager *manager in self.dependecySet) {
            // 如果监听到请求完成（即拿到了互斥锁）就立即释放互斥锁，保证接下来的请求能够正常进行
            dispatch_semaphore_wait(manager.continueMutex, DISPATCH_TIME_FOREVER);
            [HXNetWorkingLogger logInfo:@"down"];
            dispatch_semaphore_signal(manager.continueMutex);
        }
    });
    if (block) {
        block();
    }
}


+ (HXURLResponseError *)errorWithRequestId:(NSUInteger)requestID
                                 status:(HXAPIManagerResponseStatus)status {
    return [self errorWithRequestId:requestID status:status extra:nil];
}


+ (HXURLResponseError *)errorWithRequestId:(NSUInteger)requestID
                                 status:(HXAPIManagerResponseStatus)status
                                  extra:(NSString *)message {
    switch (status) {
        case HXAPIManagerResponseStatusParsingError:
            return HXURLResponseErrorWithMsg(@"数据解析错误");
        case HXAPIManagerResponseStatusTimeout:
            return HXURLResponseErrorWithMsg(@"请求超时");
        case HXAPIManagerResponseStatusNoNetwork:
            return HXURLResponseErrorWithMsg(@"当前网络已断开");
        case HXAPIManagerResponseStatusTokenExpired:
            return HXURLResponseErrorWithMsg(@"token已过期");
        case HXAPIManagerResponseStatusNeedLogin:
            return HXURLResponseErrorWithMsg(@"请登录");
        case HXAPIManagerResponseStatusRequestError:
            return HXURLResponseErrorWithMsg(@"参数错误");
        case HXAPIManagerResponseStatusTypeServerCrash:
            return HXURLResponseErrorWithMsg(@"服务器出错");
        case HXAPIManagerResponseStatusTypeServerMessage:
            return HXURLResponseErrorWithMsg(message?:@"未知信息");
        default:
            return HXURLResponseErrorWithMsg(@"未知错误");
    }
}


#pragma mark - need overrid method
- (NSString *)host{
    return kServerURL;
}

- (HXRequestType)requestType{
    return HXRequestTypeGET;
}

- (BOOL)isRequestUsingJSON{
    return YES;
}

- (BOOL)isResponseJSONable{
    return YES;
}

- (BOOL)shouldCache{
    return YES;
}

- (NSTimeInterval)cacheExpirationTime{
    return kHXCacheExpirationTimeDefault;
}

- (BOOL)isReachable{
    return [[HXNetAPIProxy shareInstance] isReachable];
}

- (BOOL)isResponseDataCorrect:(HXURLResponse *)response{
    return YES;
}


#pragma mark - Interceptor method
- (BOOL)beforePerformSuccessWithResponse:(HXURLResponse *)response{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:beforePerformSuccessWithResponse:)]) {
        return [self.interceptorDelegate apiManager:self beforePerformSuccessWithResponse:response];
    }
    return YES;
}

- (void)afterPerformSuccessWithResponse:(HXURLResponse *)response{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:afterPerformSuccessWithResponse:)]) {
        [self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponseError:(HXURLResponseError *)error{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:beforePerformFailWithResponseError:)]) {
        return [self beforePerformFailWithResponseError:error];
    }
    return YES;
}


- (void)afterPerformFailWithResponseError:(HXURLResponseError *)error{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:afterPerformFailWithResponseError:)]) {
        [self.interceptorDelegate apiManager:self afterPerformFailWithResponseError:error];
    }
}

- (void)afterPerformCancel{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManagerLoadDataDidCancle:)]) {
        [self.interceptorDelegate afterPerformCancel:self];
    }
}

- (BOOL)shouldInitiateRequestWithParams:(NSDictionary *)params{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:shouldInitiateRequestWithParams:)]) {
        return [self.interceptorDelegate apiManager:self shouldInitiateRequestWithParams:params];
    }
    return YES;
}

- (void)afterInitiateRequestWithParams:(NSDictionary *)params{
    if ([self.interceptorDelegate respondsToSelector:@selector(apiManager:afterInitiateRequestWithParams:)]) {
        [self.interceptorDelegate apiManager:self afterInitiateRequestWithParams:params];
    }
}


#pragma mark - getter && setter
- (NSMutableSet *)dependecySet{
    if (!_dependecySet) {
        _dependecySet = [[NSMutableSet alloc] init];
    }
    return _dependecySet;
}

- (NSMutableDictionary *)requestIDMap{
    if (!_requestIDMap) {
        _requestIDMap = [[NSMutableDictionary alloc] init];
    }
    return _requestIDMap;
}

- (BOOL)isLoading{
    if (self.requestIDMap.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

@end

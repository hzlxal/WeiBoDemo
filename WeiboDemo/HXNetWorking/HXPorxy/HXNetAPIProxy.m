
//
//  HXNetAPIProxy.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXNetAPIProxy.h"
#import "HXNetWorkingLogger.h"
#import "HXURLRequestGenerator.h"
#import "HXURLResponse.h"
#import "HXURLResponseError.h"
#import "NSURLRequest+HXNetWorking.h"
#import <AFNetworking.h>

@interface HXNetAPIProxy()<NSCopying, NSMutableCopying>

// requestID - dataTask的映射表
@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordeRequestID;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation HXNetAPIProxy

#pragma mark - public method

- (NSUInteger)requestByGETWithParams:(NSDictionary *)params useJSON:(BOOL)isUseJSON host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion success:(HXNetAPIProxySuccessBlock)successBlk fail:(HXNetAPIProxyFailBlock)failBlk{
    
    NSURLRequest *request = [HXURLRequestGenerator generatorGETRequestWithParams:params useJSON:isUseJSON host:host path:path apiVersion:apiVersion];

    return [self request:request success:successBlk fail:failBlk];
}


- (NSUInteger)requestByPOSTWithParams:(NSDictionary *)params useJSON:(BOOL)isUseJSON host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion success:(HXNetAPIProxySuccessBlock)successBlk fail:(HXNetAPIProxyFailBlock)failBlk{
    
    NSURLRequest *request = [HXURLRequestGenerator generatorPOSTRequestWithParams:params useJSON:isUseJSON host:host path:path apiVersion:apiVersion];
    
    return [self request:request success:successBlk fail:failBlk];
}


- (void)cancleRequestWithRequestID:(NSUInteger)requestID{
    if (!requestID) {
        return;
    }
    NSURLSessionDataTask *dataTask = self.dispatchTable[@(requestID)];
    [dataTask cancel];
    [self.dispatchTable removeObjectForKey:@(requestID)];
}


- (void)cancleRequestWithRequestIDArray:(NSArray *)array{
    for (NSNumber *requestID in array) {
        [self cancleRequestWithRequestID:requestID.unsignedIntegerValue];
    }
}


- (BOOL)isReachable{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        return YES;
    }
    return [[AFNetworkReachabilityManager sharedManager] isReachable];
}


#pragma mark - private method

// 可以在这个方法里替换AFNetWorking
- (NSUInteger)request:(NSURLRequest *)request success:(HXNetAPIProxySuccessBlock)successBlk fail:(HXNetAPIProxyFailBlock)failBlk{
    
    __block NSURLSessionDataTask *dataTask = nil;
    NSLog(@"%@",request.hx_requestParams);
    dataTask = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        NSUInteger requestID = [dataTask taskIdentifier];
        [self.dispatchTable removeObjectForKey:@(requestID)];
        
        if (error) {
            [self handlerFailRequesWithError:error failBlock:failBlk requestID:requestID];
        }else{
            [self handlerSuccessRequestWithResponseData:responseObject request:request requestID:requestID response:response successBlock:successBlk];
        }
        
    }];
    
    NSUInteger requestID = [dataTask taskIdentifier];
    self.dispatchTable[@(requestID)] = dataTask;
    [dataTask resume];
    
    return requestID;
}


// 请求失败时的处理
- (void)handlerFailRequesWithError:(NSError *)error failBlock:(HXNetAPIProxyFailBlock)failBlk requestID:(NSUInteger)requestID{
    [HXNetWorkingLogger logErrorInfo:[error localizedDescription]];
    
    NSString *errorMessage = [[NSString alloc] init];
    HXResponseStatus statue;
    
    if (error.code == NSURLErrorCancelled) {
        errorMessage = @"请求取消";
        statue = HXResponseStatusCancel;
    }else if (error.code == NSURLErrorTimedOut){
        errorMessage = @"请求超时";
        statue = HXResponseStatusErrorTimeout;
    }else{
        errorMessage = @"未知错误";
        statue = HXResponseStatusErrorUnknown;
    }
    
    if (failBlk) {
        failBlk([HXURLResponseError errorWithMessage:errorMessage code:statue requestID:requestID]);;
    }
}


// 请求成功时的处理
- (void)handlerSuccessRequestWithResponseData:(NSData *)responseData request:(NSURLRequest *)request requestID:(NSUInteger)requestID response:(NSURLResponse *)response successBlock:(HXNetAPIProxySuccessBlock)successBlk{
    
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    [HXNetWorkingLogger logResponseInfoWithRequest:request path:request.URL.absoluteString params:request.hx_requestParams response:responseString];
    
    HXURLResponse *hxresponse = [[HXURLResponse alloc] initWithResponseStatus:HXResponseStatusSuccess responseString:responseString request:request requestID:requestID response:response responseData:responseData];
    
    if (successBlk) {
        successBlk(hxresponse);
    }
}


#pragma mark - singal patterns method

static HXNetAPIProxy *_instance = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HXNetAPIProxy alloc] init];
    });
    
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return _instance;
}

- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return  _instance;
}

#pragma mark - getter && setter

- (NSMutableDictionary *)dispatchTable{
    if (!_dispatchTable) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}


- (AFHTTPSessionManager *)sessionManager{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionManager;
}


@end

//
//  HXCacheAPIProxy.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/27.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXCacheAPIProxy.h"
#import "HXNetWorkingLogger.h"
#import "NSString+HXNetWorking.h"
#import "HXCache.h"

// 通过key从缓存的数据字典中取出相应的value
static NSString *const kHXNetWorkingCacheKeyCacheData = @"hx.kHXNetWorkingCacheKeyCacheData";
static NSString *const kHXNetWorkingCacheKeyCacheTime = @"hx.kHXNetWorkingCacheKeyCacheTime";
static NSString *const kHXNetWorkingCacheKeyCacheExpirationTime = @"hx.kHXNetWorkingCacheKeyCacheExpirationTime";


static NSString *const kHXNetWorkingCache = @"kHXNetWorkingCahce";

@interface HXCacheAPIProxy()<NSCopying, NSMutableCopying>
@property (nonatomic, strong) HXCache *cache;
@end

@implementation HXCacheAPIProxy
#pragma mark - public method

- (void)setCacheWithData:(NSData *)data params:(NSDictionary *)params host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion cacheExpirationTime:(NSTimeInterval)expirationTime{
    NSString *keyString = [self getCacheKeyStringWitParams:params host:host path:path apiVersion:apiVersion];
    [self setCacheWithData:data forKey:keyString cacheExpirationTime:expirationTime];
}


- (NSData *)cacheForParams:(NSDictionary *)params host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion{
    NSString *keyString = [self getCacheKeyStringWitParams:params host:host path:path apiVersion:apiVersion];
    
    return [self cacheForKey:keyString];
}


#pragma mark - private method

- (void)setCacheWithData:(NSData *)data forKey:(NSString *)key cacheExpirationTime:(NSTimeInterval)expirationTime{
    if (!data) {
        [HXNetWorkingLogger logErrorInfo:[NSString stringWithFormat:@"[%@]:<%s>:data is nil",NSStringFromClass([self class]), __func__]];
    }
    
    NSDictionary *cacheDic = @{kHXNetWorkingCacheKeyCacheData : data,
                               kHXNetWorkingCacheKeyCacheTime : @([NSDate timeIntervalSinceReferenceDate]),
                     kHXNetWorkingCacheKeyCacheExpirationTime : @(expirationTime)
                           };
    [self.cache setObject:cacheDic forKey:key];
    [HXNetWorkingLogger logInfo:[NSString stringWithFormat:@"写入缓存成功 key为:%@",key]];
}


- (NSData *)cacheForKey:(NSString *)key{
    NSDictionary *cacheDic = (NSDictionary *)[self.cache objectForKey:key];
    
    NSData *cacheData = cacheDic[kHXNetWorkingCacheKeyCacheData];
    NSTimeInterval cacheTimeIterval = [cacheDic[kHXNetWorkingCacheKeyCacheTime] doubleValue];
    NSTimeInterval cacheExpirationTime = [cacheDic[kHXNetWorkingCacheKeyCacheExpirationTime] doubleValue];
    
    NSTimeInterval nowTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    // 超时处理
    if (cacheData && (nowTimeInterval - cacheTimeIterval > cacheExpirationTime)) {
        [HXNetWorkingLogger logInfo:@"Cache过期" label:@"Cache"];
        [self.cache removeObjectForKey:key];
        return nil;
    }
    
    return cacheData;
}


- (NSString *)getCacheKeyStringWitParams:(NSDictionary *)params host:(NSString *)host path:(NSString *)path apiVersion:(NSString *)apiVersion{
   
    NSString *urlString = [NSString hx_urlStringWithHost:host path:path apiVersion:apiVersion];
    NSString *keyString = nil;
    
    if (params.allKeys.count!=0) {
        NSData *jsonSerializerData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
         keyString = [urlString stringByAppendingString:[NSString hx_md5WithData:jsonSerializerData]];
    }else{
        keyString = urlString;
    }
    
    
    return keyString;
}


#pragma mark - singal patterns method

static HXCacheAPIProxy *_instance = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HXCacheAPIProxy alloc] init];
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

- (HXCache *)cache{
    if (!_cache) {
        _cache = [[HXCache alloc] initWithName:kHXNetWorkingCache];
    }
    return _cache;
}
@end

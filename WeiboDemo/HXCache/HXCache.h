//
//  HXCache.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HXDiskCache.h"

@interface HXCache : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, strong, readonly) NSCache *memoryCache;

@property (nonatomic, strong, readonly) HXDiskCache *diskCache;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithName:(NSString *)name;

- (instancetype)initWithPath:(NSString *)path;

+ (nullable instancetype)cacheWithName:(NSString *)name;

+ (instancetype)cacheWithPath:(NSString *)path;

- (BOOL)containsObjectForKey:(NSString *)key;

- (nullable id<NSCoding>)objectForKey:(NSString *)key;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObjects;
@end

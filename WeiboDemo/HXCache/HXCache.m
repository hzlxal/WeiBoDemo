//
//  HXCache.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXCache.h"

@interface HXCache()

@property (nonatomic, copy, readwrite) NSString *name;

@property (nonatomic, strong, readwrite) NSCache *memoryCache;

@property (nonatomic, strong, readwrite) HXDiskCache *diskCache;

@end

@implementation HXCache

#pragma mark - life cycle
- (instancetype)initWithName:(NSString *)name {
    if (name.length == 0){
        return nil;
    }
    NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *path = [cacheFolder stringByAppendingPathComponent:name];
    
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path {
    if (path.length == 0){
        return nil;
    }
    HXDiskCache *diskCache = [[HXDiskCache alloc] initWithPath:path];
    if (!diskCache){
        return nil;
    }
    NSString *name = [path lastPathComponent];
    NSCache *memoryCache = [[NSCache alloc] init];
    memoryCache.name = name;
    
    self = [super init];
    if (self) {
        self.name = name;
        self.diskCache = diskCache;
        self.memoryCache = memoryCache;
    }
    return self;
}

+ (instancetype)cacheWithName:(NSString *)name{
    return [[self alloc] initWithName:name];
}

+ (instancetype)cacheWithPath:(NSString *)path{
    return [[self alloc] initWithPath:path];
}

- (BOOL)containsObjectForKey:(NSString *)key {
    return [self.memoryCache objectForKey:key] ? [self.diskCache containsObjectForKey:key] : NO;
}

- (id<NSCoding>)objectForKey:(NSString *)key {
    id<NSCoding> object = [self.memoryCache objectForKey:key];
    if (!object) {
        object = [self.diskCache objectForKey:key];
        if (object) {
            [self.memoryCache setObject:object forKey:key];
        }
    }
    return object;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [self.memoryCache setObject:object forKey:key];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.diskCache setObject:object forKey:key];
    });
}

- (void)removeObjectForKey:(NSString *)key {
    [self.memoryCache removeObjectForKey:key];
    [self.diskCache removeObjectForKey:key];
}

- (void)removeAllObjects {
    [self.memoryCache removeAllObjects];
    [self.diskCache removeAllObjects];
}

@end

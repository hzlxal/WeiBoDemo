//
//  HXDiskCache.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXDiskCache : NSObject

@property (nonatomic, copy) NSString *name; // cache名称
@property (nonatomic, copy, readonly) NSString *path; // cache的路径
@property (nonatomic, assign) NSUInteger countLimit; // cache所存储的文件个数限制
@property (nonatomic, assign) NSUInteger costLimit; // cache所能容量的最大数据量
@property (nonatomic, assign) NSUInteger freeDiskSpaceLimit; // 文件空余容量限制
@property (nonatomic, assign) NSTimeInterval ageLimit; // 超时时间
@property (nonatomic, assign) NSTimeInterval autoTrimInterval; // 检查时间

/*供未遵循<NSCoding>的对象*/
@property (nullable, copy) NSData *(^customArchiveBlock)(id object);
@property (nullable, copy) id (^customUnarchiveBlock)(NSData *data);


- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (nullable instancetype)initWithPath:(NSString *)path;

- (BOOL)containsObjectForKey:(NSString *)key;

- (nullable id<NSCoding>)objectForKey:(NSString *)key;

- (void)setObject:(nullable id<NSCoding>)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)removeAllObjects;

- (NSInteger)totalCount;

- (NSInteger)totalCost;

- (void)trimToCount:(NSUInteger)count;

- (void)trimToCost:(NSUInteger)cost;

- (void)trimToAge:(NSTimeInterval)age;

+ (nullable NSData *)getExtendedDataFromObject:(id)object;

+ (void)setExtendedData:(nullable NSData *)extendedData toObject:(id)object;
@end

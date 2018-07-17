//
//  HXDiskStorge.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

// 一次存入db条目的model
@interface HXDiskStorgeItem : NSObject

@property (nonatomic, copy) NSString *key; // 用于从db中查找数据
@property (nonatomic, copy) NSData *value; // 存储在db中的数据
@property (nonatomic, assign) NSInteger size; // 数据大小
@property (nonatomic, assign) NSInteger modifyTime; // 数据的修改时间
@property (nonatomic, assign) NSInteger accessTime;
@property (nonatomic, copy) NSData *extendData; // 需要存入的附加数据

@end

@interface HXDiskStorge : NSObject

@property (nonatomic, copy, readonly) NSString *dbPath; // db的存储路径
@property (nonatomic, assign, readonly) NSInteger itemSize; // db的现有数据大小
@property (nonatomic, assign, readonly) NSInteger itemCount; // db的现有条目数

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)new UNAVAILABLE_ATTRIBUTE;

/* 初始化方法 */
- (instancetype)initWithPath:(NSString *)path;

/* 存储相关方法 */
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value;

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value extendedData:(nullable NSData *)extendedData;

/* 删除相关方法 */
- (BOOL)removeItemForKey:(NSString *)key;

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys;

- (BOOL)removeItemsToFitSize:(int)maxSize;

- (BOOL)removeItemsToFitCount:(int)maxCount;

- (BOOL)removeItemThanTimeInterval:(int)timeInterval;

- (BOOL)removeItemThanSize:(int)maxSize;

- (BOOL)removeAllItems;

/* 查询相关方法 */
- (nonnull HXDiskStorgeItem *)itemForKey:(NSString *)key;

- (HXDiskStorgeItem *)itemInfoForKey:(NSString *)key;

- (NSArray<HXDiskStorgeItem *> *)itemInfoForKeys:(NSArray *)keys;

- (nonnull NSData *)itemValueForKey:(NSString *)key;

- (nonnull NSArray<HXDiskStorgeItem *> *)itemsForKeys:(NSArray<NSString *> *)keys;

- (nonnull NSArray<NSData *> *)itemValuesForKeys:(NSArray<NSString *> *)keys;

- (int)itemsSize;

- (int)itemsCount;

- (BOOL)isItemExistsForKey:(NSString *)key ;
@end

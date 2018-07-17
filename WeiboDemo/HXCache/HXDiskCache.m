//
//  HXDiskCache.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXDiskCache.h"
#import "HXDiskStorge.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <time.h>

#define lock() dispatch_semaphore_wait(self.mutex, DISPATCH_TIME_FOREVER);
#define unLock() dispatch_semaphore_signal(self.mutex);

const void* extended_data_key;

@interface HXDiskCache()

@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, strong) dispatch_semaphore_t mutex;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) HXDiskStorge *storge;

@end

@implementation HXDiskCache

#pragma mark - life cycle
- (instancetype)initWithPath:(NSString *)path{
    self = [super init];
    if (self) {
        HXDiskCache *globalCache = HXDiskCacheGetGlobal(path);
        if (globalCache) {
            return globalCache;
        }
        
        self.storge = [[HXDiskStorge alloc] initWithPath:path];
        self.path = path;
        self.countLimit = NSUIntegerMax;
        self.costLimit = NSUIntegerMax;
        self.ageLimit = DBL_MAX;
        self.freeDiskSpaceLimit = 0;
        self.autoTrimInterval = 60;
        
        [self trimRecursively];
        HXDiskCacheSetGlobal(self);
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillBeTerminated) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}


#pragma mark - public method
- (BOOL)containsObjectForKey:(NSString *)key{
    if (key.length == 0) {
        return NO;
    }
    lock();
    BOOL isContain = [self.storge isItemExistsForKey:key];
    unLock();
    return isContain;
}

- (id<NSCoding>)objectForKey:(NSString *)key{
    if (key.length == 0) {
        return nil;
    }
    lock()
    HXDiskStorgeItem *item = [self.storge itemForKey:key];
    unLock();
    id object = nil;
    if (self.customUnarchiveBlock) {
        object = self.customUnarchiveBlock(item.value);
    }else{
        @try {
            object = [NSKeyedUnarchiver unarchiveObjectWithData:item.value];
        }
        @catch (NSException *exception) {
        }
    }
    
    if (object && item.extendData) {
        [HXDiskCache setExtendedData:item.extendData toObject:object];
    }
    return object;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key{
    if (key.length == 0) {
        return;
    }
    if (!object) {
        [self removeObjectForKey:key];
        return;
    }
    
    NSData *exetendedData = [HXDiskCache getExtendedDataFromObject:object];
    NSData *value = nil;
    if (self.customArchiveBlock) {
        value = self.customArchiveBlock(object);
    } else {
        @try {
            value = [NSKeyedArchiver archivedDataWithRootObject:object];
        }
        @catch (NSException *exception) {
        }
    }
    if (!value) {
        return;
    }
    
    NSLog(@"%@",key);
    lock();
    [self.storge saveItemWithKey:key value:value extendedData:exetendedData];
    unLock();
}

- (void)removeObjectForKey:(NSString *)key{
    if (key.length == 0){
        return;
    }
    lock();
    [self.storge removeItemForKey:key];
    unLock();
}

- (void)removeAllObjects{
    lock();
    [self.storge removeAllItems];
    unLock();
}

- (NSInteger)totalCount{
    lock();
    int count = [self.storge itemsCount];
    unLock();
    return count;
}

- (NSInteger)totalCost {
    lock();
    int count = [self.storge itemsSize];
    unLock();
    return count;
}

- (void)trimToCount:(NSUInteger)count {
    lock();
    [self trimToCountCore:count];
    unLock();
}


- (void)trimToCost:(NSUInteger)cost {
    lock();
    [self trimToCostCore:cost];
    unLock();
}

- (void)trimToAge:(NSTimeInterval)age {
    lock();
    [self trimToAgeCore:age];
    unLock();
}

+ (NSData *)getExtendedDataFromObject:(id)object {
    if (!object) return nil;
    return (NSData *)objc_getAssociatedObject(object, &extended_data_key);
}

+ (void)setExtendedData:(NSData *)extendedData toObject:(id)object {
    if (!object) return;
    objc_setAssociatedObject(object, &extended_data_key, extendedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - cache helper method
static int64_t HXDiskFreeSpaceSize() {
    NSError *error = nil;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (error){
        NSLog(@"%@",error);
        return -1;
    }
    int64_t space =  [[attrs objectForKey:NSFileSystemFreeSize] longLongValue];
    if (space < 0) space = -1;
    return space;
}


#pragma mark - cache for hxDiskChache method
static NSMapTable *_globalInstances;
static dispatch_semaphore_t _globalInstancesLock;

// 初始化缓存与锁
static void HXDiskCacheInitGlobal() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _globalInstancesLock = dispatch_semaphore_create(1);
        _globalInstances = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:0];
    });
}

// 从缓存中查找HXDiskCache对象
static HXDiskCache *HXDiskCacheGetGlobal(NSString *path) {
    if (path.length == 0){
        return nil;
    }
    HXDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    id cache = [_globalInstances objectForKey:path];
    dispatch_semaphore_signal(_globalInstancesLock);
    return cache;
}

// 将HXDiskCache放入缓存对象
static void HXDiskCacheSetGlobal(HXDiskCache *cache) {
    if (cache.path.length == 0){
        return;
    }
    HXDiskCacheInitGlobal();
    dispatch_semaphore_wait(_globalInstancesLock, DISPATCH_TIME_FOREVER);
    [_globalInstances setObject:cache forKey:cache.path];
    dispatch_semaphore_signal(_globalInstancesLock);
}


#pragma mark - trim
// 做LRU剪枝
- (void)trimRecursively {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoTrimInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(weakSelf) self = weakSelf;
        [self trimInBackground];
        [self trimRecursively];
    });
}

- (void)trimInBackground {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        __strong typeof(weakSelf) self = weakSelf;
        lock();
        [self trimToCostCore:self.costLimit];
        [self trimToCountCore:self.countLimit];
        [self trimToAgeCore:self.ageLimit];
        [self trimToFreeDiskSpace:self.freeDiskSpaceLimit];
        unLock();
    });
}

- (void)trimToCostCore:(NSUInteger)costLimit {
    if (costLimit >= INT_MAX){
        return;
    }
    [self.storge removeItemsToFitSize:(int)costLimit];
    
}

- (void)trimToCountCore:(NSUInteger)countLimit {
    if (countLimit >= INT_MAX){
        return;
    }
    [self.storge removeItemsToFitCount:(int)countLimit];
}

- (void)trimToAgeCore:(NSTimeInterval)ageLimit {
    if (ageLimit <= 0) {
        [self.storge removeAllItems];
        return;
    }
    long timestamp = time(NULL);
    if (timestamp <= ageLimit){
        return;
    }
    long age = timestamp - ageLimit;
    if (age >= INT_MAX){
        return;
    }
    [self.storge removeItemThanTimeInterval:(int)age];
}

- (void)trimToFreeDiskSpace:(NSUInteger)targetFreeDiskSpace {
    if (targetFreeDiskSpace == 0){
        return;
    }
    int64_t totalBytes = [self.storge itemSize];
    if (totalBytes <= 0){
        return;
    }
    int64_t diskFreeBytes = HXDiskFreeSpaceSize();
    if (diskFreeBytes < 0){
        return;
    }
    int64_t needTrimBytes = targetFreeDiskSpace - diskFreeBytes;
    if (needTrimBytes <= 0){
        return;
    }
    int64_t costLimit = totalBytes - needTrimBytes;
    if (costLimit < 0){
        costLimit = 0;
    }
    [self trimToCost:(int)costLimit];
}

- (void)appWillBeTerminated {
    lock();
    self.storge = nil;
    unLock();
}

#pragma mark - getter & setter method
- (dispatch_semaphore_t)mutex{
    if (!_mutex) {
        _mutex = dispatch_semaphore_create(1);
    }
    return _mutex;
}

- (dispatch_queue_t)queue{
    if (!_queue) {
        _queue = _queue = dispatch_queue_create("hx.cache.disk", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}


@end

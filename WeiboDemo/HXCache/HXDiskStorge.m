//
//  HXDiskStorge.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXDiskStorge.h"
#import <sqlite3.h>
#import <QuartzCore/QuartzCore.h>

@implementation HXDiskStorgeItem
@end

const NSTimeInterval kHXRetryMinTimeInterval = 2.0;
const NSInteger kHXErrorRetryMaxCount = 8;
NSString *const kHXDBFileName = @"hxcache.sqlite";
NSString *const kHXDBShmFileName = @"hxcache.sqlite-shm";
NSString *const kHXDBWalFileName = @"hxcache.sqlite-wal";

@interface HXDiskStorge()

@property (nonatomic, copy) NSString *path; // db的原始路径
@property (nonatomic, copy, readwrite) NSString *dbPath; // db的存储路径
@property (nonatomic, assign, readwrite) NSInteger itemSize; // db的现有数据大小
@property (nonatomic, assign, readwrite) NSInteger itemCount; // db的现有条目数
@property (nonatomic, assign) NSInteger dbOpenErrorCount;
@property (nonatomic, assign) NSTimeInterval dbLastOpenErrorTime;

@end

@implementation HXDiskStorge{
   sqlite3 *_db;
}

#pragma mark - life cycle
- (instancetype)initWithPath:(NSString *)path{
    if (path.length == 0) {
        @throw [NSException exceptionWithName:@"HXDiskStorge init failed" reason:@"the path is invaild" userInfo:nil];
    }
    
    self = [super init];
    
    if (self) {
        self.path = path;
        self.dbPath = [path stringByAppendingString:kHXDBFileName];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error] ) {
            NSLog(@"HXDiskStorge init faild: %@",error);
            return nil;
        }
        
        if (![self dbOpen] || ![self dbInitialize]) {
            [self dbClose];
            [self dbRest]; // rebuild
            if (![self dbOpen] || ![self dbInitialize]) {
                [self dbClose];
                     NSLog(@"HXDiskStorge init error: fail to open database.");
                return nil;
            }
        }
    }
    
    return self;
}

- (void)dealloc {
    [self dbClose];
}

#pragma mark - public method for add
- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value{
    return [self saveItemWithKey:key value:value extendedData:nil];
}

- (BOOL)saveItemWithKey:(NSString *)key value:(NSData *)value extendedData:(NSData *)extendedData{
    if (key.length == 0 || value.length == 0) {
        return NO;
    }
    return [self dbSaveWithKey:key value:value extendedData:extendedData];
}


#pragma mark - public method for read
- (HXDiskStorgeItem *)itemForKey:(NSString *)key{
    if (key.length == 0) {
        return nil;
    }
    HXDiskStorgeItem *item = [self dbGetItemWithKey:key excludeInlineData:NO];
    if (item) {
        [self dbUpdateAccessTimeWithKey:key];
    }
    return item;
}


- (NSArray<HXDiskStorgeItem *> *)itemsForKeys:(NSArray<NSString *> *)keys{
    if (keys.count == 0){
        return nil;
    }
    NSArray *items = [self dbGetItemWithKeys:keys excludeInlineData:NO];
    if (items.count > 0) {
        [self dbUpdateAccessTimeWithKeys:keys];
    }
    return items.count ? items : nil;
}

- (NSData *)itemValueForKey:(NSString *)key{
    if (key.length == 0){
        return nil;
    }
    NSData *value = [self dbGetValueWithKey:key];
    if (value) {
        [self dbUpdateAccessTimeWithKey:key];
    }
    return value;
}

- (NSDictionary<NSString *, NSData *> *)itemValuesForKeys:(NSArray<NSString *> *)keys{
    NSArray *items = [self itemsForKeys:keys];
    NSMutableDictionary *itemDic = [[NSMutableDictionary alloc] init];
    for (HXDiskStorgeItem *item in items) {
        if (item.key && item.value) {
            [itemDic setObject:item.value forKey:item.key];
        }
    }
    return itemDic.count ? [itemDic copy] : nil;
}

- (HXDiskStorgeItem *)itemInfoForKey:(NSString *)key{
    if (key.length == 0){
        return nil;
    }
    return [self dbGetItemWithKey:key excludeInlineData:YES];
}

- (NSArray<HXDiskStorgeItem *> *)itemInfoForKeys:(NSArray *)keys{
    if (keys.count == 0){
        return nil;
    }
    return [self dbGetItemWithKeys:keys excludeInlineData:YES];
}

- (BOOL)isItemExistsForKey:(NSString *)key {
    if (key.length == 0) return NO;
    return [self dbGetItemCountWithKey:key] > 0;
}

- (int)itemsCount {
    return [self dbGetTotalItemCount];
}

- (int)itemsSize {
    return [self dbGetTotalItemSize];
}

#pragma mark - public method for delete
- (BOOL)removeItemForKey:(NSString *)key{
    if (key.length == 0) {
        return NO;
    }
    
    return [self dbDeleteItemWithKey:key];
}

- (BOOL)removeItemForKeys:(NSArray<NSString *> *)keys{
    if (keys.count == 0) {
        return NO;
    }
    
    return [self dbDeleteItemWithKeys:keys];
}

- (BOOL)removeItemThanSize:(int)maxSize{
    if (maxSize == INT_MAX) {
        return YES;
    }
    if (maxSize <= 0) {
        return [self removeAllItems];
    }
    if ([self dbDeleteItemsWithSizeLargerThan:maxSize]) {
        return [self dbCheckPoint];
    }
    return NO;
}

- (BOOL)removeItemsToFitSize:(int)maxSize{
    if (maxSize == INT_MAX){
        return YES;
    }
    if (maxSize <= 0){
        return [self removeAllItems];
    }
    
    int total = [self dbGetTotalItemSize];
    if (total < 0){
        return NO;
    }
    if (total <= maxSize){
        return YES;
    }
    
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int perCount = 16;
        items = [self dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (HXDiskStorgeItem *item in items) {
            if (total > maxSize) {
                success = [self dbDeleteItemWithKey:item.key];
                total -= item.size;
            } else {
                break;
            }
            if (!success) break;
        }
    } while (total > maxSize && items.count > 0 && success);
    if (success) [self dbCheckPoint];
    return success;
}

- (BOOL)removeItemsToFitCount:(int)maxCount {
    if (maxCount <= 0){
        return [self removeAllItems];
    }
    
    int total = [self dbGetTotalItemCount];
    if (total < 0) return NO;
    if (total <= maxCount) return YES;
    
    NSArray *items = nil;
    BOOL success = NO;
    do {
        int perCount = 16;
        items = [self dbGetItemSizeInfoOrderByTimeAscWithLimit:perCount];
        for (HXDiskStorgeItem *item in items) {
            if (total > maxCount) {
                success = [self dbDeleteItemWithKey:item.key];
                total--;
            } else {
                break;
            }
            if (!success) break;
        }
    } while (total > maxCount && items.count > 0 && success);
    if (success) [self dbCheckPoint];
    return success;
}

- (BOOL)removeItemThanTimeInterval:(int)timeInterval{
    if (timeInterval == INT_MAX) {
        return [self removeAllItems];
    }
    if ([self dbDeleteItemsWithTimeEarlierThan:timeInterval]) {
        return [self dbCheckPoint];
    }
    return NO;
}

- (BOOL)removeAllItems{
    // 重新建个数据库
    if (![self dbClose]) {
        return NO;
    }
    [self dbRest];
    if (![self dbOpen]) {
        return NO;
    }
    if (![self dbInitialize]) {
        return NO;
    }
    return YES;
}

#pragma mark - private method for db
- (BOOL)dbOpen{
    if (_db) {
        return YES;
    }
    int openResult = sqlite3_open(self.dbPath.UTF8String, &(_db));
    if (openResult != SQLITE_OK) {
        _db = NULL;
    }
    return YES;
}

- (BOOL)dbClose{
    if (!_db) {
        return YES;
    }
    
    int closeResult = 0;
    BOOL successClose = YES;;
    BOOL stmtFinalized = NO;
    
    do{
       successClose = YES;
       closeResult = sqlite3_close(_db);
        if (closeResult == SQLITE_BUSY || closeResult == SQLITE_LOCKED) {
            if (!stmtFinalized) {
                // 释放相关联的prepared语句
                sqlite3_stmt *stmt;
                while ((stmt = sqlite3_next_stmt(_db, nil)) != 0) {
                    sqlite3_finalize(stmt);
                }
                successClose = NO;
                stmtFinalized = YES;
            }
        }else if (closeResult != SQLITE_OK){
            NSLog(@"[%@]:<%s>:dateBase close failed",NSStringFromClass([self class]), __func__);
        }
        
    }while (!successClose);
    _db = NULL;
    return YES;
}

- (BOOL)dbCheck {
    if (!_db) {
        if (self.dbOpenErrorCount < kHXErrorRetryMaxCount && self.dbLastOpenErrorTime - CACurrentMediaTime() <= kHXRetryMinTimeInterval) {
            return [self dbOpen] && [self dbInitialize];
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)dbInitialize{
    NSString *sqlModelStr = @"PRAGMA journal_model = wal;";
    NSString *sqlSynchronousStr = @"PRAGMA synchronous = normal;";
    NSString *sqlTableCreatStr = @"CREATE TABLE IF NOT EXISTS hxcache (key text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data blob, primary key(key));";
    NSString *sqlIndexCreatStr = @"CREATE INDEX IF NOT EXISTS last_access_time_idx ON hxcache(last_access_time);";
    NSString *sql = [NSString stringWithFormat:@"%@%@%@%@",sqlModelStr,sqlSynchronousStr,sqlTableCreatStr,sqlIndexCreatStr];
    
    return [self dbExecuteWithSql:sql];
}

- (BOOL)dbCheckPoint{
    if (![self dbCheck]) {
        return NO;
    }
    
    // 写回数据库文件
    return sqlite3_wal_checkpoint(_db, NULL);
}

- (BOOL)dbExecuteWithSql:(NSString *)sql{
    if (sql.length == 0 || ![self dbCheck]) {
        return NO;
    }
    
    char *error = NULL;
    int executeResult = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &error);
    if (error) {
        NSLog(@"[%@]:<%s>: sqlite exec falied : %s",NSStringFromClass([self class]), __func__ , error);
        sqlite3_free(error);
    }
    
    return executeResult == SQLITE_OK;
}

- (sqlite3_stmt *)dbPrepareStmtWithSql:(NSString *)sql{
    if (sql.length == 0 || ![self dbCheck]) {
        return NULL;
    }
    
    sqlite3_stmt *stmt = NULL;
    int prepareResult = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (prepareResult != SQLITE_OK) {
        NSLog(@"[%@]:<%s>: sqlite stmt prepare failed , sql is :%@",NSStringFromClass([self class]), __func__, sql);
    }
    
    return stmt;
}


- (BOOL)dbSaveWithKey:(NSString *)key value:(NSData *)value extendedData:(NSData *)extendData{
    NSString *sql = @"INSERT OR REPLACE INTO hxcache (key, size, inline_data, modification_time, last_access_time, extended_data) VALUES (?1, ?2, ?3, ?4, ?5, ?6);";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt) {
        return NO;
    }
    
    int timeStamp = (int)time(NULL);
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    sqlite3_bind_int(stmt, 2, (int)value.length);
    sqlite3_bind_blob(stmt, 3, value.bytes, (int)value.length, 0);
    sqlite3_bind_int(stmt, 4, timeStamp);
    sqlite3_bind_int(stmt, 5, timeStamp);
    sqlite3_bind_blob(stmt, 6, extendData.bytes, (int)extendData.length, 0);
    
    return [self dbSqliteStepWithStmt:stmt];;
}

- (BOOL)dbUpdateAccessTimeWithKey:(NSString *)key{
    NSString *sql = @"UPDATE hxcache SET last_access_time = ?1 WHERE key = ?2;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt) {
        return NO;
    }
    
    sqlite3_bind_int(stmt, 1, (int)time(NULL));
    sqlite3_bind_text(stmt, 2, key.UTF8String, -1, NULL);
    
    return [self dbSqliteStepWithStmt:stmt];;
}

- (BOOL)dbUpdateAccessTimeWithKeys:(NSArray *)keys {
    int timeStamp = (int)time(NULL);
    NSString *sql = [NSString stringWithFormat:@"UPDATE hxcache SET last_access_time = %d WHERE key in (%@);", timeStamp, [self dbJoinKeysForKeysCount:keys.count]];
    
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt) {
        return NO;
    }
    [self dbBindJoinedKeys:keys withStmt:stmt fromIndex:1];
    
    return  [self dbSqliteStepWithStmt:stmt];;
}


- (BOOL)dbDeleteItemWithKey:(NSString *)key {
    NSString *sql = @"DELETE FROM hxcache WHERE key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return NO;
    }
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    return  [self dbSqliteStepWithStmt:stmt];;
}


- (BOOL)dbDeleteItemWithKeys:(NSArray *)keys {
    NSString *sql =  [NSString stringWithFormat:@"DELETE FROM hxcache WHERE key in (%@);", [self dbJoinKeysForKeysCount:keys.count]];
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (stmt) {
        return NO;
    }
    
    [self dbBindJoinedKeys:keys withStmt:stmt fromIndex:1];

    return [self dbSqliteStepWithStmt:stmt];
}

- (BOOL)dbDeleteItemsWithSizeLargerThan:(int)size {
    NSString *sql = @"DELETE FROM hxcache WHERE size > ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return NO;
    }
    
    sqlite3_bind_int(stmt, 1, size);
    
    return [self dbSqliteStepWithStmt:stmt];
}

- (BOOL)dbDeleteItemsWithTimeEarlierThan:(int)time {
    NSString *sql = @"DELETE FROM hxcache WHERE last_access_time < ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return NO;
    }
    sqlite3_bind_int(stmt, 1, time);
    
    return [self dbSqliteStepWithStmt:stmt];
}

- (HXDiskStorgeItem *)dbGetItemWithKey:(NSString *)key excludeInlineData:(BOOL)excludeInlineData{
    NSString *sql = excludeInlineData ? @"SELECT key, size, modification_time, last_access_time, extended_data FROM hxcache WHERE key = ?1;" : @"SELECT key, size, inline_data, modification_time, last_access_time, extended_data FROM hxcache WHERE key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt) {
        return nil;
    }
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    
    HXDiskStorgeItem *item = nil;
    int result = sqlite3_step(stmt);
    if (result == SQLITE_ROW) {
        item = [self dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
    }else{
        if (result != SQLITE_DONE) {
        NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
        }
    }
    sqlite3_finalize(stmt);
    
    return item;
}

- (NSArray <HXDiskStorgeItem *> *)dbGetItemWithKeys:(NSArray *)keys excludeInlineData:(BOOL)excludeInlineData {
    if (![self dbCheck]){
        return nil;
    }
    NSString *sql;
    if (excludeInlineData) {
        sql = [NSString stringWithFormat:@"SELECT key, size, modification_time, last_access_time, extended_data FROM hxcache WHERE key in (%@);", [self dbJoinKeysForKeysCount:keys.count]];
    } else {
        sql = [NSString stringWithFormat:@"SELECT key, size, inline_data, modification_time, last_access_time, extended_data FROM hxcache WHERE key in (%@)", [self dbJoinKeysForKeysCount:keys.count]];
    }
    
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt) {
        NSLog(@"[%@]:<%s>: sqlite prepare failed",NSStringFromClass([self class]), __func__);
        return nil;
    }
    
    [self dbBindJoinedKeys:keys withStmt:stmt fromIndex:1];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            HXDiskStorgeItem *item = [self dbGetItemFromStmt:stmt excludeInlineData:excludeInlineData];
            if (item) [items addObject:item];
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return [items copy];
}

- (NSData *)dbGetValueWithKey:(NSString *)key{
    NSString *sql = @"SELECT inline_data FROM hxcache WHERE key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return nil;
    }
    
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    
    if (result == SQLITE_ROW) {
        const void *inline_data = sqlite3_column_blob(stmt, 0);
        int inline_data_bytes = sqlite3_column_bytes(stmt, 0);
        if (!inline_data || inline_data_bytes <= 0){
            return nil;
        }
        return [NSData dataWithBytes:inline_data length:inline_data_bytes];
    } else {
        if (result != SQLITE_DONE) {
            NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
        }
        return nil;
    }
}

- (NSArray<HXDiskStorgeItem *> *)dbGetItemSizeInfoOrderByTimeAscWithLimit:(int)count {
    NSString *sql = @"SELECT key, size from hxcache ORDER BY last_access_time ASC LIMIT ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return nil;
    }
    sqlite3_bind_int(stmt, 1, count);
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    do {
        int result = sqlite3_step(stmt);
        if (result == SQLITE_ROW) {
            char *key = (char *)sqlite3_column_text(stmt, 0);
            int size = sqlite3_column_int(stmt, 1);
            NSString *keyStr = key ? [NSString stringWithUTF8String:key] : nil;
            if (keyStr) {
                HXDiskStorgeItem *item = [[HXDiskStorgeItem alloc] init];
                item.key = [NSString stringWithUTF8String:key];
                item.size = size;
                [items addObject:item];
            }
        } else if (result == SQLITE_DONE) {
            break;
        } else {
            NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
            items = nil;
            break;
        }
    } while (1);
    sqlite3_finalize(stmt);
    return [items copy];
}

- (int)dbGetItemCountWithKey:(NSString *)key {
    NSString *sql = @"SELECT count(key) FROM hxcache WHERE key = ?1;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return -1;
    }
    sqlite3_bind_text(stmt, 1, key.UTF8String, -1, NULL);
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
        return -1;
    }
    int count = sqlite3_column_int(stmt, 0);
    sqlite3_finalize(stmt);
    return count;
}

- (int)dbGetTotalItemSize {
    NSString *sql = @"SELECT sum(size) from hxcache;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return -1;
    }
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
        NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
        return -1;
    }
    int size = sqlite3_column_int(stmt, 0);
    sqlite3_finalize(stmt);
    return size;
}

- (int)dbGetTotalItemCount {
    NSString *sql = @"SELECT count(*) from hxcache;";
    sqlite3_stmt *stmt = [self dbPrepareStmtWithSql:sql];
    if (!stmt){
        return -1;
    }
    int result = sqlite3_step(stmt);
    if (result != SQLITE_ROW) {
       NSLog(@"[%@]:<%s>: sqlite query failed",NSStringFromClass([self class]), __func__);
       return -1;
    }
    return sqlite3_column_int(stmt, 0);
}



- (HXDiskStorgeItem *)dbGetItemFromStmt:(sqlite3_stmt *)stmt excludeInlineData:(BOOL)excludeInlineData{
    /*(key text, size integer, inline_data blob, modification_time integer, last_access_time integer, extended_data*/
    
    int i = 0;
    char *key = (char *)sqlite3_column_text(stmt, i++);
    int size = sqlite3_column_int(stmt, i++);
    const void *inline_data = excludeInlineData ? NULL : sqlite3_column_blob(stmt, i);
    int inline_data_bytes = excludeInlineData ? 0 : sqlite3_column_bytes(stmt, i++);
    int modification_time = sqlite3_column_int(stmt, i++);
    int last_access_time = sqlite3_column_int(stmt, i++);
    const void *extended_data = sqlite3_column_blob(stmt, i);
    int extended_data_bytes = sqlite3_column_bytes(stmt, i++);
    
    HXDiskStorgeItem *item = [[HXDiskStorgeItem alloc] init];
    if(key){
        item.key = [NSString stringWithUTF8String:key];
    }
    item.size = size;
    if (inline_data_bytes > 0 && inline_data) {
        item.value = [NSData dataWithBytes:inline_data length:inline_data_bytes];
    }
    item.modifyTime = modification_time;
    item.accessTime = last_access_time;
    if (extended_data_bytes > 0 && extended_data) {
        item.extendData = [NSData dataWithBytes:extended_data length:extended_data_bytes];
    }
    
    return item;
}

- (void)dbRest{
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

#pragma mark - private method for dbHelper
- (BOOL)dbSqliteStepWithStmt:(sqlite3_stmt *)stmt{
    int result = sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    if (result != SQLITE_DONE) {
        NSLog(@"[%@]:<%s>: sqlite operate failed",NSStringFromClass([self class]), __func__);
        return NO;
    }
    return YES;
}


- (NSString *)dbJoinKeysForKeysCount:(NSUInteger)keysCount{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (int i = 0; i < keysCount; i++) {
        [str appendString:@"?"];
        if (i != keysCount-1) {
            [str appendString:@","];
        }
    }
    
    return str;
}


- (void)dbBindJoinedKeys:(NSArray *)keys withStmt:(sqlite3_stmt *)stmt fromIndex:(int)index{
    int i = 0;
    for (NSString *key in keys) {
        sqlite3_bind_text(stmt, index + (i++), key.UTF8String, -1, NULL);
    }
}

#pragma mark - getter & setter
- (NSString *)dbPath{
    if (!_dbPath) {
        _dbPath = [[NSString alloc] init];
    }
    return _dbPath;
}

- (NSString *)path{
    if (!_path) {
        _path = [[NSString alloc] init];
    }
    return _path;
}

@end

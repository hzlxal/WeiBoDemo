//
//  HXPageAPIManager.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXPageAPIManager.h"

const NSInteger kPageSizeNotFound = -1;
const NSInteger kPageIsLoading = -1;

@interface HXPageAPIManager()

@property (nonatomic, assign, readwrite) NSUInteger currentPage;
@property (nonatomic, assign, readwrite) NSUInteger pageSize;
@property (nonatomic, assign, readwrite) BOOL hasNextPage;

@property (nonatomic, weak) id<HXPageAPIManager> child;

@end

@implementation HXPageAPIManager

#pragma mark - life cycle
- (instancetype)initWithPageSize:(NSInteger)pageSize{
    return [self initWithPageSize:pageSize startPage:0];
}

- (instancetype)initWithPageSize:(NSInteger)pageSize startPage:(NSInteger)page{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(HXPageAPIManager)]) {
            self.child = (id<HXPageAPIManager>)self;
        }else{
            @throw [NSException exceptionWithName:@"HXPageAPIManager init failed" reason:@"Subclass of HXPageAPIManager should implement <HXPageAPIManager>" userInfo:nil];
        }
        
        self.hasNextPage = YES;
        self.currentPage = page;
        self.pageSize = self.child.currentPageSize;
    }
    return self;
}

#pragma mark - public method
- (void)reset{
    [self resetToPage:0];
}

- (void)resetToPage:(NSUInteger)page{
    self.currentPage = page;
    self.hasNextPage = YES;
}

- (NSInteger)loadNextPage{
    if (self.isLoading) {
        return kPageIsLoading;
    }
    return [super loadData];
}

- (NSInteger)loadNextPageWithoutCache{
    if (self.isLoading) {
        return kPageIsLoading;
    }
    return [super loadDataWithoutCache];
}

#pragma mark - override method
// 重载loadData防止误用
- (NSUInteger)loadData{
    return [self loadNextPage];
}

- (BOOL)beforePerformSuccessWithResponse:(HXURLResponse *)response{
    self.currentPage += 1;
    // 加载页数少于设置页数
    if (self.child.currentPageSize != kPageSizeNotFound && self.child.currentPageSize < self.pageSize) {
        self.hasNextPage = YES;
    }
    return [super beforePerformSuccessWithResponse:response];
}

- (BOOL)beforePerformFailWithResponseError:(HXURLResponseError *)error{
    if (self.currentPage > 0) {
        self.currentPage--;
    }
    return [super beforePerformFailWithResponseError:error];
}

@end

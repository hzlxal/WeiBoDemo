//
//  HXPageAPIManager.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXBaseAPIManager.h"

extern const NSInteger kHXPageIsLoading;

// 子类必须遵守HXPageAPIManager协议
@protocol HXPageAPIManager<HXAPIManager>
@required
- (NSInteger)currentPageSize;// 从未加载过时,应返回kPageSizeNotFound
@end

@interface HXPageAPIManager : HXBaseAPIManager
@property (nonatomic, assign, readonly) NSUInteger pageSize;
@property (nonatomic, assign, readonly) NSUInteger currentPage;
@property (nonatomic, assign, readonly) BOOL hasNextPage;

// 重置currentPage
- (void)reset;
- (void)resetToPage:(NSUInteger)page;

- (NSInteger)loadNextPage; // 如果正在加载则返回kPageIsLoading, 否则则返回requestId
- (NSInteger)loadNextPageWithoutCache;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPageSize:(NSInteger)pageSize;
- (instancetype)initWithPageSize:(NSInteger)pageSize startPage:(NSInteger)page;

@end

//
//  WBHomePageAPIManager.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBHomePageAPIManager.h"

@implementation WBHomePageAPIManager

- (nonnull NSString *)apiVersion {
    return @"2";
}

- (nonnull NSString *)path {
    return @"statuses/public_timeline.json";
}

- (HXRequestType)requestType{
    return HXRequestTypeGET;
}

- (NSInteger)currentPageSize {
    return 50;
}

- (NSDictionary *)reformParams:(NSDictionary *)params{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:params];
    dic[@"count"] = @(self.pageSize);
    dic[@"page"] = @(self.currentPage);
    return [dic copy];
}

@end

//
//  NSURLRequest+HXNetWorking.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "NSURLRequest+HXNetWorking.h"
#import "NSObject+HXAssociatedObject.h"

const void *kHXNetWorkingRequestParams;

@implementation NSURLRequest (HXNetWorking)

- (void)setHx_requestParams:(NSDictionary *)hx_requestParams{
    [self hx_associateValue:hx_requestParams withKey:kHXNetWorkingRequestParams];
}

- (NSDictionary *)hx_requestParams{
   return [self hx_associateValueForKey:kHXNetWorkingRequestParams];
}

@end

//
//  HXImageAPIManager.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/5.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXImageAPIManager.h"

@implementation HXImageAPIManager


#pragma mark - overrid method
- (BOOL)isRequestUsingJSON{
    return NO;
}

- (BOOL)isResponseJSONable{
    return NO;
}


- (HXRequestType)requestType{
    return HXRequestTypeGET;
}

- (NSString *)host{
    if ([self.imageDataSource respondsToSelector:@selector(wholeUrl)]) {
        return [self.imageDataSource wholeUrl];
    }else{
        NSException *exception = [[NSException alloc] initWithName:@"HXImageAPIBaseManager错误" reason:[NSString stringWithFormat:@"%@没有遵循HXImageAPIManagerDataSource协议",self] userInfo:nil];
        @throw exception;
        return nil;
    }
}


#pragma mark - HXAPIManager
- (nonnull NSString *)apiVersion {
    return @"";
}

- (nonnull NSString *)path {
    return @"";
}

@end

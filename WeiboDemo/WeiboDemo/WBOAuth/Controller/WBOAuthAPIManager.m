//
//  HXOAuthAPIManager.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBOAuthAPIManager.h"

@implementation WBOAuthAPIManager

- (nonnull NSString *)apiVersion {
    return @"oauth2";
}

- (nonnull NSString *)path {
    return @"access_token";
}

- (HXRequestType)requestType{
    return HXRequestTypePOST;
}

- (BOOL)shouldCache{
    return NO;
}

@end

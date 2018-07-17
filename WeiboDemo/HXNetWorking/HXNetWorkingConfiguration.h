//
//  HXNetWorkingConfiguration.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#ifndef HXNetWorkingConfiguration_h
#define HXNetWorkingConfiguration_h

// 默认进行缓存
static BOOL kHXShouldCacheDefault = NO;
// 请求超时时间
static NSTimeInterval kHXNetworkingTimeoutSeconds = 20.0f;
// 缓存超时时间
static NSTimeInterval kHXCacheExpirationTimeDefault = 300;

static NSString *kServerURL = @"https://api.weibo.com";

#endif /* HXNetWorkingConfiguration_h */

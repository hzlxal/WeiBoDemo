//
//  WBAccount.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBAccount : NSObject<NSCoding>

@property (nonatomic, copy) NSString *accessToken;

// access_token的生命周期
@property (nonatomic, copy) NSNumber *expiresIn;

// 当前授权用户的UID。
@property (nonatomic, copy) NSString *uid;

// access token的创建时间
@property (nonatomic, strong) NSDate *createdTime;

@end

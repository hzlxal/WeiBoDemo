//
//  HXCacheAPIProxy.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/27.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXCacheAPIProxy : NSObject

+ (instancetype)shareInstance;

- (NSData *)cacheForParams:(NSDictionary *)params
                      host:(NSString *)host
                      path:(NSString *)path
                apiVersion:(NSString *)apiVersion;

- (NSData *)cacheForKey:(NSString *)key;


- (void)setCacheWithData:(NSData *)data
                  params:(NSDictionary *)params
                    host:(NSString *)host
                    path:(NSString *)path
               apiVersion:(NSString *)apiVersion
     cacheExpirationTime:(NSTimeInterval)expirationTime;


@end

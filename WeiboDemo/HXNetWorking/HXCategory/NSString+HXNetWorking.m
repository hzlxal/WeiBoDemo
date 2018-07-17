//
//  NSString+HXNetWorking.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/27.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "NSString+HXNetWorking.h"
#import <CommonCrypto/CommonDigest.h>

#define HX_MD5_Length 16

@implementation NSString (HXNetWorking)

+ (NSString *)hx_urlStringWithHost:(nonnull NSString *)host path:(nonnull NSString *)path apiVersion:(nonnull NSString *)apiVersion{
    
    NSString *urlString = nil;
    if (apiVersion.length > 0) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@",host,apiVersion,path];
    }else if(path.length > 0){
        urlString = [NSString stringWithFormat:@"%@/%@",host,path];
    }else{
        urlString = host;
    }
    
    return urlString;
}


+ (NSString *)hx_md5WithData:(nonnull NSData *)inputData{
    unsigned char outputData[HX_MD5_Length];
    CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
    
    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hashStr appendFormat:@"%02x", outputData[i]];
    
    return [hashStr copy];
}

@end

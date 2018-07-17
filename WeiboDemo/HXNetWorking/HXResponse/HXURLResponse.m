//
//  HXURLResponse.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXURLResponse.h"
#import "NSURLRequest+HXNetWorking.h"

@interface HXURLResponse()

@property (nonatomic, copy, readwrite) NSString *responseString;
@property (nonatomic, assign, readwrite) NSUInteger requestID;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, copy, readwrite) NSURLResponse *response;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation HXURLResponse

- (instancetype)initWithResponseStatus:(HXResponseStatus)responseStatus responseString:(NSString *)responseString request:(NSURLRequest *)request requestID:(NSUInteger)requestID response:(NSURLResponse *)response responseData:(NSData *)responseData{
    
    self = [super init];
    if (self) {
        self.responseStatus = responseStatus;
        self.responseString = responseString;
        self.request = request;
        self.requestID = requestID;
        self.response = response;
        self.responseData = responseData;
        self.requestParams = request.hx_requestParams;
        self.isCache = NO;
    }
    
    return self;
}


- (instancetype)initWithData:(NSData *)data{
    
    self = [super init];
    
    if (self) {
        self.responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.requestID = 0;
        self.request = nil;
        self.responseData = [data copy];
        self.requestParams = nil;
        self.isCache = YES;
    }
    
    return self;
}

@end

//
//  HXURLResponseError.m
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXURLResponseError.h"

NSString *const kHXURLResponseErrorDomain = @"hx.error.urlresponse";

@interface HXURLResponseError()

@property (nonatomic, assign, readwrite) NSUInteger requestID;

@end

@implementation HXURLResponseError
@dynamic message;

#pragma mark - life cycle

- (instancetype)initWithMessage:(NSString *)message code:(NSInteger)code requestID:(NSUInteger)requestID{
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
    
    self = [super initWithDomain:kHXURLResponseErrorDomain code:code userInfo:userInfo];
    if (self) {
        self.requestID = requestID;
    }
    
    return self;
}


#pragma mark - public method

+ (HXURLResponseError *)errorWithMessage:(NSString *)message code:(NSInteger)code requestID:(NSUInteger)requestID{
    return [[HXURLResponseError alloc] initWithMessage:message code:code requestID:requestID];
}


#pragma mark - getter && setter

- (NSString *)message{
    return [self localizedDescription];
}


#pragma mark - override

- (NSString *)description{
   return [NSString stringWithFormat:@"[%lu]----code:%lu, message:%@",self.requestID,self.code,self.message];
}

@end

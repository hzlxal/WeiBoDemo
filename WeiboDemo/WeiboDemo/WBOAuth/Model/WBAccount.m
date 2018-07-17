//
//  WBAccount.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBAccount.h"
#import <YYModel.h>

@implementation WBAccount

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"accessToken":@"access_token",
             @"expiresIn":@"expires_in",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
     self.createdTime = [NSDate date];
     return YES;
}



- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.expiresIn forKey:@"expiresIn"];
    [aCoder encodeObject:self.createdTime forKey:@"createdTime"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        self.uid = [aDecoder decodeObjectForKey:@"uid"];
        self.expiresIn = [aDecoder decodeObjectForKey:@"expiresIn"];
        self.createdTime = [aDecoder decodeObjectForKey:@"createdTime"];
    }
    
    return self;
}

@end

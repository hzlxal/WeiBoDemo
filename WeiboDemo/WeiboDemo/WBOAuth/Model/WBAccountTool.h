//
//  WBAccountTool.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBAccount.h"
#import "HXCache.h"

@interface WBAccountTool : NSObject

+ (void)saveAccount:(WBAccount *)account;

+ (WBAccount *)account;

@end

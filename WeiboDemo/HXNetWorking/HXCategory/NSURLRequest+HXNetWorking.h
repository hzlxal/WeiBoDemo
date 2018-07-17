//
//  NSURLRequest+HXNetWorking.h
//  WeiboDemo
//
//  Created by hzl on 2018/6/26.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (HXNetWorking)

// 保存发起请求时的参数
@property (nonatomic, copy) NSDictionary *hx_requestParams;

@end

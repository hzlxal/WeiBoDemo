//
//  HXImageAPIManager.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/5.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXBaseAPIManager.h"

@protocol HXImageAPIManagerDataSource<NSObject>
@required
- (NSString *)wholeUrl;
@end


/**
 用于图片下载的APIManager
 */
@interface HXImageAPIManager : HXBaseAPIManager<HXAPIManager>

@property (nonatomic, weak) id<HXImageAPIManagerDataSource> imageDataSource;

@end

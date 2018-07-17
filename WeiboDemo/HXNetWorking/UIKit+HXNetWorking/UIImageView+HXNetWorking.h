//
//  UIImageView+HXNetWorking.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXImageAPIManager.h"

typedef void(^HXCompletionBlk)(UIImage *_Nullable image, NSURL *url);

@interface UIImageView (HXNetWorking)<HXAPIManagerDelegate,HXImageAPIManagerDataSource>

- (void)hx_setImageWithURL:(NSURL *)url;

- (void)hx_setImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder;

- (void)hx_setImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder completion:(HXCompletionBlk)blk;

- (void)cancelCurrentImageRequest;

@end

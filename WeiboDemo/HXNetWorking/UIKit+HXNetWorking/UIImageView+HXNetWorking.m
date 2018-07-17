//
//  UIImageView+HXNetWorking.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "UIImageView+HXNetWorking.h"
#import "NSObject+HXAssociatedObject.h"

const void *kHXImageAPIManager;
const void *kHXImageURL;
const void *kHXImageCompletionBlk;

@implementation UIImageView (HXNetWorking)

#pragma mark - public method
- (void)hx_setImageWithURL:(NSURL *)url{
    [self hx_setImageWithURL:url placeHolder:nil];
}

- (void)hx_setImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder{
    [self hx_setImageWithURL:url placeHolder:placeHolder completion:nil];
}

- (void)hx_setImageWithURL:(NSURL *)url placeHolder:(UIImage *)placeHolder completion:(HXCompletionBlk)blk{
    
    HXImageAPIManager *manager = [[HXImageAPIManager alloc] init];
    manager.delegate = self;
    manager.imageDataSource = self;
    [self hx_associateValue:manager withKey:&kHXImageAPIManager];
    [self hx_associateValue:url withKey:&kHXImageURL];
    if (blk) {
        [self hx_associateValue:blk withKey:&kHXImageCompletionBlk];
    }
    
    self.image = placeHolder;
    [manager loadData];
}

- (void)cancelCurrentImageRequest{
    HXImageAPIManager *manager = [self hx_associateValueForKey:&kHXImageAPIManager];
    [manager cancleAllRequests];
}

#pragma mark - HXAPIManagerDelegate & HXImageAPIManagerDataSource
- (void)apiManager:(HXBaseAPIManager *)apiManager loadDataFail:(HXURLResponseError *)error {
    NSLog(@"%@",error);
}


- (void)apiManagerLoadDataSuccess:(HXBaseAPIManager *)manager {
    UIImage * __block image = [UIImage imageWithData:[manager fetchData]];
    HXCompletionBlk blk = [self hx_associateValueForKey:&kHXImageCompletionBlk];
    NSURL *url = [self hx_associateValueForKey:&kHXImageURL];
    if (blk) {
        blk(image, url);
    }else{
        self.image = image;
    }
}

- (NSString *)wholeUrl {
    return ((NSURL *)[self hx_associateValueForKey:&kHXImageURL]).absoluteString;
}

@end

//
//  HXPhotoGroupItem.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXPhotoGroupItem.h"
#import "UIView+HXAdd.h"


@implementation HXPhotoGroupItem
- (UIImage *)thumbImage {
    if ([_thumbView respondsToSelector:@selector(image)]) {
        return ((UIImageView *)_thumbView).image;
    }
    return nil;
}

- (BOOL)thumbClippedToTop {
    if (_thumbView) {
        if (_thumbView.layer.contentsRect.size.height < 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view {
    if (imageSize.width < 1 || imageSize.height < 1){
        return NO;
    }
    if (view.width < 1 || view.height < 1){
        return NO;
    }
    return imageSize.height / imageSize.width > view.width / view.height;
}

- (id)copyWithZone:(NSZone *)zone {
    HXPhotoGroupItem *item = [self.class new];
    return item;
}
@end

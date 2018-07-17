//
//  HXPhotoGroupItem.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HXPhotoGroupItem : NSObject

@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) NSURL *largeImageURL;
@property (nonatomic, readonly) UIImage *thumbImage;
@property (nonatomic, readonly) BOOL thumbClippedToTop;

- (BOOL)shouldClipToTop:(CGSize)imageSize forView:(UIView *)view;
@end

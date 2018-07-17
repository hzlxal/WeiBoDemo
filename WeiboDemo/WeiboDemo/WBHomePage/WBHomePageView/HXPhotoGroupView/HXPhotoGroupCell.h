//
//  HXPhotoGroupCell.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPhotoGroupItem.h"

@interface HXPhotoGroupCell : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong)  HXPhotoGroupItem *item;
@property (nonatomic, readonly) BOOL itemDidLoad;
- (void)resizeSubviewSize;
- (void)scrollToTopWithAnimated:(BOOL)animated;

@end

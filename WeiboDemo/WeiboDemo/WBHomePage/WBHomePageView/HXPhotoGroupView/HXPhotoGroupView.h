//
//  HXPhotoGroupView.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXPhotoGroupCell.h"
#import "HXPhotoGroupItem.h"
@interface HXPhotoGroupView : UIView

@property (nonatomic, readonly) NSArray<HXPhotoGroupItem *> *groupItems;
@property (nonatomic, readonly) NSInteger currentPage;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithGroupItems:(NSArray *)groupItems;

- (void)presentFromImageView:(UIView *)fromView toContainer:(UIView *)container animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismiss;

@end

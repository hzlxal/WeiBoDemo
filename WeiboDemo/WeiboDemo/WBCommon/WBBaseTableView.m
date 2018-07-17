//
//  WBBaseTableView.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/4.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBBaseTableView.h"

@implementation WBBaseTableView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    /*
     是否延迟决定是否滚动(150ms内若手指移动则发送滚动，
     超出150ms外则把消息转发给子控件，
     若150ms以外手指发生滑动则会向子控件发送touchesCancelled后开始滑动
     delaysContentTouches=NO会立即把该事件传递给subView
     canCancelContentTouches=NO交给subView后会不再发生scroll事件)
     */
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = YES;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.estimatedRowHeight = NO;
    
    // UITableViewWrapperView不属于UIScrollView
    UIView *wrapView = self.subviews.firstObject;
    // UITableViewWrapperView
    if (wrapView && [NSStringFromClass(wrapView.class) hasSuffix:@"WrapperView"]) {
        for (UIGestureRecognizer *gesture in wrapView.gestureRecognizers) {
            if ([NSStringFromClass(gesture.class) containsString:@"DelayedTouchesBegan"] ) {
                gesture.enabled = NO;
                break;
            }
        }
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ( [view isKindOfClass:[UIControl class]]) {
        return YES;
    }
    return [super touchesShouldCancelInContentView:view];
}

@end

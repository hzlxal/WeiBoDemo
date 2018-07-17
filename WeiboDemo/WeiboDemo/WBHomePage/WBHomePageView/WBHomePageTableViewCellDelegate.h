//
//  WBHomePageTableViewCellDelegate.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WBHomePageTableViewCell;
@class WBModel;

@protocol WBHomePageTableViewCellDelegate <NSObject>
@optional
// 点击了Cell
- (void)cellDidClick:(WBHomePageTableViewCell *)cell;
// 点击了转发内容
- (void)cellDidClickRetweet:(WBHomePageTableViewCell *)cell;
// 点击了Cell菜单
- (void)cellDidClickMenu:(WBHomePageTableViewCell *)cell;
// 点击了关注
- (void)cellDidClickFollow:(WBHomePageTableViewCell *)cell;
// 点击了转发
- (void)cellDidClickRepost:(WBHomePageTableViewCell *)cell;
// 点击了评论
- (void)cellDidClickComment:(WBHomePageTableViewCell *)cell;
// 点击了赞
- (void)cellDidClickLike:(WBHomePageTableViewCell *)cell;
// 点击了用户
- (void)cell:(WBHomePageTableViewCell *)cell didClickUser:(WBUserModel *)user;
// 点击了图片
- (void)cell:(WBHomePageTableViewCell *)cell didClickImageAtIndex:(NSUInteger)index;
@end



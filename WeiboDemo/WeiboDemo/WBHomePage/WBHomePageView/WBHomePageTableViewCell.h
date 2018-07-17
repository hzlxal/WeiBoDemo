//
//  WBHomePageTableViewCell.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBBaseTableViewCell.h"
#import "WBHomePageLayout.h"
#import "WBHomePageTableViewCellDelegate.h"
@class WBHomePageTableViewCell;


// 用户信息View
@interface WBHomePageProfileView : UIView
@property (nonatomic, strong) UIImageView *avatarView; // 头像
@property (nonatomic, strong) UIImageView *avatarBadgeView; // 徽章
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeAndSourceLabel;
@property (nonatomic, strong) UIButton *arrowButton;
@property (nonatomic, strong) UIButton *followButton;

@property (nonatomic, weak) WBHomePageTableViewCell *cell;
@end


// 工具栏View
@interface WBHomePageToolbarView : UIView
@property (nonatomic, strong) UIButton *repostButton;
@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *likeButton;

@property (nonatomic, strong) UIImageView *repostImageView;
@property (nonatomic, strong) UIImageView *commentImageView;
@property (nonatomic, strong) UIImageView *likeImageView;

@property (nonatomic, strong) CAGradientLayer *line1;
@property (nonatomic, strong) CAGradientLayer *line2;

@property (nonatomic, strong) UILabel *repostLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *likeLabel;

@property (nonatomic, weak) WBHomePageTableViewCell *cell;

@end


// 微博内容View
@interface WBHomePageView : UIView
@property (nonatomic, strong) UIView *contentView;              // 容器
@property (nonatomic, strong) WBHomePageProfileView *profileView; // 用户资料
@property (nonatomic, strong) UILabel *textLabel;               // 文本
@property (nonatomic, strong) NSMutableArray<UIImageView *> *picViews;      // 图片
@property (nonatomic, strong) UIView *retweetBackgroundView;    //转发容器
@property (nonatomic, strong) UILabel *retweetTextLabel;        // 转发文本
@property (nonatomic, strong) WBHomePageToolbarView *toolbarView; // 工具栏
@property (nonatomic, strong) WBHomePageLayout *layout;

@property (nonatomic, weak) WBHomePageTableViewCell *cell;
@end



@interface WBHomePageTableViewCell : WBBaseTableViewCell
@property (nonatomic, weak) id<WBHomePageTableViewCellDelegate> delegate;
@property (nonatomic, strong) WBHomePageView *statusView;
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setLayout:(WBHomePageLayout *)layout;
@end

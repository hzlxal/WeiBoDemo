//
//  WBHomePageLayout.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WBModel.h"
#import "HXTextLayout.h"
#import "WBCommonMacro.h"

@class WBStatusModel;

// 宽高
#define kWBCellTopMargin 8      // cell 顶部灰色留白
#define kWBCellTitleHeight 36   // cell 标题高度 (例如"仅自己可见")
#define kWBCellPadding 12       // cell 内边距
#define kWBCellPaddingTextAnother 10   // cell 文本与其他元素间留白
#define kWBCellPaddingPic 4     // cell 多张图片中间留白
#define kWBCellPaddingText 5 //cell 文本与文本间的宽度
#define kWBCellProfileHeight 56 // cell 名片高度
#define kWBCellAvatarHeight 40 // 头像为40*40的正方形
#define kWBCellNamePaddingLeft 14 // cell 名字和 avatar 之间留白
#define kWBCellContentWidth (kScreenWidth - 2 * kWBCellPadding) // cell 内容宽度
#define kWBCellNameWidth (kScreenWidth - 110) // cell 名字最宽限制


#define kWBCellToolbarHeight 35     // cell 下方工具栏高度
#define kWBCellToolbarBottomMargin 2 // cell 下方灰色留白


// 字体
#define kWBCellNameFontSize 16      // 名字字体大小
#define kWBCellSourceFontSize 12    // 来源字体大小
#define kWBCellTextFontSize 17      // 文本字体大小
#define kWBCellTextFontRetweetSize 16 // 转发字体大小
#define kWBCellToolbarFontSize 14 // 工具栏字体大小

// 颜色
#define kWBCellNameNormalColor UIColorHex(333333) // 名字颜色
#define kWBCellTimeNormalColor UIColorHex(828282) // 时间颜色

#define kWBCellTextNormalColor UIColorHex(333333) // 一般文本色
#define kWBCellTextSubTitleColor UIColorHex(5d5d5d) // 次要文本色
#define kWBCellTextHighlightColor UIColorHex(527ead) // Link 文本色
#define kWBCellTextHighlightBackgroundColor UIColorHex(bfdffe) // Link 点击背景色
#define kWBCellToolbarTitleColor UIColorHex(929292) // 工具栏文本色
#define kWBCellToolbarTitleHighlightColor UIColorHex(df422d) // 工具栏文本高亮色

#define kWBCellBackgroundColor UIColorHex(f2f2f2)    // Cell背景灰色
#define kWBCellHighlightColor UIColorHex(f0f0f0)     // Cell高亮时灰色
#define kWBCellInnerViewColor UIColorHex(f7f7f7)  // Cell转发灰色
#define kWBCellLineColor [UIColor colorWithWhite:0.000 alpha:0.09] //线条颜色


@interface WBHomePageLayout : NSObject

- (instancetype)initWithWBStatus:(WBStatusModel *)status;

// 需要布局的数据
@property (nonatomic, strong) WBStatusModel *status;

/** 布局结果 */
// 顶部留白
@property (nonatomic, assign) CGFloat marginTop; //顶部灰色留白

// 个人资料
@property (nonatomic, assign) CGFloat profileHeight; //个人资料高度(包括留白)
@property (nonatomic, assign) CGRect avatarFrame; // 头像
@property (nonatomic, strong) HXTextLayout *nameTextLayout; // 名字
@property (nonatomic, strong) HXTextLayout *dateAndSourceTextLayout; //时间与来源

// 文本
@property (nonatomic, assign) CGFloat textHeight; //文本高度(包括下方留白)
@property (nonatomic, strong) HXTextLayout *textLayout; //文本

// 图片
@property (nonatomic, assign) CGFloat picHeight; //图片高度，0为没图片
@property (nonatomic, assign) CGSize picSize;

// 转发
@property (nonatomic, assign) CGFloat retweetHeight; //转发高度，0为没转发
@property (nonatomic, assign) CGFloat retweetTextHeight;
@property (nonatomic, strong) HXTextLayout *retweetTextLayout; //被转发文本
@property (nonatomic, assign) CGFloat retweetPicHeight;
@property (nonatomic, assign) CGSize retweetPicSize;
@property (nonatomic, assign) CGRect retweetFrame;


// 工具栏
@property (nonatomic, assign) CGFloat toolbarHeight; // 工具栏高度
@property (nonatomic, strong) HXTextLayout *toolbarRepostTextLayout;
@property (nonatomic, strong) HXTextLayout *toolbarCommentTextLayout;
@property (nonatomic, strong) HXTextLayout *toolbarLikeTextLayout;

// 下边留白
@property (nonatomic, assign) CGFloat marginBottom; //下边留白

// 总高度
@property (nonatomic, assign) CGFloat height;

@end

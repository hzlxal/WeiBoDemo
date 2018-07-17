//
//  WBModel.h
//  WeiboDemo
//
//  Created by hzl on 2018/7/3.
//  Copyright © 2018年 hzl. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface WBPicture: NSObject

@property (nonatomic, copy) NSURL *thumbnailPicUrl;
@property (nonatomic, copy) NSURL *bmiddlePicUrl;
@property (nonatomic, copy) NSURL *originalPicUrl;

@end


typedef NS_ENUM(NSInteger, WBUserVertifedType){
    WBUserVertifedTypeNone = -1, // 没有任何认证
    WBUserVertifedTypePersonal = 0,  // 个人认证
    WBUserVertifedTypeOrgEnterprice = 2, // 企业官方
    WBUserVertifedTypeOrgMedia = 3, // 媒体官方
    WBUserVertifedTypeOrgWebsite = 5, // 网站官方
    WBUserVertifedTypeDaren = 220 // 微博达人
};

// 用户信息
@interface WBUserModel: NSObject

@property (nonatomic, assign) int64_t userID; // 用户ID
@property (nonatomic, copy) NSString *userIDStr; // 字符串型的用户ID
@property (nonatomic, copy) NSString *screenName; // 用户昵称
@property (nonatomic, copy) NSString *name; // 友好显示昵称
@property (nonatomic, assign) int province; // 用户所在省级ID
@property (nonatomic, assign) int city; // 用户所在市级ID
@property (nonatomic, copy) NSString *descriptionInfo; // 用户个人描述
@property (nonatomic, copy) NSURL *url; // 用户博客地址
@property (nonatomic, copy) NSURL *profileImageUrl; // 用户头像地址（中图），50×50像素
@property (nonatomic, copy) NSString *profileUrl; // 用户的微博统一URL地址 (这里的url不完全)
@property (nonatomic, copy) NSString *domain; // 用户的个性化域名
@property (nonatomic, copy) NSString *weihao; // 用户的微号
@property (nonatomic, copy) NSString *gender; // 性别，m：男、f：女、n：未知
@property (nonatomic, assign) int followersCount; // 粉丝数
@property (nonatomic, assign) int friendsCount; // 关注数
@property (nonatomic, assign) int statusesCount; // 微博数
@property (nonatomic, assign) int favouritesCount; // 收藏数
@property (nonatomic, copy) NSString *createdAt; // 用户创建（注册）时间
@property (nonatomic, assign) BOOL allowAllActMsg; // 是否允许所有人给我发私信
@property (nonatomic, assign) BOOL geoEnabled; // 是否允许标识用户的地理位置
@property (nonatomic, assign) BOOL verified; // 是否是微博认证用户，即加V用户
@property (nonatomic, assign) WBUserVertifedType verifiedType; // 用户认证类型
@property (nonatomic, copy) NSString *remark; // 用户备注信息，只有在查询用户关系时才返回此字段
@property (nonatomic, assign) BOOL allowAllComment; // 是否允许所有人对我的微博进行评论
@property (nonatomic, copy) NSURL *avatarLarge; // 用户头像地址（大图），180×180像素
@property (nonatomic, copy) NSURL *avatarHD; // 用户头像地址（高清），高清头像原图
@property (nonatomic, copy) NSString *verifiedReason; // 认证原因
@property (nonatomic, assign) BOOL followMe; // 该用户是否关注当前登录用户
@property (nonatomic, assign) int onlineStatus; // 用户的在线状态
@property (nonatomic, assign) int biFollowersCount; // 用户的互粉数
@property (nonatomic, copy) NSString *lang; // 用户当前的语言版本

@end


// 微博推文
@interface WBStatusModel: NSObject

@property (nonatomic, copy) NSString *createdAt; // 微博创建时间
@property (nonatomic, assign) int64_t wbId; // 微博ID
@property (nonatomic, assign) int64_t wbMid; // 微博的MID
@property (nonatomic, copy) NSString *wbIdStr; // 字符串型的微博ID
@property (nonatomic, copy) NSString *text; // 微博信息内容
@property (nonatomic, copy) NSString *source; // 微博来源
@property (nonatomic, assign) BOOL favorited; // 是否已收藏
@property (nonatomic, assign) BOOL truncated; // 是否被截断
@property (nonatomic, copy) NSURL *thumbnailPic; // 缩略图地址
@property (nonatomic, copy) NSURL *bmiddlePic; // 中等图片尺寸地址
@property (nonatomic, copy) NSURL *originalPic; // 原始图片地址
@property (nonatomic, copy) NSDictionary *geo; // 地理信息
@property (nonatomic, strong) WBUserModel *user; // 微博作者的用户信息
@property (nonatomic, strong) WBStatusModel *retweetedStatus; // 被转发的原微博信息
@property (nonatomic, assign) int repostsCount; // 转发数
@property (nonatomic, assign) int commentsCount; // 评论数
@property (nonatomic, assign) int attitudesCount; // 表态数(赞)
@property (nonatomic, copy) NSDictionary *visible; // 微博的可见性及指定可见分组信息
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSURL *> *> *picUrls; // 微博配图ID
@property (nonatomic, strong) NSArray<WBPicture *> *pictures; // 用于记录微博配图的各尺寸的url
@property (nonatomic, copy) NSArray *ad; // 微博流内的推广微博ID

@end

// 一次请求到的数据

@interface WBModel: NSObject

@property (nonatomic, copy) NSArray *ad; // 微博流内的推广微博的ID
@property (nonatomic, copy) NSArray *advertises;
@property (nonatomic, copy) NSString *sinceID;
@property (nonatomic, copy) NSString *maxID;
@property (nonatomic, copy) NSString *previousCursor;
@property (nonatomic, copy) NSString *nextCursor;
@property (nonatomic, strong) NSArray<WBStatusModel *> *statuses;

@end




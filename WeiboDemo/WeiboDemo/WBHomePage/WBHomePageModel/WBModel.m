//
//  WBModel.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/3.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBModel.h"

@implementation WBPicture
@end

@implementation WBUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userID":@"id",
             @"userIDStr":@"idstr",
             @"screenName":@"screen_name",
             @"name":@"name",
             @"descriptionInfo":@"description",
             @"profileImageUrl":@"profile_image_url",
             @"profileUrl":@"profile_url",
             @"followersCount":@"followers_count",
             @"friendsCount":@"friends_count",
             @"statusesCount":@"statuses_count",
             @"favouritesCount":@"favourites_count",
             @"verifiedType":@"verified_type",
             @"createdAt":@"created_at",
             @"allowAllActMsg":@"allow_all_act_msg",
             @"geoEnabled":@"geo_enabled",
             @"allowAllComment":@"allow_all_comment",
             @"avatarLarge":@"avatar_large",
             @"avatarHD":@"avatar_hd",
             @"verifiedReason":@"verified_reason",
             @"followMe":@"follow_me",
             @"onlineStatus":@"online_status",
             @"biFollowersCount":@"bi_followers_count",
             @"lang":@"zh"
             };
}

@end

@implementation WBStatusModel

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"createdAt":@"created_at",
             @"wbId":@"id",
             @"wbIdStr":@"idstr",
             @"wbMid":@"mid",
             @"picUrls":@"pic_urls",
             @"thumbnailPic":@"thumbnail_pic",
             @"bmiddlePic":@"bmiddle_pic",
             @"originalPic":@"original_pic",
             @"retweetedStatus":@"retweeted_status",
             @"repostsCount":@"reposts_count",
             @"commentsCount":@"comments_count",
             @"attitudesCount":@"attitudes_count",
             @"picUrls":@"pic_urls"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    // 将微博中对应的图片取出
    NSMutableArray *picTempArray = [[NSMutableArray alloc] init];
    NSString *tempPicUrlStr = nil;
    
    if (_picUrls) {
        for (NSDictionary *dict in _picUrls) {
            WBPicture *picture = [[WBPicture alloc] init];
            tempPicUrlStr = dict[@"thumbnail_pic"];
            picture.thumbnailPicUrl = [NSURL URLWithString:tempPicUrlStr];;
            picture.bmiddlePicUrl = [NSURL URLWithString:[tempPicUrlStr stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"]];
            picture.originalPicUrl = [NSURL URLWithString:[tempPicUrlStr stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"]];
            [picTempArray addObject:picture];
        }
    }
    
    _pictures = [picTempArray copy];
    
    return YES;
}

@end


@implementation WBModel

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"sinceID":@"since_id",
             @"maxID":@"max_id",
             @"previousCursor":@"previous_cursor",
             @"nextCursor":@"next_cursor"
             
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"statuses" : [WBStatusModel class]};
}

@end


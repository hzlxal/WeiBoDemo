//
//  WBHomePageLayout.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBHomePageLayout.h"
#import "NSString+HXAdd.h"
#import "WBHomePageHelper.h"
#import "WBModel.h"

@implementation WBHomePageLayout

#pragma mark - life cycle
- (instancetype)initWithWBStatus:(WBStatusModel *)status{
    self = [super init];
    if (self) {
        self.status = status;
        [self layout];
    }
    return self;
}


#pragma mark - layout private Method
- (void)layout{
    // 初始化
    self.marginTop = kWBCellTopMargin;
    self.profileHeight = kWBCellProfileHeight;
    self.textHeight = 0;
    self.retweetHeight = 0;
    self.retweetTextHeight = 0;
    self.retweetPicHeight = 0;
    self.picHeight = 0;
    self.toolbarHeight = kWBCellToolbarHeight;
    self.marginBottom = kWBCellToolbarBottomMargin;
    
    // 计算布局
    [self layoutProfile];
    [self layoutText];
    [self layoutRetweet];
    if (self.retweetHeight == 0) {
        [self layoutPics];
    }
    [self layoutToolbarText];
    
    // 计算高度
    [self caculateHeight];
}

- (void)layoutProfile{
    WBUserModel *user = self.status.user;
    WBStatusModel *status = self.status;
    
    // 头像
    CGFloat avatarX = kWBCellPadding;
    CGFloat avatarY = kWBCellPadding + 3;
    self.avatarFrame = CGRectMake(avatarX, avatarY, kWBCellAvatarHeight, kWBCellAvatarHeight);
    
    // 名称
    NSString *nameStr = nil;
    if (user.screenName.length) {
        nameStr = user.screenName;
    } else {
        nameStr = user.name;
    }
    CGSize nameSize = [nameStr sizeWithFont:[UIFont systemFontOfSize:kWBCellNameFontSize] maxW:kWBCellNameWidth];
    CGFloat nameX = CGRectGetMaxX(self.avatarFrame) + kWBCellNamePaddingLeft;
    CGFloat nameY = avatarY;
    CGRect nameTextFrame = CGRectMake(nameX, nameY, nameSize.width, nameSize.height);
    self.nameTextLayout = [[HXTextLayout alloc] initWithFrame:nameTextFrame color:kWBCellNameNormalColor fontSize:kWBCellNameFontSize text:nameStr];
    
    // 时间与来源
    NSString *sourceStr = nil;
    if (status.source.length > 0) {
        sourceStr = [WBHomePageHelper formatSourceString:status.source];
    }
    NSString *dateStr = [WBHomePageHelper formatDateStringWithDateString:status.createdAt];
    
    NSString *dateAndSource = [dateStr stringByAppendingString:[NSString stringWithFormat:@"   %@",sourceStr]];
    
    CGFloat dsX = nameX;
    CGFloat dsY = CGRectGetMaxY(nameTextFrame) + kWBCellPaddingText;
    CGSize dsSize = [dateAndSource sizeWithFont:[UIFont systemFontOfSize:kWBCellSourceFontSize] maxW:kWBCellContentWidth];
    CGRect dateAndSourceTextFrame = CGRectMake(dsX, dsY, dsSize.width, dsSize.height);
    self.dateAndSourceTextLayout = [[HXTextLayout alloc] initWithFrame:dateAndSourceTextFrame color:kWBCellTimeNormalColor fontSize:kWBCellSourceFontSize text:dateAndSource];
    
    self.profileHeight = kWBCellProfileHeight + kWBCellPadding;
}



- (void)layoutRetweet{
    self.retweetHeight = 0;
    [self layoutRetweetedText];
    [self layoutRetweetPics];
    
    self.retweetHeight = self.retweetTextHeight;
    if (self.retweetPicHeight > 0) {
        self.retweetHeight += self.retweetPicHeight;
        self.retweetHeight += kWBCellPadding;
    }
    
}


- (void)layoutRetweetedText{
    WBStatusModel *retweetedStatus = self.status.retweetedStatus;
    WBUserModel *retweetetStatusUser = retweetedStatus.user;
    NSString *retweetContent = nil;
    if (retweetetStatusUser.name.length > 0) {
    retweetContent = [NSString stringWithFormat:@"@%@ : %@", retweetetStatusUser.name, retweetedStatus.text];
    }
    CGFloat retweetContentX = kWBCellPaddingTextAnother;
    CGFloat retweetContentY = kWBCellPaddingTextAnother;
    CGSize retweetContentSize = [retweetContent sizeWithFont:[UIFont systemFontOfSize:kWBCellTextFontRetweetSize] maxW:kWBCellContentWidth];
    CGRect retweetTextLayoutFrame = CGRectMake(retweetContentX, retweetContentY, retweetContentSize.width, retweetContentSize.height);
    self.retweetTextLayout = [[HXTextLayout alloc] initWithFrame:retweetTextLayoutFrame color:kWBCellTextSubTitleColor fontSize:kWBCellTextFontRetweetSize text:retweetContent];
    
    self.retweetTextHeight = retweetContentSize.height;
}


- (void)layoutRetweetPics{
    [self layoutPicsWithStatus:self.status.retweetedStatus isRetweet:YES];
}


- (void)layoutText{
    CGFloat contentX = kWBCellPaddingTextAnother;
    CGFloat contentY = kWBCellPaddingTextAnother;
    CGSize contentSize = [self.status.text sizeWithFont:[UIFont systemFontOfSize:kWBCellTextFontSize] maxW:kWBCellContentWidth];
    CGRect textFrame = CGRectMake(contentX, contentY, contentSize.width, contentSize.height);
    self.textLayout = [[HXTextLayout alloc] initWithFrame:textFrame color:kWBCellTextNormalColor fontSize:kWBCellTextFontSize text:self.status.text];
    
    self.textHeight = contentSize.height + kWBCellPaddingTextAnother;
}

- (void)layoutPics{
    [self layoutPicsWithStatus:self.status isRetweet:NO];
}



- (void)layoutToolbarText{
    CGFloat toolbarX = 0;
    CGFloat toolbarW = kScreenWidth/3;
    
    NSString *repostText = [[NSString alloc] initWithString:self.status.repostsCount <= 0 ? @"转发" : [WBHomePageHelper shortedNumberDesc:self.status.repostsCount]];
    NSString *commentText = [[NSString alloc] initWithString:self.status.commentsCount <= 0 ? @"评论" : [WBHomePageHelper shortedNumberDesc:self.status.commentsCount]];
    NSString *likeText = [[NSString alloc] initWithString:self.status.attitudesCount <= 0 ? @"赞" : [WBHomePageHelper shortedNumberDesc:self.status.attitudesCount]];
    CGSize repostTextContentSize = [repostText sizeWithFont:[UIFont systemFontOfSize:kWBCellToolbarFontSize] maxW:toolbarW];
    CGSize commentTextContentSize = [commentText sizeWithFont:[UIFont systemFontOfSize:kWBCellToolbarFontSize] maxW:toolbarW];
    CGSize likeTextContentSize = [likeText sizeWithFont:[UIFont systemFontOfSize:kWBCellToolbarFontSize] maxW:toolbarW];
    
    CGRect toolbarRepostTextFrame = CGRectMake(toolbarX, 0, repostTextContentSize.width, kWBCellToolbarHeight);
    [self setToolBarLayout:self.toolbarRepostTextLayout WithFrame:toolbarRepostTextFrame text:repostText];
    
    CGRect toolbarCommentTextFrame = CGRectMake(toolbarX, 0, commentTextContentSize.width, kWBCellToolbarHeight);
    [self setToolBarLayout:self.toolbarCommentTextLayout WithFrame:toolbarCommentTextFrame text:commentText];
    
    CGRect toolbarLikeTextFrame = CGRectMake(toolbarX, 0, likeTextContentSize.width,kWBCellToolbarHeight);
    [self setToolBarLayout:self.toolbarLikeTextLayout WithFrame:toolbarLikeTextFrame text:likeText];
    
    
    self.toolbarHeight = kWBCellToolbarHeight;
}

#pragma mark - tool private Method

- (void)setToolBarLayout:(HXTextLayout *)layout WithFrame:(CGRect)frame text:(NSString *)text{
    layout = [[HXTextLayout alloc] initWithFrame:frame color:kWBCellToolbarTitleColor fontSize:kWBCellToolbarFontSize text:text];
}

- (void)caculateHeight{
    self.height = 0;
    self.height += self.marginTop;
    self.height += self.profileHeight;
    self.height += self.textHeight;
    if (self.retweetHeight > 0) {
        self.height += self.retweetHeight;
    } else if (self.picHeight > 0) {
        self.height += self.picHeight;
    }
    if (self.picHeight > 0) {
        self.height += kWBCellPadding;
    }
    self.height += self.toolbarHeight;
    self.height += self.marginBottom;
}


- (void)layoutPicsWithStatus:(WBStatusModel *)status isRetweet:(BOOL)isRetweet {
    if (isRetweet) {
        self.retweetPicSize = CGSizeZero;
        self.retweetPicHeight = 0;
    } else {
        self.picSize = CGSizeZero;
        self.picHeight = 0;
    }
    
    if (status.pictures.count == 0){
        return;
    }
    
    CGSize picSize = CGSizeZero;
    CGFloat picHeight = 0;
    CGFloat len1_3 = (kWBCellContentWidth + kWBCellPaddingPic) / 3 - kWBCellPaddingPic;
    
    switch (status.pictures.count) {
        case 1: {
            CGFloat maxLen = kWBCellContentWidth / 2.0;
            picSize = CGSizeMake(maxLen, maxLen);
            picHeight = maxLen;
            
        } break;
        case 2: case 3: {
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3;
        } break;
        case 4: case 5: case 6: {
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3 * 2 + kWBCellPaddingPic;
        } break;
        default: {
            picSize = CGSizeMake(len1_3, len1_3);
            picHeight = len1_3 * 3 + kWBCellPaddingPic * 2;
        } break;
    }
    
    if (isRetweet) {
        self.retweetPicSize = picSize;
        self.retweetPicHeight = picHeight;
    } else {
        self.picSize = picSize;
        self.picHeight = picHeight;
    }
    
}
@end

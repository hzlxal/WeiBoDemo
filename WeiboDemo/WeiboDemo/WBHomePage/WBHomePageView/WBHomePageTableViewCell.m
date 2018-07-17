//
//  WBHomePageTableViewCell.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/8.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBHomePageTableViewCell.h"
#import "UILabel+HXAdd.h"
#import "UIView+HXAdd.h"
#import "UIImage+HXAdd.h"
#import "UITapGestureRecognizer+HXAdd.h"
#import "UIImageView+HXNetWorking.h"

@implementation WBHomePageProfileView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 头像
        self.avatarView = [[UIImageView alloc] init];
        self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.avatarView];
        
        // 边线
        CALayer *avatarBorder = [CALayer layer];
        avatarBorder.frame = self.avatarView.bounds;
        avatarBorder.borderWidth = 1.f;
        avatarBorder.borderColor = [UIColor colorWithWhite:0.000 alpha:0.090].CGColor;
        avatarBorder.cornerRadius = _avatarView.frame.size.height / 2;
        avatarBorder.shouldRasterize = YES;
        avatarBorder.rasterizationScale = kScreenScale;
        [self.avatarView.layer addSublayer:avatarBorder];
        
        // 昵称
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.numberOfLines = 0;
        [self addSubview:self.nameLabel];
        
        // 时间与来源
        self.timeAndSourceLabel = [[UILabel alloc] init];
        self.nameLabel.numberOfLines = 0;
        [self addSubview:self.timeAndSourceLabel];
    }
    return self;
}

@end


@implementation WBHomePageToolbarView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
        [self layoutBtn];
        [self setupImageView];
        [self setupLabel];
    }
    return self;
}

#pragma mark - set UI
- (void)layoutBtn{
    self.repostButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.repostButton.exclusiveTouch = YES;
    self.repostButton.size = CGSizeMake(self.width/3.0, self.height);
    [_repostButton setBackgroundImage:[UIImage imageWithColor:kWBCellHighlightColor] forState:UIControlStateHighlighted];
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentButton.exclusiveTouch = YES;
    self.commentButton.size = CGSizeMake(self.width / 3.0, self.height);
    self.commentButton.left = self.width / 3.0;
    [self.commentButton setBackgroundImage:[UIImage imageWithColor:kWBCellHighlightColor] forState:UIControlStateHighlighted];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.exclusiveTouch = YES;
    self.likeButton.size = CGSizeMake(self.width / 3.0, self.height);
    self.likeButton.left = self.width / 3.0 * 2.0;
    [self.likeButton setBackgroundImage:[UIImage imageWithColor:kWBCellHighlightColor] forState:UIControlStateHighlighted];
}

- (void)setWithLayout:(WBHomePageLayout *)layout {
    self.repostLabel.width = layout.toolbarRepostTextLayout.frame.size.width;
    self.commentLabel.width = layout.toolbarCommentTextLayout.frame.size.width;
    self.likeLabel.width = layout.toolbarLikeTextLayout.frame.size.width;
    
    [self adjustImage:self.repostImageView label:self.repostLabel inButton:self.repostButton];
    [self adjustImage:self.commentImageView label:self.commentLabel inButton:self.commentButton];
    [self adjustImage:self.likeImageView label:self.likeLabel inButton:self.likeButton];
}


- (void)setupImageView{
    self.repostImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_icon_retweet"]];
    self.repostImageView.centerY = self.height / 2;
    [self.repostButton addSubview:self.repostImageView];
    
    self.commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_icon_comment"]];
    self.commentImageView.centerY = self.height / 2;
    [self.commentButton addSubview:self.commentImageView];
    
    self.likeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_icon_unlike"]];
    self.likeImageView.centerY = self.height / 2;
    [self.likeButton addSubview:self.likeImageView];
}


- (void)setupLabel{
    self.repostLabel = [[UILabel alloc] init];
    self.repostLabel.userInteractionEnabled = NO;
    self.repostLabel.height = self.height;
    self.repostLabel.centerY = self.height/2;
    [self.repostButton addSubview:self.repostLabel];
    
    self.commentLabel = [[UILabel alloc] init];
    self.commentLabel.userInteractionEnabled = NO;
    self.commentLabel.height = self.height;
    self.repostLabel.centerY = self.height/2;
    [self.commentButton addSubview:self.commentLabel];
    
    self.likeLabel = [[UILabel alloc] init];
    self.likeLabel.userInteractionEnabled = NO;
    self.likeLabel.height = self.height;
    self.repostLabel.centerY = self.height/2;
    [self.likeButton addSubview:self.likeLabel];
    
    [self addSubview:self.repostButton];
    [self addSubview:self.commentButton];
    [self addSubview:self.likeButton];
}


- (void)adjustImage:(UIImageView *)image label:(UILabel *)label inButton:(UIButton *)button {
    CGFloat imageWidth = image.bounds.size.width;
    CGFloat labelWidth = label.frame.size.width;
    CGFloat paddingMid = 5;
    CGFloat paddingSide = (button.width - imageWidth - labelWidth - paddingMid) / 2.0;
    image.centerX = paddingSide + imageWidth / 2;
    label.right = button.width - paddingSide;
}

#pragma mark event response

@end


@implementation WBHomePageView{
    CGFloat _top;
}

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        self.contentView = [[UIView alloc] init];
        self.contentView.width = kScreenWidth;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.contentView];
        
        self.profileView = [[WBHomePageProfileView alloc] initWithFrame:CGRectMake(kWBCellPadding, kWBCellTopMargin, kWBCellContentWidth, kWBCellProfileHeight)];
        [self.contentView addSubview:self.profileView];
        
        self.textLabel = [[UILabel alloc] init];
        self.textLabel.numberOfLines = 0;
        [self.contentView addSubview:self.textLabel];
        
        self.retweetBackgroundView = [[UIView alloc] init];
        self.retweetBackgroundView.width = kScreenWidth;
        self.retweetBackgroundView.left = 0;
        self.retweetBackgroundView.height = 0;
        self.retweetBackgroundView.backgroundColor = kWBCellInnerViewColor;
        [self.contentView addSubview:self.retweetBackgroundView];
        
        self.retweetTextLabel = [[UILabel alloc] init];
        self.retweetTextLabel.numberOfLines = 0;
        self.retweetTextLabel.height = 0;
        [self.contentView addSubview:self.retweetTextLabel];
        
        self.toolbarView = [[WBHomePageToolbarView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kWBCellToolbarHeight)];
        [self.contentView addSubview:self.toolbarView];
        
        [self setPicsViews];
    }
    return self;
}

- (void)setLayout:(WBHomePageLayout *)layout{
    _layout = layout;
    _top = 0;
    [self layoutContentView];
    [self layoutProfileView];
    [self layoutTextLabel];
    self.retweetBackgroundView.height = 0;
    self.retweetTextLabel.height = 0;
    
    if (layout.picHeight == 0 && layout.retweetPicHeight == 0) {
        [self hideImageViews];
    }
    
    if (layout.retweetHeight > 0) {
        [self layoutRetweetBackgroundView];
        [self layoutRetweetTextLabel];
        if (layout.retweetPicHeight > 0) {
            [self setImageViewWithTop:self.retweetTextLabel.bottom isRetweet:YES];
        }
    }else if(layout.picHeight > 0){
        [self setImageViewWithTop:_top isRetweet:NO];
    }
    [self layoutToolbarView];
}


#pragma mark - private method
- (void)layoutContentView{
    self.contentView.top = self.layout.marginTop;
    self.contentView.height = self.layout.height - self.layout.marginTop - self.layout.marginBottom;
}

- (void)layoutProfileView{
    
    // 设置圆角
    __weak typeof(self.profileView.avatarView) weakImageView = self.profileView.avatarView;
    [self.profileView.avatarView hx_setImageWithURL:self.layout.status.user.avatarLarge placeHolder:nil completion:^(UIImage * _Nullable image, NSURL *url) {
        weakImageView.image = [image imageByRoundCornerRadius:image.size.width/2.f];
    }];
    self.profileView.nameLabel.textLayout = self.layout.nameTextLayout;
    self.profileView.timeAndSourceLabel.textLayout = self.layout.dateAndSourceTextLayout;
    self.profileView.avatarView.frame = self.layout.avatarFrame;
    
    _top += self.layout.profileHeight;
}

- (void)layoutTextLabel{
    self.textLabel.textLayout = self.layout.textLayout;
    NSLog(@"%@--------%f",self.layout.textLayout.text,self.layout.textLayout.frame.origin.y);
    self.textLabel.top = _top;
    _top += self.layout.textHeight;
}

- (void)layoutRetweetBackgroundView{
    self.retweetBackgroundView.top = _top;
    self.retweetBackgroundView.height = self.layout.retweetHeight;
}

- (void)layoutRetweetTextLabel{
    self.retweetTextLabel.textLayout = self.layout.retweetTextLayout;
    self.retweetTextLabel.top = _top;
    self.retweetTextLabel.height = self.layout.retweetTextHeight;
}


- (void)layoutToolbarView{
    self.toolbarView.bottom = self.contentView.height;
    [self.toolbarView setWithLayout:self.layout];
}

- (void)setPicsViews{
    NSMutableArray *picViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.size = CGSizeMake(100, 100);
        imageView.hidden = YES;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = kWBCellHighlightColor;
        imageView.exclusiveTouch = YES;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImage:)];
        tapGesture.tag = @(i);
        [imageView addGestureRecognizer:tapGesture];
        
        UIView *badge = [UIImageView new];
        badge.userInteractionEnabled = NO;
        badge.contentMode = UIViewContentModeScaleAspectFit;
        badge.size = CGSizeMake(56 / 2, 36 / 2);
        badge.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        badge.right = imageView.width;
        badge.bottom = imageView.height;
        badge.hidden = YES;
        [imageView addSubview:badge];
        
        [picViews addObject:imageView];
        [self.contentView addSubview:imageView];
    }
    self.picViews = picViews;
}

- (void)setImageViewWithTop:(CGFloat)imageTop isRetweet:(BOOL)isRetweet {
    CGSize picSize = isRetweet ? self.layout.retweetPicSize : self.layout.picSize;
    NSArray *pics = isRetweet ? self.layout.status.retweetedStatus.pictures : self.layout.status.pictures;
    int picsCount = (int)pics.count;
    
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = self.picViews[i];
        if (i >= picsCount) {
            imageView.hidden = YES;
        } else {
            CGPoint origin = {0};
            switch (picsCount) {
                case 1: {
                    origin.x = kWBCellPadding;
                    origin.y = imageTop;
                } break;
                case 4: {
                    origin.x = kWBCellPadding + (i % 2) * (picSize.width + kWBCellPaddingPic);
                    origin.y = imageTop + (int)(i / 2) * (picSize.height + kWBCellPaddingPic);
                } break;
                default: {
                    origin.x = kWBCellPadding + (i % 3) * (picSize.width + kWBCellPaddingPic);
                    origin.y = imageTop + (int)(i / 3) * (picSize.height + kWBCellPaddingPic);
                } break;
            }
            imageView.frame = (CGRect){.origin = origin, .size = picSize};
            imageView.hidden = NO;
            WBPicture *pic = pics[i];
            
            __weak typeof(imageView) weakImageView = imageView;
            
            [imageView hx_setImageWithURL:pic.bmiddlePicUrl placeHolder:nil completion:^(UIImage * _Nullable image, NSURL *url) {
                int width = image.size.width;
                int height = image.size.height;
                CGFloat scale = (height / width) / (weakImageView.height / weakImageView.width);
                if (scale < 0.99 || isnan(scale)) { // 宽图把左右两边裁掉
                    weakImageView.contentMode = UIViewContentModeScaleAspectFill;
                    weakImageView.layer.contentsRect = CGRectMake(0, 0, 1, 1);
                } else { // 高图只保留顶部
                    weakImageView.contentMode = UIViewContentModeScaleToFill;
                    weakImageView.layer.contentsRect = CGRectMake(0, 0, 1, (float)width / height);
                }
                weakImageView.image = image;
            }];
        }
    }
}

- (void)hideImageViews {
    for (UIImageView *imageView in _picViews) {
        imageView.hidden = YES;
    }
}
#pragma mark - event response
- (void)didClickImage:(UITapGestureRecognizer *)sender{
    if ([self.cell.delegate respondsToSelector:@selector(cell:didClickImageAtIndex:)]) {
        [self.cell.delegate cell:self.cell didClickImageAtIndex:sender.tag.integerValue];
    }
}

#pragma mark - override method
// 截获图片的点击事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIImageView *imageView in self.picViews) {
        if (point.x - imageView.centerX < imageView.width/2.0 && point.y - imageView.centerY < imageView.height/2.0) {
            return imageView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end

@implementation WBHomePageTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.statusView = [[WBHomePageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0)];
        self.statusView.cell = self;
        self.statusView.profileView.cell = self;
        self.statusView.toolbarView.cell = self;
        [self.contentView addSubview:self.statusView];
    }
    return self;
}

- (void)setLayout:(WBHomePageLayout *)layout{
    self.height = layout.height;
    self.contentView.height = layout.height;
    self.statusView.layout = layout;
}

@end

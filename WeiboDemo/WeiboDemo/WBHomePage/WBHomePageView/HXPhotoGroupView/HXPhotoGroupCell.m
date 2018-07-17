//
//  HXPhotoGroupCell.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/11.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXPhotoGroupCell.h"
#import "UIView+HXAdd.h"
#import "UIImageView+HXNetWorking.h"

@interface HXPhotoGroupCell()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, readwrite) BOOL itemDidLoad;
@end

@implementation HXPhotoGroupCell

#pragma mark - life cycle
- (instancetype)init {
    self = super.init;
    if (!self) return nil;
    self.delegate = self;
    self.bouncesZoom = YES;
    self.maximumZoomScale = 3;
    self.multipleTouchEnabled = YES;
    self.alwaysBounceVertical = NO;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.frame = [UIScreen mainScreen].bounds;
    
    
    [self addSubview:self.imageContainerView];
    [self.imageContainerView addSubview:self.imageView];
    
    return self;
}


#pragma mark - public method
- (void)resizeSubviewSize {
    self.imageContainerView.origin = CGPointZero;
    self.imageContainerView.width = self.width;
    
    UIImage *image = self.imageView.image;
    
    // 等比进行缩放
    if (image.size.height / image.size.width > self.height / self.width) {
        self.imageContainerView.height = floor(image.size.height / (image.size.width / self.width));
    } else {
        CGFloat height = image.size.height / image.size.width * self.width;
        if (height < 1 || isnan(height)){
           height = self.height;
        }
        
        height = floor(height);
        self.imageContainerView.height = height;
        self.imageContainerView.centerY = self.height / 2;
    }
    
    if (self.imageContainerView.height > self.height && self.imageContainerView.height - self.height <= 1) {
        self.imageContainerView.height = self.height;
    }
    
    self.contentSize = CGSizeMake(self.width, MAX(self.imageContainerView.height, self.height));
    [self scrollRectToVisible:self.bounds animated:NO];
    
    if (self.imageContainerView.height <= self.height) {
        self.alwaysBounceVertical = NO;
    } else {
        self.alwaysBounceVertical = YES;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.imageView.frame = self.imageContainerView.bounds;
    [CATransaction commit];
}

- (void)scrollToTopWithAnimated:(BOOL)animated{
    CGPoint off = self.contentOffset;
    off.y = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark - getter & setter
- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
    }
    return _imageView;
}


- (UIView *)imageContainerView{
    if (!_imageContainerView) {
        _imageContainerView = [UIView new];
        _imageContainerView.clipsToBounds = YES;
    }
    return _imageContainerView;
}

- (UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.size = CGSizeMake(80, 80);
        _indicator.center = CGPointMake(self.width / 2, self.height / 2);
        _indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
        _indicator.clipsToBounds = YES;
        _indicator.layer.cornerRadius = 6;
        _indicator.hidesWhenStopped = YES;
    }
    return _indicator;
}


- (void)setItem:(HXPhotoGroupItem *)item {
    if (_item == item) {
        return;
    }else if(!item){
        self.imageView.image = nil;
        return;
    }
    
    
    _item = item;
    self.itemDidLoad = NO;
    
    [self setZoomScale:1.0 animated:NO];
    self.maximumZoomScale = 1;
    
    [self.imageView cancelCurrentImageRequest];
    // 菊花圈转
    [self.indicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    [self.imageView hx_setImageWithURL:self.item.largeImageURL placeHolder:self.item.thumbImage completion:^(UIImage * _Nullable image, NSURL *url) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        [strongSelf.indicator stopAnimating];
        strongSelf.maximumZoomScale = 3;
        if (image) {
            strongSelf.itemDidLoad = YES;
            [strongSelf resizeSubviewSize];
        }
        strongSelf.imageView.image = image;
    }];
    
    [self resizeSubviewSize];
}


@end

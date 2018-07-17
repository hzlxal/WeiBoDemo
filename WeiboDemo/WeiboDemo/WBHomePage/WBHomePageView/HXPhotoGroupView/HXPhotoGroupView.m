//
//  HXPhotoGroupView.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "HXPhotoGroupView.h"
#import "UIImageView+HXNetWorking.h"
#import "UIView+HXAdd.h"
#import "UIImage+HXAdd.h"

@interface HXPhotoGroupView() <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy, readwrite) NSArray<HXPhotoGroupItem *> *groupItems;
@property (nonatomic, assign, readwrite) NSInteger currentPage;

@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toContainerView;

@property (nonatomic, strong) UIImageView *blurBackground;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *cells;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, assign) CGFloat pagerCurrentPage;

@property (nonatomic, assign) NSInteger fromItemIndex;
@property (nonatomic, assign) BOOL isPresented;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;
@end

@implementation HXPhotoGroupView

#pragma mark - life cycle
- (instancetype)initWithGroupItems:(NSArray *)groupItems {
    self = [super init];
    
    if (self) {
        self.groupItems = groupItems;
        self.backgroundColor = [UIColor clearColor];
        self.frame = [UIScreen mainScreen].bounds;
        self.clipsToBounds = YES;
        
        [self addGesture];
        [self addSubview:self.blurBackground];
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.scrollView];
        [self.contentView addSubview:self.pager];
        
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav setNavigationBarHidden:YES];
    }
    
    return self;
}

#pragma mark - public method
- (void)presentFromImageView:(UIView *)fromView toContainer:(UIView *)toContainer animated:(BOOL)animated completion:(void (^)(void))completion {
    
    self.fromView = fromView;
    self.toContainerView = toContainer;
    
    NSInteger page = -1;
    for (NSUInteger i = 0; i < self.groupItems.count; i++) {
        if (fromView == self.groupItems[i].thumbView) {
            page = (int)i;
            break;
        }
    }
    if (page == -1) page = 0;
    self.fromItemIndex = page;
    
    self.blurBackground.image = [UIImage imageWithColor:[UIColor blackColor]];
    
    self.size = _toContainerView.size;
    self.blurBackground.alpha = 0;
    self.pager.alpha = 0;
    self.pager.numberOfPages = self.groupItems.count;
    self.pager.currentPage = page;
    [_toContainerView addSubview:self];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.width * self.groupItems.count, _scrollView.height);
    [_scrollView scrollRectToVisible:CGRectMake(_scrollView.width * _pager.currentPage, 0, _scrollView.width, _scrollView.height) animated:NO];
    [self scrollViewDidScroll:_scrollView];
    
    [UIView setAnimationsEnabled:YES];
    
    HXPhotoGroupCell *cell = [self cellForPage:self.currentPage];
    HXPhotoGroupItem *item = self.groupItems[self.currentPage];
    
    if (!cell.item) {
        cell.imageView.image = item.thumbImage;
        [cell resizeSubviewSize];
    }
    
    if (item.thumbClippedToTop) {
        CGRect fromFrame = [self.fromView convertRect:self.fromView.bounds toView:cell];
        CGRect originFrame = cell.imageContainerView.frame;
        CGFloat scale = fromFrame.size.width / cell.imageContainerView.width;
        
        cell.imageContainerView.centerX = CGRectGetMidX(fromFrame);
        cell.imageContainerView.height = fromFrame.size.height / scale;
        cell.imageContainerView.centerY = CGRectGetMidY(fromFrame);
        
        float aniTime = animated ? 0.25 : 0;
        [UIView animateWithDuration:aniTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blurBackground.alpha = 1;
        }completion:NULL];
        
        self.scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:aniTime delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageContainerView.frame = originFrame;
            self.pager.alpha = 1;
        }completion:^(BOOL finished) {
            self.isPresented = YES;
            [self scrollViewDidScroll:self.scrollView];
            self.scrollView.userInteractionEnabled = YES;
            [self hidePager];
            if (completion) completion();
        }];
        
    } else {
        CGRect fromFrame = [self.fromView convertRect:_fromView.bounds toView:cell.imageContainerView];
        
        cell.imageContainerView.clipsToBounds = NO;
        cell.imageView.frame = fromFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        float aniTime = animated ? 0.18 : 0;
        [UIView animateWithDuration:aniTime*2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            self.blurBackground.alpha = 1;
        }completion:NULL];
        
        self.scrollView.userInteractionEnabled = NO;
        [UIView animateWithDuration:aniTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
            cell.imageView.frame = cell.imageContainerView.bounds;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:aniTime delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                self.pager.alpha = 1;
            }completion:^(BOOL finished) {
                cell.imageContainerView.clipsToBounds = YES;
                self.isPresented = YES;
                [self scrollViewDidScroll:self.scrollView];
                self.scrollView.userInteractionEnabled = YES;
                [self hidePager];
                if (completion) completion();
            }];
        }];
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [UIView setAnimationsEnabled:YES];
    
    NSInteger currentPage = self.currentPage;
    HXPhotoGroupCell *cell = [self cellForPage:currentPage];
    HXPhotoGroupItem *item = _groupItems[currentPage];
    
    UIView *fromView = nil;
    if (self.fromItemIndex == currentPage) {
        fromView = self.fromView;
    } else {
        fromView = item.thumbView;
    }
    
    [self cancelAllImageLoad];
    _isPresented = NO;
    BOOL isFromImageClipped = fromView.layer.contentsRect.size.height < 1;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (isFromImageClipped) {
        CGRect frame = cell.imageContainerView.frame;
        cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0);
        cell.imageContainerView.frame = frame;
    }
    [CATransaction commit];
    
    
    if (fromView == nil) {
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            self.scrollView.alpha = 0;
            self.pager.alpha = 0;
            self.blurBackground.alpha = 0;
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self cancelAllImageLoad];
            if (completion) completion();
        }];
        return;
    }
    
    if (isFromImageClipped) {
        [cell scrollToTopWithAnimated:NO];
    }
    
    [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0.0;
        self.blurBackground.alpha = 0.0;
        if (isFromImageClipped) {
            
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell];
            CGFloat height = fromFrame.size.height / fromFrame.size.width * cell.imageContainerView.width;
            if (isnan(height)) height = cell.imageContainerView.height;
            
            cell.imageContainerView.height = height;
            cell.imageContainerView.center = CGPointMake(CGRectGetMidX(fromFrame), CGRectGetMinY(fromFrame));
        } else {
            CGRect fromFrame = [fromView convertRect:fromView.bounds toView:cell.imageContainerView];
            cell.imageContainerView.clipsToBounds = NO;
            cell.imageView.contentMode = fromView.contentMode;
            cell.imageView.frame = fromFrame;
        }
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:animated ? 0.15 : 0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            cell.imageContainerView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self removeFromSuperview];
            if (completion) completion();
        }];
    }];
    
    
}


#pragma mark - private method
- (void)addGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [self addGestureRecognizer:tap2];

    
    [self addGestureRecognizer:self.panGesture];
}

- (void)dismiss {
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [nav setNavigationBarHidden:NO];
    [self dismissAnimated:NO completion:nil];
}


#pragma mark - private method
- (void)cancelAllImageLoad {
    [self.cells enumerateObjectsUsingBlock:^(HXPhotoGroupCell *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        [cell.imageView cancelCurrentImageRequest];
    }];
}

- (void)hidePager {
    [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut animations:^{
        self.pager.alpha = 0;
    }completion:^(BOOL finish) {
    }];
}

- (void)updateCellsForReuse {
    for (HXPhotoGroupCell *cell in _cells) {
        if (cell.superview) {
            if (cell.left > self.scrollView.contentOffset.x + _scrollView.width * 2||
                cell.right < self.scrollView.contentOffset.x - _scrollView.width) {
                [cell removeFromSuperview];
                cell.page = -1;
                cell.item = nil;
            }
        }
    }
}

- (HXPhotoGroupCell *)dequeueReusableCell {
    HXPhotoGroupCell *cell = nil;
    for (cell in _cells) {
        if (!cell.superview) {
            return cell;
        }
    }
    
    cell = [[HXPhotoGroupCell alloc] init];
    cell.frame = self.bounds;
    cell.imageContainerView.frame = self.bounds;
    cell.imageView.frame = cell.bounds;
    cell.page = -1;
    cell.item = nil;
    [self.cells addObject:cell];
    return cell;
}

- (HXPhotoGroupCell *)cellForPage:(NSInteger)page {
    for (HXPhotoGroupCell *cell in self.cells) {
        if (cell.page == page) {
            return cell;
        }
    }
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCellsForReuse];
    
    CGFloat floatPage = self.scrollView.contentOffset.x / _scrollView.width;
    NSInteger page = self.scrollView.contentOffset.x / _scrollView.width + 0.5;
    
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i >= 0 && i < self.groupItems.count) {
            HXPhotoGroupCell *cell = [self cellForPage:i];
            if (!cell) {
                HXPhotoGroupCell *cell = [self dequeueReusableCell];
                cell.page = i;
                cell.left = (self.width + 20) * i + 20 / 2;
                
                if (self.isPresented) {
                    cell.item = self.groupItems[i];
                }
                [self.scrollView addSubview:cell];
            } else {
                if (self.isPresented && !cell.item) {
                    cell.item = self.groupItems[i];
                }
            }
        }
    }
    
    NSInteger intPage = floatPage + 0.5;
    intPage = intPage < 0 ? 0 : intPage >= _groupItems.count ? (int)_groupItems.count - 1 : intPage;
    self.pager.currentPage = intPage;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
        self.pager.alpha = 1;
    }completion:^(BOOL finish) {
    }];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self hidePager];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self hidePager];
}



#pragma mark - event response
- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (!_isPresented) return;
    HXPhotoGroupCell *tile = [self cellForPage:self.currentPage];
    if (tile) {
        if (tile.zoomScale > 1) {
            [tile setZoomScale:1 animated:YES];
        } else {
            CGPoint touchPoint = [g locationInView:tile.imageView];
            CGFloat newZoomScale = tile.maximumZoomScale;
            CGFloat xsize = self.width / newZoomScale;
            CGFloat ysize = self.height / newZoomScale;
            [tile zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)g {
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.isPresented) {
                self.panGestureBeginPoint = [g locationInView:self];
            } else {
                self.panGestureBeginPoint = CGPointZero;
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            if (self.panGestureBeginPoint.x == 0 && self.panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - self.panGestureBeginPoint.y;
            self.scrollView.top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                self.blurBackground.alpha = alpha;
                self.pager.alpha = alpha;
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (self.panGestureBeginPoint.x == 0 && self.panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - self.panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {
                [self cancelAllImageLoad];
                self.isPresented = NO;
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? self.scrollView.bottom : self.height - self.scrollView.top) / vy;
                duration *= 0.8;

                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self->_blurBackground.alpha = 0;
                    self->_pager.alpha = 0;
                    if (moveToTop) {
                        self.scrollView.bottom = 0;
                    } else {
                        self.scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    [self removeFromSuperview];
                }];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    self.scrollView.top = 0;
                    self.blurBackground.alpha = 1;
                    self.pager.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            self.scrollView.top = 0;
            self.blurBackground.alpha = 1;
        }
        default:break;
    }
}

#pragma mark - getter & setter
- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture =  [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    }
    return _panGesture;
}

- (NSMutableArray *)cells{
    if (!_cells) {
        _cells = [[NSMutableArray alloc] init];
    }
    return _cells;
}

- (UIImageView *)blurBackground{
    if (!_blurBackground) {
        _blurBackground = [[UIImageView alloc] init];
        _blurBackground.frame = self.bounds;
        _blurBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _blurBackground;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _contentView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(-20 / 2, 0, self.width + 20, self.height);
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = self.groupItems.count > 1;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
        _scrollView.canCancelContentTouches = YES;
    }
    return _scrollView;
}

- (UIPageControl *)pager{
    if (!_pager) {
        _pager = [[UIPageControl alloc] init];
        _pager.hidesForSinglePage = YES;
        _pager.userInteractionEnabled = NO;
        _pager.width = self.width - 36;
        _pager.height = 10;
        _pager.center = CGPointMake(self.width / 2, self.height - 18);
        _pager.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
    }
    return _pager;
}

- (NSInteger)currentPage {
    NSInteger page = self.scrollView.contentOffset.x / self.scrollView.width + 0.5;
    if (page >= self.groupItems.count){
        page = (NSInteger)self.groupItems.count - 1;
    }
    if (page < 0){
        page = 0;
    }
    return page;
}

@end


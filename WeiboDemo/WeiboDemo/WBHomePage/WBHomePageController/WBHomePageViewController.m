//
//  WBHomePageViewController.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/9.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBHomePageViewController.h"
#import "WBHomePageTableViewCell.h"
#import "WBHomePageLayout.h"
#import "WBBaseTableView.h"
#import "WBHomePageAPIManager.h"
#import "UIView+HXAdd.h"
#import "HXPhotoGroupView.h"


@interface WBHomePageViewController ()<UITableViewDelegate, UITableViewDataSource, HXAPIManagerDelegate, HXAPIManagerDataSource, WBHomePageTableViewCellDelegate>

@property (nonatomic, strong) WBBaseTableView *tableView;
@property (nonatomic, strong) NSMutableArray<WBHomePageLayout *> *layouts;
@property (nonatomic, strong) WBHomePageAPIManager *manager;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WBHomePageViewController{ 
    NSString *_accessToken;
}

- (instancetype)initWithAccessToke:(NSString *)accessToken{
    self = [super init];
    if (self) {
      _accessToken = accessToken;
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kWBCellBackgroundColor;
    self.title = @"微博";
    
    [self.manager loadData];
    [self.indicator startAnimating];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.indicator];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.layouts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *const kHXHomePageCell = @"kHXHomePageCell";
    WBHomePageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHXHomePageCell];
    if (!cell) {
        cell = [[WBHomePageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHXHomePageCell];
        cell.delegate = self;
    }
    [cell setLayout:self.layouts[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.layouts[indexPath.row].height;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - HXAPIManagerDelegate & HXAPIManagerDataSource
- (NSDictionary *)paramsForAPIManager:(HXPageAPIManager *)manager{
    return @{@"access_token":@"2.00aARVBHIdNYwCdd96f21f5dXaJN4E"};
}

- (void)apiManager:(HXBaseAPIManager *)apiManager loadDataFail:(HXURLResponseError *)error{
    NSLog(@"[%@]:<%s> %@",NSStringFromClass([self class]),__func__,error);
}

- (void)apiManagerLoadDataSuccess:(WBHomePageAPIManager *)manager{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        WBModel *items = [manager fetchDataWithModel:[WBModel class]];
        for (WBStatusModel *status in items.statuses) {
            WBHomePageLayout *layout = [[WBHomePageLayout alloc] initWithWBStatus:status];
            [self.layouts addObject:layout];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            [self.tableView reloadData];
        });
        
    });
}

#pragma mark - WBHomePageTableViewCellDelegate
- (void)cell:(WBHomePageTableViewCell *)cell didClickImageAtIndex:(NSUInteger)index{
    UIView *fromView = nil;
    NSMutableArray *items = [NSMutableArray new];
    WBStatusModel *status = cell.statusView.layout.status;
    NSArray<WBPicture *> *pics = status.retweetedStatus ? status.retweetedStatus.pictures : status.pictures;
    
    for (NSUInteger i = 0, max = pics.count; i < max; i++) {
        UIView *imgView = cell.statusView.picViews[i];
        WBPicture *pic = pics[i];
        HXPhotoGroupItem *item = [[HXPhotoGroupItem alloc] init];
        item.thumbView = imgView;
        item.largeImageURL = pic.originalPicUrl;
        [items addObject:item];
        if (i == index) {
            fromView = imgView;
        }
    }
    
    HXPhotoGroupView *v = [[HXPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromView toContainer:self.view animated:YES completion:nil];
}

#pragma mark - getter & setter
- (WBBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[WBBaseTableView alloc] initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

- (UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.size = CGSizeMake(80, 80);
        _indicator.center = CGPointMake(self.view.width / 2, self.view.height / 2);
        _indicator.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
        _indicator.clipsToBounds = YES;
        _indicator.layer.cornerRadius = 6;
        _indicator.hidesWhenStopped = YES;
    }
    return _indicator;
}

- (WBHomePageAPIManager *)manager{
    if (!_manager) {
        _manager = [[WBHomePageAPIManager alloc] initWithPageSize:50 startPage:1];
        _manager.delegate = self;
        _manager.dataSource = self;
    }
    return _manager;
}

- (NSMutableArray *)layouts{
    if (!_layouts) {
        _layouts = [[NSMutableArray alloc] init];
    }
    return _layouts;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

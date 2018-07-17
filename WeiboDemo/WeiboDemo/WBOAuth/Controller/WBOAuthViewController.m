//
//  WBOAuthViewController.m
//  WeiboDemo
//
//  Created by hzl on 2018/7/10.
//  Copyright © 2018年 hzl. All rights reserved.
//

#import "WBOAuthViewController.h"
#import "WBOAuthAPIManager.h"
#import "WBAccount.h"
#import "WBAccountTool.h"
#import "WBHomePageViewController.h"

NSString *const kHXAuthorizeUlr = @"https://api.weibo.com/oauth2/authorize";
NSString *const kHXClientId = @"2697448702";
NSString *const kHXRedirectUrl = @"https://www.baidu.com";
NSString *const kHXClientSecret = @"9f3f8d35148c09deece153287fbdc3ac";

@interface WBOAuthViewController ()<UIWebViewDelegate, HXAPIManagerDelegate, HXAPIManagerDataSource>

@property (nonatomic, strong) WBOAuthAPIManager *manager;

@end

@implementation WBOAuthViewController{
    NSString *_code;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIWebView *webView = [[UIWebView alloc]init];
    webView.delegate = self;
    webView.frame = self.view.bounds;
    [self.view addSubview:webView];
    
    [webView loadRequest:[self generateRequest]];
}

#pragma mark - override method
- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //获得Url
    NSString *url = request.URL.absoluteString;
    
    //判断是否为回调地址
    NSRange range = [url rangeOfString:@"code="];
    
    if (range.length != 0) {
        //截取code=后面的参数
        int fromIndex = (int)(range.location + range.length);
        _code = [url substringFromIndex:fromIndex];
        
        [self.manager loadData];
        //禁止加载回调页面
        return NO;
    }
    
    return YES;
}

#pragma mark - HXAPIManagerDelegate & HXAPIManagerDataSource
- (void)apiManager:(HXBaseAPIManager *)apiManager loadDataFail:(HXURLResponseError *)error{
    NSLog(@"[%@]:<%s>:%@",NSStringFromClass([self class]),__func__,error);
}

- (void)apiManagerLoadDataSuccess:(HXBaseAPIManager *)manager{
    // 将返回的账号字典数据 --> 模型，存进沙盒
    WBAccount *account = [manager fetchDataWithModel:[WBAccount class]];
    //储存账号信息
    [WBAccountTool saveAccount:account];
    
    [self switchRootViewControllerWithAccount:account];
    
}

- (NSDictionary *)paramsForAPIManager:(HXBaseAPIManager *)manager{
    return @{@"client_id":kHXClientId,
             @"client_secret":kHXClientSecret,
             @"grant_type":@"authorization_code",
             @"redirect_uri":kHXRedirectUrl,
             @"code": _code
             };
}

#pragma mark - private method
- (NSURLRequest *)generateRequest{
    NSString *urlStr = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@",kHXAuthorizeUlr,kHXClientId,kHXRedirectUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

- (void)switchRootViewControllerWithAccount:(WBAccount *)account{
    WBHomePageViewController *wbVC = [[WBHomePageViewController alloc] initWithAccessToke:account.accessToken];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:wbVC];
    
    // 切换窗口的根控制器
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    window.rootViewController = nav;
}

#pragma mark - getter & setter
- (WBOAuthAPIManager *)manager{
    if (!_manager) {
        _manager = [[WBOAuthAPIManager alloc] init];
        _manager.delegate = self;
        _manager.dataSource = self;
    }
    return _manager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

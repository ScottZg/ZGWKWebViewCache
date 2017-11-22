//
//  ViewController.m
//  ZGWKWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "ZGWKWebViewCache.h"
@interface ViewController ()
@property (strong, nonatomic) WKWebView *myWKWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZGWKWebViewCache registerSchemeCache];    //在需要缓存的页面注册scheme
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://172.16.10.35:3333/src/p/about/index.html"]];
    [self.myWKWebView loadRequest:request];
}


- (WKWebView *)myWKWebView {
    if (!_myWKWebView) {
        _myWKWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:_myWKWebView];
    }
    return _myWKWebView;
}


@end

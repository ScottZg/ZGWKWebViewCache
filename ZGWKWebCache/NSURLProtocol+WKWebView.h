//
//  NSURLProtocol+WKWebView.h
//  ZGWKWebViewCache
//
//  Created by zhanggui on 2017/11/22.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebView)


+ (void)zg_registerScheme:(NSString *)scheme;


+ (void)zg_unregisterScheme:(NSString *)scheme;
@end

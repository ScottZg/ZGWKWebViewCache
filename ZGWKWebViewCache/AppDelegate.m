//
//  AppDelegate.m
//  ZGWKWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "AppDelegate.h"
#import "ZGWKWebViewCache.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[ZGWKWebViewCache sharedWebViewCache] initWebCacheWithCacheTypes:@[@(CacheTypeJS),@(CacheTypeImage)]];
    [[ZGWKWebViewCache sharedWebViewCache] setDebugModel:YES];
    [[ZGWKWebViewCache sharedWebViewCache] clearCacheWithInvalidDays:7];
    
    return YES;
}

@end

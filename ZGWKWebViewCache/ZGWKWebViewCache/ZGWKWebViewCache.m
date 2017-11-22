//
//  ZGUIWebViewCache.m
//  ZGUIWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "ZGWKWebViewCache.h"
#import "ZGURLProtocol.h"
#import "FileUtil.h"
#import "NSURLProtocol+WKWebView.h"
NSString * const URLMIMETYPE = @"url_mime_type";


static NSString * const CacheLiveTimeKey = @"CacheLiveTimeKey";

static NSInteger  const CacheLiveDate = 7;   //cache默认缓存时间为7天，7天清理一次缓存

@interface ZGWKWebViewCache()
@property (nonatomic,assign)BOOL debug;


@property (nonatomic,strong)NSArray *cacheTypeArr;
@end

@implementation ZGWKWebViewCache

+ (instancetype)sharedWebViewCache {
    static ZGWKWebViewCache *ch = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ch = [[self alloc] init];
    });
    return ch;
}
- (NSArray *)cacheArr {
    return _cacheTypeArr;
}
- (void)initWebCacheWithCacheTypes:(NSArray *)arr {
    [NSURLProtocol registerClass:[ZGURLProtocol class]];
    _cacheTypeArr =arr;
}

- (ZGCacheModel *)getCacheDataByKey:(NSString *)cacheKey {
    ZGCacheModel *model = [ZGCacheModel new];
    
    FileUtil *util = [FileUtil shared];
   
    model.data = [util readForKey:cacheKey];
    if (model.data) {
        model.MIMEType = [self getMIMETypeFromKey:cacheKey];
    }
    return model;
}
- (void)setCacheWithKey:(NSString *)key value:(ZGCacheModel *)model {
    FileUtil *util = [FileUtil shared];
    [util write:model.data forKey:key];
}
- (void)clearZGCache {

    [[FileUtil shared] clearCacheFolder];   //清除缓存的文件
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:URLMIMETYPE];   //清除mime类型s
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:CacheLiveTimeKey];

}
- (void)clearCacheWithInvalidDays:(NSInteger)day {
    NSDate *originTime = [[NSUserDefaults standardUserDefaults] objectForKey:CacheLiveTimeKey];  //存取当前时间
    if (!originTime) {
        originTime = [self beijingTime];
        [[NSUserDefaults standardUserDefaults] setObject:originTime forKey:CacheLiveTimeKey];
    }
    if (day<=0) {
        day = CacheLiveDate;
    }
    NSDate *sevenTime = [originTime dateByAddingTimeInterval:24*60*60*day];
    
    NSDate *currentDateTime = [self beijingTime];
    NSComparisonResult  result = [currentDateTime compare:sevenTime];
    
    if (result == NSOrderedDescending) {   //时间超过设定的时间
        [self clearZGCache];
    }
}
- (void)setDebugModel:(BOOL)boo {

    FileUtil *util = [FileUtil shared];
    util.debug = boo;
    _debug = boo;
    
}
+ (void)registerSchemeCache {
    [NSURLProtocol zg_registerScheme:@"http"];
    [NSURLProtocol zg_registerScheme:@"https"];
}
+ (void)unRegisterSchemeCache {
    [NSURLProtocol zg_unregisterScheme:@"http"];
    [NSURLProtocol zg_unregisterScheme:@"https"];
}
#pragma mark - private method
//拿到当前北京时间
- (NSDate *)beijingTime {
    NSDate *date = [NSDate date];
    NSTimeInterval inter = [[NSTimeZone systemTimeZone] secondsFromGMT];
    return  [date dateByAddingTimeInterval:inter];
}
/**
 得到MIME类型

 @param cacheKey 缓存key
 @return MIME类型
 */
- (NSString *)getMIMETypeFromKey:(NSString *)cacheKey {
    NSURL *url = [NSURL URLWithString:cacheKey];
    NSString *keyValue = [url path];
    
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:URLMIMETYPE];
    NSString *mimeType = [dic objectForKey:keyValue];
    
    if (mimeType) {
        return mimeType;
    }
    return nil;
}

@end

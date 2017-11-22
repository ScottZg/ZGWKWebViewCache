//
//  ZGUIWebViewCache.h
//  ZGUIWebViewCache
//使用过程中只需要关注该类即可，其他类无需关注
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZGCacheModel.h"

extern NSString *const URLMIMETYPE;


typedef NS_ENUM(NSInteger,CacheType) {
    CacheTypeImage = 4,
    CacheTypeJS,
    CacheTypeCSS,
    CacheTypeHTML
};
@interface ZGWKWebViewCache : NSObject


/**
 初始化web cache该方法可以直接在application:didFinishLaunchingWithOptions中调用
 @param arr 缓存类型,CacheType
 */
- (void)initWebCacheWithCacheTypes:(NSArray *)arr;





+(instancetype)sharedWebViewCache;


- (instancetype)init NS_UNAVAILABLE;



/**
 注册cache
 */
+ (void)registerSchemeCache;

/**
 不注册cache
 */
+ (void)unRegisterSchemeCache;

/**
 得到缓存的数据

 @param cacheKey 缓存key
 @return 返回缓存model
 */
- (ZGCacheModel *)getCacheDataByKey:(NSString *)cacheKey;

/**
 设置离线缓存，根据需求缓存，如果你的js有版本号，那么如有更新，缓存key便会和原有key不一致，达到更新效果。如果相同的链接内容更改则无法实现即时更新。

 @param key 缓存key
 @param model 缓存model
 */
- (void)setCacheWithKey:(NSString *)key value:(ZGCacheModel *)model;


/**
 清除缓存,自己在合适的地方调用，比如清除缓存按钮点击
 */
- (void)clearZGCache;

- (NSArray *)cacheArr;
/**
 清除缓存

 @param day 天数，例如7天，7天后会自动清除所有缓存,该方法可以直接在application:didFinishLaunchingWithOptions中调用
 */
- (void)clearCacheWithInvalidDays:(NSInteger)day;


/**
 设置debug模式，是否打印日志，默认为NO，上线请设置为NO

 @param boo YES表示开启debug模式，NO表示关闭debugM模式
 */
- (void)setDebugModel:(BOOL)boo;

@end

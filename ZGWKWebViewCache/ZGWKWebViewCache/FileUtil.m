//
//  FileUtil.m
//  RongShu
//
//  Created by zhanggui on 2017/11/9.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "FileUtil.h"

#import "NSString+ZGExtension.h"
static inline NSString * RSFileCacheDirectory() {
    static NSString * _fileDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileDic  = NSSearchPathForDirectoriesInDomains( NSCachesDirectory, NSUserDomainMask, YES )[0];
    });
    return _fileDic;
}

static inline NSString *cachePathForKey(NSString *key) {
    NSString *fileName = [NSString SHA1FromString:key];
    NSString *filePath = [RSFileCacheDirectory() stringByAppendingString:@"/ZGWebCaches"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
}
@interface FileUtil ()

@property (nonatomic,strong)NSCache *cache;



@property (nonatomic,strong)dispatch_queue_t zgQueue;
@end



@implementation FileUtil


+ (instancetype)shared {
    static FileUtil *util = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[self alloc] init];
    });
    return util;
}
- (id)init {
    self = [super init];
    if (self) {
        _debug = true;
    }
    return self;
}
- (void)clearCacheFolder {
    NSString *cacheFolder = [RSFileCacheDirectory() stringByAppendingString:@"/RSWebCaches"];
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:cacheFolder error:&error];
    if (error || !contents || contents.count<=0) {
        return;
    }
    for (NSString *fileName in contents) {
        NSString *path = [NSString stringWithFormat:@"/%@",fileName];
        NSString *filePath = [cacheFolder stringByAppendingString:path];
       BOOL bo =  [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (bo) {
            NSString *str = [NSString stringWithFormat:@"移除%@成功",filePath];
            [self ZGLog:str];
        }
    }
    
}
//内存 -> 文件系统
- (NSData *)readForKey:(NSString *)key {
    if (!key) {
        return nil;
    }
    NSData *cacheData = [self.cache objectForKey:key];
    if (cacheData) {
         NSString *str = [NSString stringWithFormat:@"从cache中读取%@",key];
        [self ZGLog:str];
        return cacheData;
    }else {
        NSString *str = [NSString stringWithFormat:@"从cache无法读取，从文件读取从cache中读取%@",key];
        [self ZGLog:str];
        NSString *filePath = cachePathForKey(key);
        NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
        if (fileData) {
            [self.cache setObject:fileData forKey:key];
        }
        return fileData;
    }
    return nil;
}
- (void)write:(NSData *)data forKey:(NSString *)key {
    NSString *filePath = cachePathForKey(key);
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    [self.cache setObject:data forKey:key];
    dispatch_async(self.zgQueue, ^{
        BOOL boo =  [[NSFileManager defaultManager] createFileAtPath:fileUrl.path contents:data attributes:nil];
        if (boo) {
            NSString *str = [NSString stringWithFormat:@"创建%@成功",filePath];
            [self ZGLog:str];
            
        }else {
            NSString *str = [NSString stringWithFormat:@"创建%@失败",filePath];
            [self ZGLog:str];
        }
    });
}
- (void)ZGLog:(NSString *)str {
    if (_debug) {
        NSLog(@"%@", str);
    }
}
- (dispatch_queue_t)zgQueue {
    if (!_zgQueue) {
        _zgQueue = dispatch_queue_create("com.zgCache.zgCache", DISPATCH_QUEUE_CONCURRENT);
    }
    return _zgQueue;
}
- (NSCache *)cache {
    if (!_cache) {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}
@end

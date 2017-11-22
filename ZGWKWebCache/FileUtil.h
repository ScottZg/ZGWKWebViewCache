//
//  FileUtil.h
//  RongShu
//
//  Created by zhanggui on 2017/11/9.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject


@property (nonatomic,assign)BOOL debug;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)shared;


- (void)write:(NSData *)data forKey:(NSString *)key;



-(NSData *)readForKey:(NSString *)key;



- (void)clearCacheFolder;
@end

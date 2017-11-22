//
//  ZGCacheModel.h
//  ZGUIWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGCacheModel : NSObject

/**
 mime 类型
 */
@property (nonatomic,strong)NSString *MIMEType;


/**
 缓存数据
 */
@property (nonatomic,strong)NSData *data;
@end

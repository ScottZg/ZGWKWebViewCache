//
//  NSString+Extension.h
//  ZGUIWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZGExtension)

/**
 SHA1

 @param string 要sha1的string
 @return 返回sha1后的str
 */
+ (NSString *)SHA1FromString:(NSString *)string;
@end

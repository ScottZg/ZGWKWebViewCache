//
//  NSString+Extension.m
//  ZGUIWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "NSString+ZGExtension.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (ZGExtension)

#pragma mark - Hash methods
+ (NSString *)SHA1FromString:(NSString *)string {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    
    NSData *stringBytes = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (CC_SHA1([stringBytes bytes], (CC_LONG)[stringBytes length], digest)) {
        
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        
        for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    }
    return nil;
}
@end

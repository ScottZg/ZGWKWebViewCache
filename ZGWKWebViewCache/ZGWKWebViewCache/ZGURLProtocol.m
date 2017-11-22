//
//  ZGURLProtocol.m
//  ZGUIWebViewCache
//
//  Created by zhanggui on 2017/11/20.
//  Copyright © 2017年 zhanggui. All rights reserved.
//

#import "ZGURLProtocol.h"
#import "ZGCacheModel.h"
#import "ZGWKWebViewCache.h"
static NSString * const ZGURLProtocolKey = @"zgPKey";

@interface ZGURLProtocol()<NSURLSessionDataDelegate>

/**
 请求的数据
 */
@property (nonatomic,strong)NSMutableData *responseData;

/**
 task
 */
@property (nonatomic,strong)NSURLSessionDataTask *task;

@property (nonatomic,strong)NSString *responseMIMEType;
@end

@implementation ZGURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSString *scheme = [[request URL] scheme];
    NSLog(@"1111%@",request.URL.absoluteString);
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {  //只缓存http和https的请求
        NSString *str = request.URL.path;
        if ([self cacheTypeWithStr:str] && ![NSURLProtocol propertyForKey:ZGURLProtocolKey inRequest:request]) {
            return YES;
        }
    }
    return NO;
}
+ (BOOL)cacheTypeWithStr:(NSString *)str {
    if ([[[ZGWKWebViewCache sharedWebViewCache] cacheArr] containsObject:@(CacheTypeJS)] && [str hasSuffix:@".js"]) {
        return YES;
    }
    if ([[[ZGWKWebViewCache sharedWebViewCache] cacheArr] containsObject:@(CacheTypeImage)] && [self ifImageType:str]) {
        return YES;
    }
    if ([[[ZGWKWebViewCache sharedWebViewCache] cacheArr] containsObject:@(CacheTypeCSS)] && [str hasSuffix:@".css"]) {
        return YES;
    }
    if ([[[ZGWKWebViewCache sharedWebViewCache] cacheArr] containsObject:@(CacheTypeHTML)] && [str hasSuffix:@".html"]) {
        return YES;
    }
    return NO;
}
/**
 判断是否值js

 @param urlStr 资源地址，这里暂时只判断了一下js
 @return YES表示是js，NO表示不是js
 */
+ (BOOL)ifJSType:(NSString *)urlStr {
    if ([urlStr hasSuffix:@".js"]) {
        return YES;
    }
    return NO;
}
/**
 判断将要请求的资源是否是图片

 @param urlStr 资源地址，这里暂时只判断了一下png/jpg/gif/jpeg四种格式
 @return YES表示是图片，NO表示不是图片
 */
+ (BOOL)ifImageType:(NSString *)urlStr {
    if ([urlStr hasSuffix:@".png"] ||
        [urlStr hasSuffix:@".jpg"] ||
        [urlStr hasSuffix:@".gif"] ||
        [urlStr hasSuffix:@".jpeg"]) {
        return YES;
    }
    return NO;
}
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    //这里可以进行重定向操作，重写request，
    return request;
}
//这里请求是否的等价于缓存
+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}
//开始请求
- (void)startLoading {
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:ZGURLProtocolKey inRequest:mutableRequest];
    ZGCacheModel *model = [[ZGWKWebViewCache sharedWebViewCache] getCacheDataByKey:self.request.URL.absoluteString];
    
    if (model.data && model.MIMEType) {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:model.MIMEType expectedContentLength:model.data.length textEncodingName:nil];
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:model.data];
        [self.client URLProtocolDidFinishLoading:self];
    }else {
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        self.task = [session dataTaskWithRequest:self.request];
        [self.task resume];
    }
}
- (void)stopLoading {
    if (self.task) {
        [self.task cancel];
    }
}

#pragma mark - NSURLConnectionDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    self.responseData = [NSMutableData data];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    
    
    [[self client] URLProtocol:self didLoadData:data];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    ZGCacheModel *model = [ZGCacheModel new];
    model.data = self.responseData;
    model.MIMEType = task.response.MIMEType;
    
    [self setMiType:model.MIMEType withKey:[self.request.URL path]];//userdefault存储MIMEtype
    [[ZGWKWebViewCache sharedWebViewCache] setCacheWithKey:self.request.URL.absoluteString value:model];
    [self.client URLProtocolDidFinishLoading:self];
}
/**
 将类型和key存储到一个字典里面，然后
 
 @param mimeType mime类型
 @param urlKey url的key
 */
- (void)setMiType:(NSString *)mimeType withKey:(NSString *)urlKey {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:URLMIMETYPE];
    
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [muDic setValue:mimeType forKey:urlKey];
    [[NSUserDefaults standardUserDefaults] setObject:muDic forKey:URLMIMETYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end

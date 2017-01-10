//
//  CTBaseRequest.m
//  CTNetWork
//
//  Created by Admin on 16/5/30.
//  Copyright © 2016年 Excalibur-Tong. All rights reserved.
//

#import "CTBaseRequest.h"
#import "CTNetworkManager.h"

static NSUInteger _requestIdentifier = 0;

@interface CTBaseRequest ()

@property (nonatomic, readwrite) NSURLSessionDataTask * _Nullable sessionTask;
@property (nonatomic, strong) NSMutableDictionary * mutableRequestHTTPHeaderFields;
@property (nonatomic, copy) NSString * requestKey;

@property (nonatomic, weak) id<CTNetworkRequestDelegate> delegate;

@end

@implementation CTBaseRequest

- (void)dealloc
{
    if ([CTNetworkManager sharedManager].configuration.isDebug)
    {
        NET_LOG(@"%@ [ - delloc - ]  requestIndentifier : %ld ", NSStringFromClass(self.class), (unsigned long)self.requestIdentifier);
    }
}

- (instancetype)init
{
    if(self = [super init]){
        _requestIdentifier += 1;
        _mutableRequestHTTPHeaderFields = [[NSMutableDictionary alloc] init];
        _isCancleSendWhenExciting = NO;
        self.requestMethod = CTNetworkRequestHTTPGet;
        self.cachePolicy = CTRequestCacheNone;
    }
    return self;
}

+ (CTBaseRequest * _Nonnull)request
{
    CTBaseRequest * req = [[CTBaseRequest alloc] init];
    return req;
}

+ (CTBaseRequest * _Nonnull)requestWithInterface:(NSString * _Nonnull)interface
{
    CTBaseRequest * req = [[CTBaseRequest alloc] initWithInterface:interface];
    return req;
}

+ (CTBaseRequest * _Nonnull)requestWithInterface:(NSString * _Nonnull)interface
                                       parameter:(id _Nonnull)parameter
{
    CTBaseRequest * req = [[CTBaseRequest alloc] initWithInterface:interface];
    req.parameterDict = parameter;
    return req;
}

- (instancetype)initWithInterface:(NSString * _Nullable)interface
{
    self = [self init];
    if (self) {
        self.interface = interface;
    }
    return self;
}

- (instancetype _Nonnull)initWithInterface:(NSString * _Nullable)interface
                                 parameter:(NSDictionary * _Nullable)param
{
    return [self initWithInterface:interface parameter:param cachePolicy:CTRequestCacheNone];
}

- (instancetype _Nonnull)initWithInterface:(NSString * _Nullable)interface
                                 parameter:(NSDictionary * _Nullable)param
                               cachePolicy:(CTRequestCachePolicy)policy
{
    self = [self init];
    if (self) {
        self.interface = interface;
        self.parameterDict = param;
        self.cachePolicy = policy;
    }
    return self;
}

#pragma mark - set or get method
- (NSUInteger)requestIdentifier
{
    return _requestIdentifier;
}


- (NSString *)requestKey
{
    if (!_requestKey)
    {
        NSURL * baseUrl = [NSURL URLWithString:[CTNetworkManager sharedManager].configuration.baseURLString];
        _requestKey = CTKeyFromRequestAndBaseURL(self.parameterDict, baseUrl, self.interface);
    }
    return _requestKey;
}

- (void)start
{
    [[CTNetworkManager sharedManager] sendRequest:self];
}

#pragma mark - NSCopying method
- (id)copyWithZone:(NSZone *)zone
{
    CTBaseRequest *request = [[[self class] allocWithZone:zone] init];
    request.mutableRequestHTTPHeaderFields = [self.mutableRequestHTTPHeaderFields mutableCopy];
    return request;
}

#pragma mark - description
- (NSString *)description
{
    NSString * className = NSStringFromClass([self class]);
    NSString * desStr = [NSString stringWithFormat:@"%@ indentifier %ld \n-> interface: [-  %@  -]\n-> param:\n%@\n-> Unusual HTTPHeader:\n%@\n-> responseObj:\n%@", className,self.requestIdentifier, self.interface, self.parameterDict, self.HTTPHeaderFieldDict, self.responseObj];
    return desStr;
}

@end

@implementation CTBaseRequest (CTNetworkManager)

#pragma mark - class method

- (void)startRequestWithSuccess:(CTNetworkSuccessBlock _Nullable)successBlock
                        failure:(CTNetworkFailureBlock _Nullable)failureBlock
{
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    [[CTNetworkManager sharedManager] sendRequest:self];
}

- (void)startUploadRequestWithProgress:(CTNetworkProgressBlock _Nullable)progressBlock
                               success:(CTNetworkSuccessBlock _Nullable)successBlock
                               failure:(CTNetworkFailureBlock _Nullable)failureBlock
{
    self.successBlock = successBlock;
    self.progressBlock = progressBlock;
    self.failureBlock = failureBlock;
    [[CTNetworkManager sharedManager] sendUploadRequest:self];
}

- (void)startDownloadRequestWithProgress:(CTNetworkProgressBlock _Nullable)progressBlock
                         complectHandler:(CTNetworkDownloadBlock _Nonnull)complectBlock
{
    self.progressBlock = progressBlock;
    self.downloadBlock = complectBlock;
    [[CTNetworkManager sharedManager] sendDownloadRequest:self];
}

- (void)cancle
{
    [[CTNetworkManager sharedManager] cancelRequest:self];
}
@end


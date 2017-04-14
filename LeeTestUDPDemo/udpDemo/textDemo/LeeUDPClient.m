//
//  LeeUDPClient.m
//  textDemo
//
//  Created by MacBook on 2017/4/11.
//  Copyright © 2017年 dahua. All rights reserved.
//

#import "LeeUDPClient.h"
#import "GCDAsyncUdpSocket.h"
#define CLIENTPORT 8665
#define SERVERPORT 9600
@interface LeeUDPClient()<GCDAsyncUdpSocketDelegate>{

    AduroUDPReceiveDataBlock  _receiveDataBlock;
    AduroUDPReceiveErrorBlock _errorBlock;
    AduroUDPReceiveDataBlock  _startUDPDataBlock;
    AduroUDPReceiveErrorBlock _startUDPErrorBlock;
    
}
@property (nonatomic,strong)GCDAsyncUdpSocket * UDPClient;

@end

@implementation LeeUDPClient

+(instancetype)sharedManager{
    
    static LeeUDPClient * client = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        client = [[LeeUDPClient alloc] init];
    });
    
    return client;
    
}
-(instancetype)init{

    if (self = [super init]) {
    }
    return self;
}
-(BOOL)startUDPClientWithFeedBackBlock:(AduroUDPReceiveDataBlock)receiveDataBlock andError:(AduroUDPReceiveErrorBlock)errorBlock{

    BOOL bindResult = NO;
    NSError * error;
    [self closeUDPClient];
    if (_UDPClient == nil) {
        _startUDPErrorBlock = errorBlock;
        _startUDPDataBlock = receiveDataBlock;
        
        _UDPClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udpclient_queue", NULL)];
       bindResult =  [_UDPClient bindToPort:CLIENTPORT error:&error];
        if (error) {
            NSLog(@"bind error:::%@",error);
        }
        [_UDPClient beginReceiving:nil];
    }else{
    
        return YES;
    }
    return bindResult;
}

-(BOOL)startBroadCast{
    BOOL result = NO;
    _UDPClient = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("udpclient_queue", NULL)];
    [_UDPClient localPort];
    return result;
    
}
//关闭网络对象
-(void)closeUDPClient{
    [_UDPClient close];
    [_UDPClient close];
    _UDPClient.delegate = nil;
    _UDPClient = nil;
    self.udpIsConnect = NO;
}
-(void)sendData:(NSData*)commandData andReceiveData:(AduroUDPReceiveDataBlock)receiveDataBlock andError:(AduroUDPReceiveErrorBlock)errorBlock{

    @try {
        if (_receiveDataBlock==nil) {
            _receiveDataBlock = receiveDataBlock;
        }
        if (_errorBlock==nil) {
            _errorBlock       = errorBlock;
        }
        if (commandData.length == 0) {
            NSError * error = [NSError errorWithDomain:@"error command data" code:0 userInfo:@{@"commanddata":@"null"}];
            _errorBlock(error);
            return;
        }
        [_UDPClient sendData:commandData toHost:self.host port:self.udpPort withTimeout:20 tag:200];
        self.udpIsConnect = YES;
    } @catch (NSException *exception) {
        NSLog(@"send data error:::%@",exception);
    } @finally {
         
    }
   
}

#pragma mark udpsocket delegate;
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{

    NSLog(@"client connect to --->>>%@ and port--->>%hu",[GCDAsyncUdpSocket hostFromAddress:address],[GCDAsyncUdpSocket portFromAddress:address]);
    self.udpIsConnect = YES;

}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError * _Nullable)error{

    NSLog(@"not connect--->>>%@",error);
    if (_errorBlock) {
        _errorBlock(error);
    }
    if (_startUDPErrorBlock) {
        _startUDPErrorBlock(error);
    }
    self.udpIsConnect = YES;

}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{

    if (tag == 200) {
        NSLog(@"client发送数据");
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error{
    if (tag == 200) {
        NSLog(@"client发送失败-->%@",error);
        if (_errorBlock) {
            _errorBlock(error);
        }
        if (_startUDPErrorBlock) {
            _startUDPErrorBlock(error);
        }
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{

    NSString *receiveStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"服务器ip地址--->%@,host---%u,内容--->%@",
          [GCDAsyncUdpSocket hostFromAddress:address],
          [GCDAsyncUdpSocket portFromAddress:address],
          receiveStr);
    self.host = [GCDAsyncUdpSocket hostFromAddress:address];
    self.udpPort = [GCDAsyncUdpSocket portFromAddress:address];
    
    if (_receiveDataBlock) {
        _receiveDataBlock(data);
    }
    if (_startUDPDataBlock) {
        _startUDPDataBlock(data);
    }
    self.udpIsConnect = YES;
}



- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError  * _Nullable)error{

    NSLog(@"clientClose error--->>>%@",error);
    if (_errorBlock) {
    _errorBlock(error);
    }
    if (_startUDPErrorBlock) {
        _startUDPErrorBlock(error);
    }
    self.udpIsConnect = NO;

}


@end

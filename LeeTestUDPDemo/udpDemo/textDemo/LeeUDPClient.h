//
//  LeeUDPClient.h
//  textDemo
//
//  Created by MacBook on 2017/4/11.
//  Copyright © 2017年 dahua. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^AduroUDPReceiveDataBlock)(NSData*data);
typedef void (^AduroUDPReceiveErrorBlock)(NSError*error);
@interface LeeUDPClient : NSObject

@property(nonatomic,assign)uint16_t udpPort;
@property(nonatomic,copy)NSString  *host;
@property(nonatomic,assign)BOOL udpIsConnect;

+(instancetype)sharedManager;
-(BOOL)startUDPClientWithFeedBackBlock:(AduroUDPReceiveDataBlock)receiveDataBlock andError:(AduroUDPReceiveErrorBlock) errorBlock;
-(BOOL)startBroadCast;
-(void)sendData:(NSData*)commandData andReceiveData:(AduroUDPReceiveDataBlock) receiveDataBlock andError:(AduroUDPReceiveErrorBlock) errorBlock;
@end

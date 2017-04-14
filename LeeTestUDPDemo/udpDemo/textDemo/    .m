//
//  SendViewController.m
//  textDemo
//
//  Created by dadahua on 16/9/25.
//  Copyright © 2016年 dahua. All rights reserved.
//

#import "SendViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "NSString+GetIPAddress.h"
#import "LeeUDPClient.h"

#define CLIENTPORT 8085
#define SERVERPORT 9600

/**
 *  客户端
 */
@interface SendViewController ()<GCDAsyncUdpSocketDelegate>
{
    LeeUDPClient *_udpClient;
    __weak IBOutlet UITextField *msgTF;
    __weak IBOutlet UITextField *ipTF;
    __weak IBOutlet UILabel *receiveLab;
}

@end

@implementation SendViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"客户端";
    _udpClient = [LeeUDPClient sharedManager];
    [_udpClient startUDPClientWithFeedBackBlock:^(NSData *data) {
        NSLog(@"start udp ------>>>>data");
    } andError:^(NSError *error) {
        NSLog(@"start udp ------>>>>error");
    }];
    _udpClient.host = [NSString getCurrentLocalIP];
    
}

#pragma mark 发送消息
- (IBAction)sendMsgClick:(UIButton *)sender {

    @try {
        
        [_udpClient sendData:[msgTF.text dataUsingEncoding:NSUTF8StringEncoding] andReceiveData:^(NSData *data) {
            NSLog(@"%@",data);
            dispatch_async(dispatch_get_main_queue(), ^{
                receiveLab.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            });
            
        } andError:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
        
        
    }
   
}




@end

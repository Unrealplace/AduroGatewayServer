//
//  ViewController.m
//  textDemo
//
//  Created by dadahua on 16/9/23.
//  Copyright © 2016年 dahua. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncUdpSocket.h"
#define SERVERPORT 9600
#define CLIENTPORT 8888
#import "AduroGateway.h"
#import "NSString+GetIPAddress.h"

/**
 *  服务器端
 */
@interface ViewController ()<GCDAsyncUdpSocketDelegate>
{
    GCDAsyncUdpSocket *receiveSocket;
}
@property (weak, nonatomic) IBOutlet UILabel *textView;
@property (nonatomic,strong)AduroGateway * gateway;
@property (nonatomic,strong)NSMutableDictionary * gateDic;
@property (weak, nonatomic) IBOutlet UILabel *commandLabel;

@property (nonatomic,copy)NSString * clientHost;
@property (nonatomic,assign)uint16_t   clientPort;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    NSDictionary * dic = @{@"gatewayID":@"aabbccddeeff",@"gatewayName":@"oliverGateway",@"gatewayIPv4Address":[NSString getCurrentLocalIP]};
    self.gateDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    [self initSocket];
}

- (void)initSocket {
    
    self.title = @"服务器";
    dispatch_queue_t dQueue = dispatch_queue_create("Server queue", NULL);
    receiveSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                  delegateQueue:dQueue];
    NSError *error;
    [receiveSocket bindToPort:SERVERPORT error:&error];
    if (error) {
        NSLog(@"服务器绑定失败");
    }
    if (![receiveSocket enableBroadcast:YES error:&error]) {
        NSLog(@"Error enableBroadcast (bind): %@", error);
        return;
    }
    if (![receiveSocket joinMulticastGroup:@"224.0.0.1"  error:&error]) {
        NSLog(@"Error joinMulticastGroup (bind): %@", error);
        return;
    }
    [receiveSocket beginReceiving:nil];
    
    NSLog(@"udp servers success starting %hd", [receiveSocket localPort]);

}
- (IBAction)sendCommand:(id)sender {
    
    NSString * commandStr = [NSString stringWithFormat:@"oliver-%d",arc4random()];
    
    [receiveSocket sendData:[commandStr dataUsingEncoding:NSUTF8StringEncoding] toHost:self.clientHost port:self.clientPort withTimeout:30 tag:60];
    
    
}
- (IBAction)sendBroadCast:(id)sender {
    
//    dispatch_source_t：是一个监视某些类型事件的对象。当这些事件发生时，它自动将一个block放入一个dispatch queue的执行例程中。
//    
//    dispatch_source_set_timer：这是一个定时器的方法。
//    
//    首先把所需要的创建的对象创建：
    __block int timeout=15; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),2.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(timeout<=0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置界面的按钮显示 根据自己需求设置
            });
            
        }else{
            [self timerAction];
            timeout--;
        }
        
    });
    
    dispatch_resume(_timer);
}


-(void)timerAction{

    //在这里执行事件
    NSData * data = [NSJSONSerialization dataWithJSONObject:self.gateDic options:NSJSONWritingPrettyPrinted error:nil];
    [receiveSocket sendData:data toHost:@"255.255.255.255" port:CLIENTPORT withTimeout:30 tag:10];
}


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{

    NSLog(@"send data");
    
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{

    NSLog(@"%@",error);
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    /**
     *  更新UI一定要到主线程去操作啊
     */
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.textView.text = msg;
    });
    NSLog(@"客户端ip地址-->%@,port--->%u,内容-->%@",
          [GCDAsyncUdpSocket hostFromAddress:address],
          [GCDAsyncUdpSocket portFromAddress:address],
          msg);
    self.clientHost = [GCDAsyncUdpSocket hostFromAddress:address];
    self.clientPort = [GCDAsyncUdpSocket portFromAddress:address];
    
    
}


@end

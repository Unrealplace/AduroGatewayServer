//
//  NSString+GetIPAddress.h
//  textDemo
//
//  Created by MacBook on 2017/4/11.
//  Copyright © 2017年 dahua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GetIPAddress)

/**
 获取当前的ip地址
 */
+ (nullable NSString*)getCurrentLocalIP;

/**
 获取当前的wifi强度
 */
+ (nullable NSString *)getCurreWiFiSsid;
@end

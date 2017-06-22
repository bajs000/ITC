//
//  Util.m
//  ITC
//
//  Created by YunTu on 2017/6/22.
//  Copyright © 2017年 YunTu. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation Util

+ (NSString*) sha1:(NSString *)hashString
{
    const char *cstr = [hashString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:hashString.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end

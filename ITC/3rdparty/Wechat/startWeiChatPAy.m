//
//  startWeiChatPAy.m
//  NTFM_IOS
//
//  Created by zhiminruan on 16/8/2.
//  Copyright © 2016年 cmytc. All rights reserved.
//

#import "startWeiChatPAy.h"
//#import "NTAppConstants.h"
//#import "JSONKit.h"
//#import "HUDHelper.h"
//#import "MBProgressHUD.h"
#import <AFNetworking/AFNetworking.h>
//#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import <CommonCrypto/CommonDigest.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ITC-Swift.h"

#import "DataMD5.h"

#import "XMLDictionary.h"
#import "PrefixHeader.pch"

#pragma mark - 用于获取设备ip地址

#include <ifaddrs.h>
#include <arpa/inet.h>

#pragma mark - 产生随机字符串

@implementation startWeiChatPAy

+ (void)jumpToBizPay:(NSString *)money recharge:(BOOL)flag{
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    //    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
    //    NSString *urlString = [NSString stringWithFormat:@"%@/card/v1/weixin/pay/ask/appPay",NT_BaseUrl];//@"http://yt.dev.cmytc.com/card/v1/weixin/pay/ask/appPay";
    
    //    __weak MBProgressHUD *hud = [[HUDHelper sharedInstance] loading];
    
    [SVProgressHUD show];
    NSString *time = [NSString stringWithFormat:@"%ld",(long)[NSDate date].timeIntervalSince1970];
    NSDictionary *dic = @{@"app":@"appspay",@"act":@"wx_unifiedorder",@"out_trade_no":[NSString stringWithFormat:@"%@-%@-1-%@",@"1114",@"0",time],@"total_fee":money}; //充值参数
//    NSDictionary *dic = @{@"app":@"appspay",@"act":@"wx_unifiedorder",@"out_trade_no":[NSString stringWithFormat:@"%@-%@-0-0",[UserModel share].userId,dataDic[@"order_id"]],@"total_fee":@"0.01"};
    [NetworkModel requestGet:dic complete:^(id _Nonnull dic) {
        
        if ([dic[@"msg"] intValue] == 1) {
            NSString *userInfo = dic[@"retval"];
            NSData *data = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *dict = dic;
            if(dict != nil){
                NSDictionary *dic = dict;
                //                NSMutableString *retcode = [dic objectForKey:@"result_code"];
                //                if (retcode.intValue == 0){
                NSMutableString *stamp  = (NSMutableString *)[[dic objectForKey:@"timestamp"] stringValue];
                PayReq* req             = [[PayReq alloc] init];
                req.openID              = [dic objectForKey:@"appid"];
                req.partnerId           = [dic objectForKey:@"partnerid"];
                req.prepayId            = [dic objectForKey:@"prepayid"];
                req.nonceStr            = [NSString stringWithFormat:@"%@",[dic objectForKey:@"noncestr"]];
                req.timeStamp           = stamp.intValue;
                req.package             = @"Sign=WXPay";
                req.sign                = [dic objectForKey:@"sign"];
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:req.openID forKey:@"appid"];
                [params setObject:req.nonceStr forKey:@"noncestr"];
                [params setObject:req.package forKey:@"package"];
                [params setObject:req.partnerId forKey:@"partnerid"];
                [params setObject:req.prepayId forKey:@"prepayid"];
                [params setObject:[NSString stringWithFormat:@"%d", stamp.intValue] forKey:@"timestamp"];
                
                
                
                NSLog(@"%@",req.sign);
                [WXApi sendReq:req];
                req.sign = [self createMd5Sign:params];
                NSLog(@"%@",req.sign);
                
                //                    [WXApi sendReq:req];
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
                //                }
            }
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:dic[@"retval"]];
        }
        
        
        
        
    }];
    
    //    [[[NetWorkModel alloc] initWithRequestWithParam:@{@"deal_no":dataDic[@"deal_no"],@"payment":@"weixin"} url:@"/api.php/Pay/online_pay" requestMethod:YTKRequestMethodPost requestType:YTKRequestSerializerTypeHTTP] startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
    //        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
    //        [SVProgressHUD dismiss];
    //        if(dict != nil){
    //            NSDictionary *dic = dict[@"wechat_pay"];
    //            NSMutableString *retcode = [dic objectForKey:@"result_code"];
    //            if (retcode.intValue == 0){
    //                NSMutableString *stamp  = (NSMutableString *)[[dic objectForKey:@"timestamp"] stringValue];
    //                PayReq* req             = [[PayReq alloc] init];
    //                req.openID              = [dic objectForKey:@"appid"];
    //                req.partnerId           = [dic objectForKey:@"mch_id"];
    //                req.prepayId            = [dic objectForKey:@"prepay_id"];
    //                req.nonceStr            = [dic objectForKey:@"nonce_str"];
    //                req.timeStamp           = stamp.intValue;
    //                req.package             = @"Sign=WXPay";
    //                req.sign                = [dic objectForKey:@"sign"];
    //
    //                NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //                [params setObject:req.openID forKey:@"appid"];
    //                [params setObject:req.nonceStr forKey:@"noncestr"];
    //                [params setObject:req.package forKey:@"package"];
    //                [params setObject:req.partnerId forKey:@"partnerid"];
    //                [params setObject:req.prepayId forKey:@"prepayid"];
    //                [params setObject:[NSString stringWithFormat:@"%d", stamp.intValue] forKey:@"timestamp"];
    //
    //
    //
    //                NSLog(@"%@",req.sign);
    ////                [WXApi sendReq:req];
    //                req.sign = [self createMd5Sign:params];
    //                NSLog(@"%@",req.sign);
    //
    //                [WXApi sendReq:req];
    //            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
    //            }
    //        }
    //    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
    //
    //    }];
    
    
    
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [manager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
    //    [manager.requestSerializer setValue:@"application/json; charset=utf-8"forHTTPHeaderField:@"Content-Type"];
    //
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //
    //    [manager POST:urlString parameters:dataDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
    ////        [[HUDHelper sharedInstance] stopLoading:hud];
    //        NSMutableDictionary *dict = NULL;
    //        dict = responseObject;
    //        if(dict != nil){
    //            NSDictionary *dic = dict;
    //            NSMutableString *retcode = [dic objectForKey:@"result_code"];
    //            if (retcode.intValue == 0){
    ////                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    //                NSMutableString *stamp  = (NSMutableString *)[[[dic objectForKey:@"timestamp"] stringValue] substringToIndex:10];
    //                //调起微信支付
    //                PayReq* req             = [[PayReq alloc] init];
    //                req.openID              = [dic objectForKey:@"appid"];
    //                req.partnerId           = [dic objectForKey:@"partnerid"];
    //                req.prepayId            = [dic objectForKey:@"prepayid"];
    //                req.nonceStr            = [dic objectForKey:@"noncestr"];
    //                req.timeStamp           = stamp.intValue;
    //                req.package             = [dic objectForKey:@"package"];
    //                req.sign                = [dic objectForKey:@"sign"];
    //                [WXApi sendReq:req];
    //                //日志输出
    //                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appId"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
    //
    ////                NSDate *date            = [NSDate date];
    ////                req.openID              = [dic objectForKey:@"appId"];
    ////                req.partnerId           = [dic objectForKey:@"partnerId"];
    ////                req.prepayId            = [dic objectForKey:@"prepayId"];
    ////                req.nonceStr            = [dic objectForKey:@"nonceStr"];
    ////                req.timeStamp           = [dic[@"timeStamp"] intValue];
    ////                req.package             = dic[@"package"];
    ////                req.sign                = [dic objectForKey:@"sign"];
    ////
    //                NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //                [params setObject:req.openID forKey:@"appid"];
    //                [params setObject:req.nonceStr forKey:@"noncestr"];
    //                [params setObject:req.package forKey:@"package"];
    //                [params setObject:req.partnerId forKey:@"partnerid"];
    //                [params setObject:req.prepayId forKey:@"prepayid"];
    //                [params setObject:[NSString stringWithFormat:@"%.0f", interval] forKey:@"timestamp"];
    //                NSLog(@"%@",req.sign);
    //                req.sign = [[self class] createMd5Sign:params];
    //                NSLog(@"%@",req.sign);
    ////                [WXApi sendReq:req];
    //            }else{
    ////                [[HUDHelper sharedInstance] tipMessage:dict[@"retmsg"]];
    //                //                return [dict objectForKey:@"retmsg"];
    //            }
    //        }else{
    //
    //            //            return @"服务器返回错误，未获取到json对象";
    //        }
    //    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
    ////        [[HUDHelper sharedInstance] stopLoading:hud];
    //        NSLog(@"Error: %@", error);
    //    }];
    
    //    [NSURLConnection]
    //    if ( response != nil) {
    //        NSMutableDictionary *dict = NULL;
    //        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    //        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    //
    //        NSLog(@"url:%@",urlString);
    //        if(dict != nil){
    //            NSMutableString *retcode = [dict objectForKey:@"retcode"];
    //            if (retcode.intValue == 0){
    //                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
    //
    //                //调起微信支付
    //                PayReq* req             = [[PayReq alloc] init];
    //                req.partnerId           = [dict objectForKey:@"partnerid"];
    //                req.prepayId            = [dict objectForKey:@"prepayid"];
    //                req.nonceStr            = [dict objectForKey:@"noncestr"];
    //                req.timeStamp           = stamp.intValue;
    //                req.package             = [dict objectForKey:@"package"];
    //                req.sign                = [dict objectForKey:@"sign"];
    //                [WXApi sendReq:req];
    //                //日志输出
    //                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
    ////                return @"";
    //            }else{
    ////                return [dict objectForKey:@"retmsg"];
    //            }
    //        }else{
    ////            return @"服务器返回错误，未获取到json对象";
    //        }
    //    }else{
    ////        return @"服务器返回错误";
    //    }
}

+ (void)jumpToBizPay:(NSDictionary *)dataDic {
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
//    NSString *urlString   = @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php?plat=ios";
//    NSString *urlString = [NSString stringWithFormat:@"%@/card/v1/weixin/pay/ask/appPay",NT_BaseUrl];//@"http://yt.dev.cmytc.com/card/v1/weixin/pay/ask/appPay";
    
//    __weak MBProgressHUD *hud = [[HUDHelper sharedInstance] loading];
    
    
    [startWeiChatPAy jumpToWxPay];
    return;
    [SVProgressHUD show];
//    NSString *time = [NSString stringWithFormat:@"%ld",(long)[NSDate date].timeIntervalSince1970];
//    NSDictionary *dic = @{@"app":@"appspay",@"act":@"wx_unifiedorder",@"out_trade_no":[NSString stringWithFormat:@"%@-%@-1-%@",[UserModel share].userId,@"0",time],@"total_fee":@"0.01"}; //充值参数
    NSDictionary *dic = @{@"app":@"appspay",@"act":@"wx_unifiedorder",@"out_trade_no":[NSString stringWithFormat:@"%@-%@-0-0",@"1114",dataDic[@"order_id"]],@"total_fee":@"0.01"};
    [NetworkModel requestGet:dic complete:^(id _Nonnull dic) {
        
        if ([dic[@"msg"] intValue] == 1) {
            NSString *userInfo = dic[@"retval"];
            NSData *data = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            
            NSDictionary *dict = dic;
            if(dict != nil){
                NSDictionary *dic = dict;
//                NSMutableString *retcode = [dic objectForKey:@"result_code"];
//                if (retcode.intValue == 0){
                    NSMutableString *stamp  = (NSMutableString *)[[dic objectForKey:@"timestamp"] stringValue];
                    PayReq* req             = [[PayReq alloc] init];
                    req.openID              = [dic objectForKey:@"appid"];
                    req.partnerId           = [dic objectForKey:@"partnerid"];
                    req.prepayId            = [dic objectForKey:@"prepayid"];
                    req.nonceStr            = [NSString stringWithFormat:@"%@",[dic objectForKey:@"noncestr"]];
                    req.timeStamp           = stamp.intValue;
                    req.package             = @"Sign=WXPay";
                    req.sign                = [dic objectForKey:@"sign"];
                    
                    NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    [params setObject:req.openID forKey:@"appid"];
                    [params setObject:req.nonceStr forKey:@"noncestr"];
                    [params setObject:req.package forKey:@"package"];
                    [params setObject:req.partnerId forKey:@"partnerid"];
                    [params setObject:req.prepayId forKey:@"prepayid"];
                    [params setObject:[NSString stringWithFormat:@"%d", stamp.intValue] forKey:@"timestamp"];
                    
                    
                    
                    NSLog(@"%@",req.sign);
                                    [WXApi sendReq:req];
                    req.sign = [self createMd5Sign:params];
                    NSLog(@"%@",req.sign);
                    
//                    [WXApi sendReq:req];
                    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
//                }
            }
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:dic[@"retval"]];
        }
        
        
        
        
    }];

//    [[[NetWorkModel alloc] initWithRequestWithParam:@{@"deal_no":dataDic[@"deal_no"],@"payment":@"weixin"} url:@"/api.php/Pay/online_pay" requestMethod:YTKRequestMethodPost requestType:YTKRequestSerializerTypeHTTP] startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
//        [SVProgressHUD dismiss];
//        if(dict != nil){
//            NSDictionary *dic = dict[@"wechat_pay"];
//            NSMutableString *retcode = [dic objectForKey:@"result_code"];
//            if (retcode.intValue == 0){
//                NSMutableString *stamp  = (NSMutableString *)[[dic objectForKey:@"timestamp"] stringValue];
//                PayReq* req             = [[PayReq alloc] init];
//                req.openID              = [dic objectForKey:@"appid"];
//                req.partnerId           = [dic objectForKey:@"mch_id"];
//                req.prepayId            = [dic objectForKey:@"prepay_id"];
//                req.nonceStr            = [dic objectForKey:@"nonce_str"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = @"Sign=WXPay";
//                req.sign                = [dic objectForKey:@"sign"];
//                
//                NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                [params setObject:req.openID forKey:@"appid"];
//                [params setObject:req.nonceStr forKey:@"noncestr"];
//                [params setObject:req.package forKey:@"package"];
//                [params setObject:req.partnerId forKey:@"partnerid"];
//                [params setObject:req.prepayId forKey:@"prepayid"];
//                [params setObject:[NSString stringWithFormat:@"%d", stamp.intValue] forKey:@"timestamp"];
//                
//                
//                
//                NSLog(@"%@",req.sign);
////                [WXApi sendReq:req];
//                req.sign = [self createMd5Sign:params];
//                NSLog(@"%@",req.sign);
//                
//                [WXApi sendReq:req];
//            NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
//            }
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        
//    }];
    
    
    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json"forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8"forHTTPHeaderField:@"Content-Type"];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    
//    [manager POST:urlString parameters:dataDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
////        [[HUDHelper sharedInstance] stopLoading:hud];
//        NSMutableDictionary *dict = NULL;
//        dict = responseObject;
//        if(dict != nil){
//            NSDictionary *dic = dict;
//            NSMutableString *retcode = [dic objectForKey:@"result_code"];
//            if (retcode.intValue == 0){
////                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
//                NSMutableString *stamp  = (NSMutableString *)[[[dic objectForKey:@"timestamp"] stringValue] substringToIndex:10];
//                //调起微信支付
//                PayReq* req             = [[PayReq alloc] init];
//                req.openID              = [dic objectForKey:@"appid"];
//                req.partnerId           = [dic objectForKey:@"partnerid"];
//                req.prepayId            = [dic objectForKey:@"prepayid"];
//                req.nonceStr            = [dic objectForKey:@"noncestr"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = [dic objectForKey:@"package"];
//                req.sign                = [dic objectForKey:@"sign"];
//                [WXApi sendReq:req];
//                //日志输出
//                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%d\npackage=%@\nsign=%@",[dic objectForKey:@"appId"],req.partnerId,req.prepayId,req.nonceStr,(int)req.timeStamp,req.package,req.sign );
//                
////                NSDate *date            = [NSDate date];
////                req.openID              = [dic objectForKey:@"appId"];
////                req.partnerId           = [dic objectForKey:@"partnerId"];
////                req.prepayId            = [dic objectForKey:@"prepayId"];
////                req.nonceStr            = [dic objectForKey:@"nonceStr"];
////                req.timeStamp           = [dic[@"timeStamp"] intValue];
////                req.package             = dic[@"package"];
////                req.sign                = [dic objectForKey:@"sign"];
////                
//                NSMutableDictionary *params = [NSMutableDictionary dictionary];
//                [params setObject:req.openID forKey:@"appid"];
//                [params setObject:req.nonceStr forKey:@"noncestr"];
//                [params setObject:req.package forKey:@"package"];
//                [params setObject:req.partnerId forKey:@"partnerid"];
//                [params setObject:req.prepayId forKey:@"prepayid"];
//                [params setObject:[NSString stringWithFormat:@"%.0f", interval] forKey:@"timestamp"];
//                NSLog(@"%@",req.sign);
//                req.sign = [[self class] createMd5Sign:params];
//                NSLog(@"%@",req.sign);
////                [WXApi sendReq:req];
//            }else{
////                [[HUDHelper sharedInstance] tipMessage:dict[@"retmsg"]];
//                //                return [dict objectForKey:@"retmsg"];
//            }
//        }else{
//            
//            //            return @"服务器返回错误，未获取到json对象";
//        }
//    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
////        [[HUDHelper sharedInstance] stopLoading:hud];
//        NSLog(@"Error: %@", error);
//    }];
    
//    [NSURLConnection]
//    if ( response != nil) {
//        NSMutableDictionary *dict = NULL;
//        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
//        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
//        
//        NSLog(@"url:%@",urlString);
//        if(dict != nil){
//            NSMutableString *retcode = [dict objectForKey:@"retcode"];
//            if (retcode.intValue == 0){
//                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//                
//                //调起微信支付
//                PayReq* req             = [[PayReq alloc] init];
//                req.partnerId           = [dict objectForKey:@"partnerid"];
//                req.prepayId            = [dict objectForKey:@"prepayid"];
//                req.nonceStr            = [dict objectForKey:@"noncestr"];
//                req.timeStamp           = stamp.intValue;
//                req.package             = [dict objectForKey:@"package"];
//                req.sign                = [dict objectForKey:@"sign"];
//                [WXApi sendReq:req];
//                //日志输出
//                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
////                return @"";
//            }else{
////                return [dict objectForKey:@"retmsg"];
//            }
//        }else{
////            return @"服务器返回错误，未获取到json对象";
//        }
//    }else{
////        return @"服务器返回错误";
//    }
}

+ (NSString*) createMd5Sign:(NSDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", @"chongqingyibiyiwangluo369140141y"];
    //得到MD5 sign签名
    NSString *md5Sign =[self md5:contentString];
    
    //输出Debug Info
//    [self.debugInfo appendFormat:@"MD5签名字符串：\n%@\n\n",contentString];
    
    return md5Sign;
}

+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//生成随机数算法 ,随机字符串，不长于32位
//微信支付API接口协议中包含字段nonce_str，主要保证签名不可预测。
//我们推荐生成随机数算法如下：调用随机数函数生成，将得到的值转换为字符串。

+ (NSString *)generateTradeNO {
    
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    
    //  srand函数是初始化随机数的种子，为接下来的rand函数调用做准备。
    //  time(0)函数返回某一特定时间的小数值。
    //  这条语句的意思就是初始化随机数种子，time函数是为了提高随机的质量（也就是减少重复）而使用的。
    
    //　srand(time(0)) 就是给这个算法一个启动种子，也就是算法的随机种子数，有这个数以后才可以产生随机数,用1970.1.1至今的秒数，初始化随机数种子。
    //　Srand是种下随机种子数，你每回种下的种子不一样，用Rand得到的随机数就不一样。为了每回种下一个不一样的种子，所以就选用Time(0)，Time(0)是得到当前时时间值（因为每时每刻时间是不一样的了）。
    
    srand(time(0)); // 此行代码有警告:
    
    for (int i = 0; i < kNumber; i++) {
        
        unsigned index = rand() % [sourceStr length];
        
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

#pragma mark - 获取设备ip地址

+ (NSString *)fetchIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - Public Methods
//  发起微信支付
+ (void)jumpToWxPay
{
    
#pragma mark 客户端操作时候的代码 \ 但是这些步骤应该放在服务端操作
    
    //============================================================
    // V3&V4支付流程实现
    // 注意:参数配置请查看服务器端Demo
    // 更新时间：2015年11月20日
    //============================================================
    
    // 交易类型
#define TRADE_TYPE @"APP"
    
    // 交易结果通知网站此处用于测试，随意填写，正式使用时填写正确网站
#define NOTIFY_URL @"http://wxpay.weixin.qq.com/pub_v2/pay/notify.v2.php"
    
    // 交易价格1表示0.01元，10表示0.1元
#define PRICE @"1"
    
    
    //  随机字符串变量 这里最好使用和安卓端一致的生成逻辑
    NSString *nonce_str = [self generateTradeNO];
    
    //  设备IP地址,请再wifi环境下测试,否则获取的ip地址为error,正确格式应该是8.8.8.8
    NSString *addressIP = [self fetchIPAddress];
    
    //  随机产生订单号用于测试，正式使用请换成你从自己服务器获取的订单号
    NSString *orderno = [NSString stringWithFormat:@"%ld",time(0)];
    
    //  获取SIGN签名
    DataMD5 *data = [[DataMD5 alloc] initWithAppid:WX_APPID
                                            mch_id:MCH_ID
                                         nonce_str:nonce_str
                                        partner_id:WX_PartnerKey
                                              body:@"充值"
                                      out_trade_no:orderno
                                         total_fee:PRICE
                                  spbill_create_ip:addressIP
                                        notify_url:NOTIFY_URL
                                        trade_type:TRADE_TYPE];
    
    // 转换成xml字符串
    NSString *string = [[data dic] XMLString];
    
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    //这里传入的xml字符串只是形似xml，但不是正确是xml格式，需要使用AF方法进行转义
    session.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    [session.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [session.requestSerializer setValue:WXUNIFIEDORDERURL forHTTPHeaderField:@"SOAPAction"];
    [session.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return string;
    }];
    [session POST:WXUNIFIEDORDERURL parameters:string progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //  输出XML数据
        NSString *responseString = [[NSString alloc] initWithData:responseObject
                                                         encoding:NSUTF8StringEncoding] ;
        //  将微信返回的xml数据解析转义成字典
        NSDictionary *dic = [NSDictionary dictionaryWithXMLString:responseString];
        
        // 判断返回的许可
        if ([[dic objectForKey:@"result_code"] isEqualToString:@"SUCCESS"]
            &&[[dic objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
            // 发起微信支付，设置参数
            PayReq *request = [[PayReq alloc] init];
            request.openID = [dic objectForKey:WXAPPID];
            request.partnerId = [dic objectForKey:WXMCHID];
            request.prepayId= [dic objectForKey:WXPREPAYID];
            request.package = @"Sign=WXPay";
            request.nonceStr= [dic objectForKey:WXNONCESTR];
            // 将当前时间转化成时间戳
            NSDate *datenow = [NSDate date];
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
            UInt32 timeStamp =[timeSp intValue];
            request.timeStamp= timeStamp;
            // 签名加密
            DataMD5 *md5 = [[DataMD5 alloc] init];
            request.sign = [dic objectForKey:@"sign"];
            request.sign=[md5 createMD5SingForPay:request.openID
                                        partnerid:request.partnerId
                                         prepayid:request.prepayId
                                          package:request.package
                                         noncestr:request.nonceStr
                                        timestamp:request.timeStamp];
            // 调用微信
            [WXApi sendReq:request];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
    }];
    
#pragma mark  服务端操作微信支付 / 上述客户端操作可以忽略（仅供参考）没办法，靠后台还不如靠自己，先自己了解客户端实现支付的操作
    
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[WXTOTALFEE] = @"1";
//    params[WXEQUIPMENTIP] = [self fetchIPAddress];
//    
//    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//    [session POST:URLSTRING parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        
//        NSLog(@"responseObject = %@",responseObject);
//        
//        // 判断返回的许可
//        if ([[responseObject objectForKey:@"result_code"] isEqualToString:@"SUCCESS"]
//            &&[[responseObject objectForKey:@"return_code"] isEqualToString:@"SUCCESS"] ) {
//            
//            // 发起微信支付，设置参数
//            PayReq *request     = [[PayReq alloc] init];
//            request.openID      = [responseObject objectForKey:WXAPPID];
//            request.partnerId   = [responseObject objectForKey:WXMCHID];
//            request.prepayId    = [responseObject objectForKey:WXPREPAYID];
//            request.package     = @"Sign=WXPay";
//            request.nonceStr    = [responseObject objectForKey:WXNONCESTR];
//            request.timeStamp   = [[responseObject objectForKey:@"timestamp"] intValue];
//            request.sign        = [responseObject objectForKey:@"sign"];
//            // 调用微信支付
//            [WXApi sendReq:request];
//        }else{
//            // 显示错误信息
//            [LyonKeyWindow.rootViewController showHint:responseObject[@"err_code_des"]];
//        }
//        
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        
//        NSLog(@"%@",error);
//    }];
    
}

@end

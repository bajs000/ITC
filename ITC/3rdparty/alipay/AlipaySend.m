//
//  AlipaySend.m
//  JMS
//  支付宝支付
//  Created by crly on 15/8/21.
//  Copyright (c) 2015年 sevnce. All rights reserved.
//

#import "AlipaySend.h"
#import "DataSigner.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
//#import "NTAPPConstants.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ITC-Swift.h"

@implementation AlipaySend

+(void)toAlipay:(NSString *)outTradeNO withSubject:(NSString *)subject withBody:(NSString *)body withTotalFee:(float)totalFee callback:(void (^)(NSDictionary *))callback{
    
    //partner和seller获取失败,提示
    NSString *partner = @"2088221373799928";
    NSString *seller= @"23872073@qq.com"; //商户号
    NSString *privateKey= @"MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCWzUsjSkxN+bg7sjKFOK5h0S95nAlJaYOMGDGHlI2LkLaPAC9Q0YzoweQy0ZlSJIKlnVW1mtv5mBIyRDGL6nw0PJbxT2/S4Uukibanb7BVg6gioCbObTffNpI7pXxIGBRWAKujoqHmvyybovaxadpnXCiSB8WqmqVD7FaQ82q7/pDLUMpq4PiWy6IniAaYn3UQDPtoJVkBesdFv24lBRBejkezF1/EyNg3o/ZbZAEPDvlGdaadapK+FAozF68cXSCs2mY4eopD2ibh8H0hJ7GBhltWHtan2TPv/gbR9acKDn2dFkpu7JIUCGqHoI0BfFQ3inqMAWDATuhAIFL29Kq7AgMBAAECggEAGQMX8VSDb3N54TzfMEWEdujxTORajfiYPwZMQMac64cnIHTRZEA9dOWj6eHl4j/4A2wjKSn0TmOwsPGqniBYVXmvN3sLexivKS1GRGM8BhL+MjAJ/7cRy04L1yTNhk+oH9OgpFV3MQSIa5AOBsMd3ILmn8H2QSPBQZDTktss2t1PC3xhz89h5kQGTM9mzkO2WrDvsZvx0wFXPZvrZAxUHivnVESHn9wK8paWJp4uMbqxduLHUHkkc4gzv+ydeOEvthzij5XFDlf+cHRF0ExCHkK5mhuAx5urwBnhbrrgXGJ1649BRwyrz9nPT0P3Q4pETazW1ps0w2eDKAiS5+SToQKBgQDHRYNsEtFeuMYVi5kGQJwRSjxlVdt6AjJNgcqYVoZeh1HAfaJqchihYaEJSKSwKN2w78wDdukEjm3SSVBI7z2hR37FUjlOmIgyadqp2LsqNELkDfnBuKfdcYFdg7172iRwiCxsTBNvbeTgNJBO+ZAB0dUT2q18RE8iueLb2EAK0wKBgQDBu2r9HuXgGtURXs1VFp+Q1wYVzK4eI4Y4gbQX5EM/dw2sXkw3rkM/fOe7Ecwn4BhugEuR1Z7482PqYVDDWyxjw3QzMAJKIHxIBIbpRCLNzSxLgRzFWkrV0QTAFq3Byj+g4z2AWUCZMVWhMNZXYi6NFoDGpxsCDNTlPBuTpyAfeQKBgHW3d9KRL0PwjXvO0qAh7NA99X27gYMK5yJoSQFDI++VqtK2pQqSykATh2kPk9JI4eWTUwa86Rx68x9lldrwEY1DyfzQ/O+UJej6JWVulepxow5Lvz4UUn37fnt6xqXykNI1b2CudFDAL5PPGWy9+rdIeMJYzWF6jPErtHtAvVxnAoGAONhjdk5AqVd2OZiVq2ft/jP5xx+9334Q/jegvnnt+YtXacJpntT1SoW+ATghrXml8ZaXlf0WnnncUYOojQoNpmBNkk99/H43uXIKnBuwEq8nVihWZtotpzujpzGAXqKXtP+4phaKS+kb9SY9Xnqiqid2NdQGqr1VIsZWWSbq2BECgYB/b/xJERG1NsnqPNKl7UrIvjFc4gVSfvCi6CtvtZoRZ6xbr1Qe6puKgTeh+x6MCqAsTHHL53FDoG/jRsXIV0CZzqr6FCxaq4GWjOqeTnJxDFEQNm8PbaukSE4TyD6xbFmwCKSxOPZsV3ojMnHhRHBudDwvJT9eLC9xMZjnJ9tDTg=="; //私钥
    [SVProgressHUD show];
//    [[[NetWorkModel alloc] initWithRequestWithParam:@{@"deal_no":outTradeNO,@"payment":@"alipay"} url:@"/api.php/Pay/online_pay" requestMethod:YTKRequestMethodPost requestType:YTKRequestSerializerTypeHTTP] startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
//        if ([dic[@"code"] intValue] == 200) {
            if ([partner length] == 0 ||
                [seller length] == 0 ||
                [privateKey length] == 0)
            {
                NSString *error=@"缺少partner或者seller或者私钥";
                NSLog(@"支付宝错误：%@",error);
            }
            
            
            
            /*
             *生成订单信息及签名
             */
            //将商品信息赋予AlixPayOrder的成员变量
            Order *order = [[Order alloc] init];
            order.partner = partner;
            order.sellerID = seller;
            order.outTradeNO = [NSString stringWithFormat:@"%@0%@0000",@"1114",outTradeNO]; //订单ID（由商家自行制定）
    NSLog(@"%@",order.outTradeNO);
            order.subject = subject; //商品标题
            order.body = body; //商品描述
            order.appID = @"2016031201205984";
            order.totalFee = [NSString stringWithFormat:@"%.2f",totalFee]; //商品价格
            order.notifyURL = @"http://112.74.124.86/ybb/index.php?app=appspay&act=notify";//回调URL
            
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
//            order.showURL = @"m.alipay.com";
            
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
            NSString *appScheme = @"baby1314";
            
            //将商品信息拼接成字符串
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@",orderSpec);
            
            //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderSpec];
            
            //将签名成功字符串格式化为订单字符串,请严格按照该格式
            NSString *orderString = nil;
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                               orderSpec, signedString, @"RSA"];
                
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSLog(@"reslut = %@",resultDic);
                    [SVProgressHUD dismiss];
                    if ([resultDic[@"resultStatus"] isEqualToString:@"9000"] ) {
                    }else {
                        [SVProgressHUD showErrorWithStatus:@"支付失败"];
                    }
                }];
            }
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                               orderSpec, signedString, @"RSA"];
                
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    //            NSLog(@"reslut = %@",resultDic);
                    callback(resultDic);
                }];
            }
//        }else{
//            [SVProgressHUD showErrorWithStatus:dic[@"msg"]];
//        }
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        
//    }];
    
    
    
    
    
    
}

+(void)toAlipay:(NSString *)outTradeNO withSubject:(NSString *)subject withBody:(NSString *)body withTotalFee:(float)totalFee{
    
    //partner和seller获取失败,提示
    NSString *partner = @"2088221373799928";
    NSString *seller= @"23872073@qq.com"; //商户号
    NSString *privateKey= @"MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCWzUsjSkxN+bg7sjKFOK5h0S95nAlJaYOMGDGHlI2LkLaPAC9Q0YzoweQy0ZlSJIKlnVW1mtv5mBIyRDGL6nw0PJbxT2/S4Uukibanb7BVg6gioCbObTffNpI7pXxIGBRWAKujoqHmvyybovaxadpnXCiSB8WqmqVD7FaQ82q7/pDLUMpq4PiWy6IniAaYn3UQDPtoJVkBesdFv24lBRBejkezF1/EyNg3o/ZbZAEPDvlGdaadapK+FAozF68cXSCs2mY4eopD2ibh8H0hJ7GBhltWHtan2TPv/gbR9acKDn2dFkpu7JIUCGqHoI0BfFQ3inqMAWDATuhAIFL29Kq7AgMBAAECggEAGQMX8VSDb3N54TzfMEWEdujxTORajfiYPwZMQMac64cnIHTRZEA9dOWj6eHl4j/4A2wjKSn0TmOwsPGqniBYVXmvN3sLexivKS1GRGM8BhL+MjAJ/7cRy04L1yTNhk+oH9OgpFV3MQSIa5AOBsMd3ILmn8H2QSPBQZDTktss2t1PC3xhz89h5kQGTM9mzkO2WrDvsZvx0wFXPZvrZAxUHivnVESHn9wK8paWJp4uMbqxduLHUHkkc4gzv+ydeOEvthzij5XFDlf+cHRF0ExCHkK5mhuAx5urwBnhbrrgXGJ1649BRwyrz9nPT0P3Q4pETazW1ps0w2eDKAiS5+SToQKBgQDHRYNsEtFeuMYVi5kGQJwRSjxlVdt6AjJNgcqYVoZeh1HAfaJqchihYaEJSKSwKN2w78wDdukEjm3SSVBI7z2hR37FUjlOmIgyadqp2LsqNELkDfnBuKfdcYFdg7172iRwiCxsTBNvbeTgNJBO+ZAB0dUT2q18RE8iueLb2EAK0wKBgQDBu2r9HuXgGtURXs1VFp+Q1wYVzK4eI4Y4gbQX5EM/dw2sXkw3rkM/fOe7Ecwn4BhugEuR1Z7482PqYVDDWyxjw3QzMAJKIHxIBIbpRCLNzSxLgRzFWkrV0QTAFq3Byj+g4z2AWUCZMVWhMNZXYi6NFoDGpxsCDNTlPBuTpyAfeQKBgHW3d9KRL0PwjXvO0qAh7NA99X27gYMK5yJoSQFDI++VqtK2pQqSykATh2kPk9JI4eWTUwa86Rx68x9lldrwEY1DyfzQ/O+UJej6JWVulepxow5Lvz4UUn37fnt6xqXykNI1b2CudFDAL5PPGWy9+rdIeMJYzWF6jPErtHtAvVxnAoGAONhjdk5AqVd2OZiVq2ft/jP5xx+9334Q/jegvnnt+YtXacJpntT1SoW+ATghrXml8ZaXlf0WnnncUYOojQoNpmBNkk99/H43uXIKnBuwEq8nVihWZtotpzujpzGAXqKXtP+4phaKS+kb9SY9Xnqiqid2NdQGqr1VIsZWWSbq2BECgYB/b/xJERG1NsnqPNKl7UrIvjFc4gVSfvCi6CtvtZoRZ6xbr1Qe6puKgTeh+x6MCqAsTHHL53FDoG/jRsXIV0CZzqr6FCxaq4GWjOqeTnJxDFEQNm8PbaukSE4TyD6xbFmwCKSxOPZsV3ojMnHhRHBudDwvJT9eLC9xMZjnJ9tDTg=="; //私钥
    [SVProgressHUD show];
    //    [[[NetWorkModel alloc] initWithRequestWithParam:@{@"deal_no":outTradeNO,@"payment":@"alipay"} url:@"/api.php/Pay/online_pay" requestMethod:YTKRequestMethodPost requestType:YTKRequestSerializerTypeHTTP] startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
    //        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
    //        if ([dic[@"code"] intValue] == 200) {
    if ([partner length] == 0 ||
        [seller length] == 0 ||
        [privateKey length] == 0)
    {
        NSString *error=@"缺少partner或者seller或者私钥";
        NSLog(@"支付宝错误：%@",error);
    }
    
    
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.sellerID = seller;
    NSString *time = [NSString stringWithFormat:@"%ld",(long)[NSDate date].timeIntervalSince1970];
    order.outTradeNO = [NSString stringWithFormat:@"%@0%@010%@",@"1114",outTradeNO,time]; //订单ID（由商家自行制定）
    NSLog(@"%@",order.outTradeNO);
    order.subject = subject; //商品标题
    order.body = body; //商品描述
    order.appID = @"2016031201205984";
    order.totalFee = [NSString stringWithFormat:@"%.2f",totalFee]; //商品价格
    order.notifyURL = @"http://112.74.124.86/ybb/index.php?app=appspay&act=notify";//回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    //            order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"baby1314";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
        }];
    }
    //        }else{
    //            [SVProgressHUD showErrorWithStatus:dic[@"msg"]];
    //        }
    //    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
    //
    //    }];
    
    
    
    
    
    
}

@end

//
//  Constants.m
//  NEWMOHO
//
//  Created by rimi on 2017/8/15.
//  Copyright © 2017年 yangkai. All rights reserved.
//

#import "Constants.h"
#import "CommonCrypto/CommonDigest.h"
#import <MJRefresh/MJRefresh.h>


@implementation Constants

+ (BOOL)getIsIpad
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        return NO;
    }
    else if([deviceType isEqualToString:@"iPod touch"]) {
        //iPod Touch
        return NO;
    }
    else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        return YES;
    }
    return NO;
}

+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title{
    NSString * strT = title;
    if ([self isTextEmpty:title]) {
        strT = @"提示";
    }
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:strT message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [[self keyController] presentViewController:alert animated:true completion:nil];
}
+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title buttonText:(NSString *)buttonText buttonAction:(void (^)())buttonAction{
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title ? title : @"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:buttonText ? buttonText :@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (buttonAction) {
            buttonAction();
        }
    }]];
    [[self keyController] presentViewController:alert animated:true completion:nil];
}

+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title buttonTexts:(NSArray *)arrTexts buttonAction:(void (^)(int buttonIndex))buttonAction{
    
    if (arrTexts && arrTexts.count) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:title ? title : @"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        int index = 0;
        for (NSString * strText in arrTexts) {
            [alert addAction:[UIAlertAction actionWithTitle:strText ? strText :@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (buttonAction) {
                    buttonAction(index);
                }
            }]];
            index++;
        }
        [[self keyController] presentViewController:alert animated:true completion:nil];
    }
    
}
+(UIViewController *)keyController{
    UIViewController * keyController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    do{
        if (keyController.presentedViewController) {
            keyController = keyController.presentedViewController;
        }else{
            break;
        }
    }while(keyController.presentedViewController);
    return keyController;
}

//判断字符是否为空
+(BOOL)isTextEmpty:(NSString *)str{
    if (str == nil || (id)str == [NSNull null]) {
        return YES;
    }else{
        if (![str respondsToSelector:@selector(length)]) {
            return YES;
        }
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([str length]) {
            return NO;
        }
    }
    return YES;
}

//计算字节长度 中文两个字节
+ (NSUInteger)textLength: (NSString *) text{
    
    NSUInteger asciiLength = 0;
    
    for (NSUInteger i = 0; i < text.length; i++) {
        
        
        unichar uc = [text characterAtIndex: i];
        
        asciiLength += isascii(uc) ? 1 : 1;
    }
    
    NSUInteger unicodeLength = asciiLength;
    
    return unicodeLength;
    
}


+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}


+ (NSString *)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    json = [json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    json = [json stringByReplacingOccurrencesOfString:@" " withString:@""];
    return json;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"Json Parse Err：%@",err);
        return nil;
    }
    return dic;
}







@end

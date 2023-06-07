//
//  Constants.h
//  NEWMOHO
//
//  Created by rimi on 2017/8/15.
//  Copyright © 2017年 yangkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, OCVideoLiveDeviceType) {
  OCVideoLiveDeviceTypePhone,
  OCVideoLiveDeviceTypePad
};
@class MJRefreshGifHeader,MJRefreshAutoGifFooter;
@interface Constants : NSObject
+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title;
+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title buttonText:(NSString *)buttonText buttonAction:(void (^)())buttonAction;
+(void)showAAlertMessage:(NSString *)msg title:(NSString *)title buttonTexts:(NSArray *)arrTexts buttonAction:(void (^)(int buttonIndex))buttonAction;
/**
 判断字符是否为空
 */
+(BOOL)isTextEmpty:(NSString *)str;
/**
 计算字符（包含中文）
 */
+ (NSUInteger)textLength: (NSString *) text;


/**
 字典转Json字符串
 
 @param infoDict 字典
 */
+ (NSString*)convertToJSONData:(id)infoDict;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

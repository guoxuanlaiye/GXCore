//
//  GXUtility.h
//  GXUtility
//
//  Created by yingcan on 17/2/20.
//  Copyright © 2017年 Guoxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GXUtility : NSObject
// 获取时间戳，如：刚刚，几s前，几分钟前
+ (NSString*)getTimestamp:(time_t)ctime;
// 纯颜色图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
// 验证是含本方法定义的 “特殊字符”
+ (BOOL)isSpecialCharacter:(NSString *)Character;
// 验证是否是数字
+ (BOOL)isNumber:(NSString *)Character;
// 能否使用相机
+ (BOOL)canUseCamera;
// 检测字符串是否为空
+ (BOOL)isEmpty:(NSString *)src;
// 根据屏幕宽度适应字体大小
+ (void)setLabelFont:(UILabel *)label fitToDevice:(CGFloat)fontSize;
// 金额字符串隐藏，显示为***
+ (NSString *)transformAmountWithString:(NSString *)amountStr;
// 金额以千划分，保留小数点后两位
+ (NSString *)separateAmountWithFloat:(CGFloat)amount;
+ (NSString *)separateAmountWithString:(NSString* )amountStr;

#pragma mark - 封装MBProgressHUD

+ (void)showHUDMessage:(NSString *)msg view:(UIView *)view;
+ (void)showHUDMessage:(NSString *)msg;
+ (void)showHUDLoadingWithMessage:(NSString *)msg view:(UIView *)view;
+ (void)showHUDLoadingWithMessage:(NSString *)msg;
+ (void)dismissHUDInView:(UIView *)view;
+ (void)dismissHUD;
@end

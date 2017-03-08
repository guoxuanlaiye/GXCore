//
//  GXUtility.m
//  GXUtility
//
//  Created by yingcan on 17/2/20.
//  Copyright © 2017年 Guoxuan. All rights reserved.
//

#import "GXUtility.h"
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@implementation GXUtility
// 时间显示格式化
+ (NSString*)getTimestamp:(time_t)ctime
{
    NSString *_timestamp;
    time_t now;
    time(&now);
    
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:ctime];
    
    int distance = (int)difftime(now, ctime);
    if (distance < 0) {
        _timestamp = @"刚刚";
    } else if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    } else if (distance < 60 * 60) {
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    } else {
        NSCalendar* chineseClendar = [[ NSCalendar alloc ] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSUInteger unitFlags =  NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents *orginDate = [chineseClendar components:unitFlags fromDate:dateTime];
        NSInteger orginYear = orginDate.year;
        NSInteger orginMonth = orginDate.month;
        NSInteger orginDay = orginDate.day;
        
        NSDateComponents *nowDate = [chineseClendar components:unitFlags fromDate:[NSDate date]];
        NSInteger nowYear = nowDate.year;
        NSInteger nowMonth = nowDate.month;
        NSInteger nowDay = nowDate.day;
        
        
        if (orginYear == nowYear && orginMonth == nowMonth && orginDay == nowDay) {
            //当天的时间
            NSDateFormatter *stringFormatter = [[NSDateFormatter alloc] init];
            [stringFormatter setDateFormat:@"HH:mm"];
            _timestamp = [stringFormatter stringFromDate:dateTime];
        } else {
            if (distance < 60 * 60 * 24 * 365) {
                NSDateFormatter *stringFormatter = [[NSDateFormatter alloc] init];
                [stringFormatter setDateFormat:@"MM-dd HH:mm"];
                _timestamp = [stringFormatter stringFromDate:dateTime];
            } else {
                NSDateFormatter *stringFormatter = [[NSDateFormatter alloc] init];
                [stringFormatter setDateFormat:@"yyy-MM-dd HH:mm"];
                _timestamp = [stringFormatter stringFromDate:dateTime];
            }
        }
    }
    return _timestamp;
}

// 纯颜色图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//验证是含本方法定义的 “特殊字符”
+ (BOOL)isSpecialCharacter:(NSString *)Character {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:
                           @"@／:;（）¥「」!,.?<>£＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\"/"""];
    NSRange specialrang = [Character rangeOfCharacterFromSet:set];
    if (specialrang.location != NSNotFound) {
        return YES;
    }
    return NO;
}
// 验证是否是数字
+ (BOOL)isNumber:(NSString *)Character {
    NSCharacterSet *cs;
    cs = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSRange specialrang = [Character rangeOfCharacterFromSet:cs];
    if (specialrang.location != NSNotFound) {
        return YES;
    }
    return NO;
}
// 能否使用相机
+ (BOOL)canUseCamera {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == AVAuthorizationStatusRestricted) {
        
        
    } else if (authStatus == AVAuthorizationStatusDenied) {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设备的设置-隐私-相机 中允许访问相机。" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertVC addAction:action];
        UIViewController * topVC = [UIApplication sharedApplication].windows[0].rootViewController;
        [topVC presentViewController:alertVC animated:YES completion:nil];
        
        return NO;
    } else if (authStatus == AVAuthorizationStatusAuthorized) { //允许访问
        return YES;
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType
                                 completionHandler:^(BOOL granted) {
                                     if (granted) { //点击允许访问时调用
                                         //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                                         NSLog(@"Granted access to %@", mediaType);
                                     } else {
                                         NSLog(@"Not granted access to %@", mediaType);
                                     }
                                 }];
    } else {
        NSLog(@"Unknown authorization status");
    }
    return YES;
}
// 检测字符串是否为空
+ (BOOL)isEmpty:(NSString *)src{
    
    if (src == nil || [@"" isEqualToString:src] || [src isKindOfClass:[NSNull class]] || [src isEqualToString:@"(null)"] || [src isEqualToString:@"<null>"]) {
        return YES;
    }
    return NO;
}
// 根据屏幕宽度适应字体大小
+ (void)setLabelFont:(UILabel *)label fitToDevice:(CGFloat)fontSize
{
    CGFloat kScreenSize = [[UIScreen mainScreen] bounds].size.width;
    if (kScreenSize == 320) { // 4s/5/5s
        label.font = [UIFont systemFontOfSize:fontSize];
    } else if (kScreenSize == 375){ // 6/6s/7
        label.font = [UIFont systemFontOfSize:fontSize + 1];
    } else {  //  6p/6sp/7p
        label.font = [UIFont systemFontOfSize:fontSize + 2];
    }
}
//金额字符串转化为***
+ (NSString *)transformAmountWithString:(NSString *)amountStr {

    NSString * tmpStr  = @"";
    NSString * hideStr = @"";
    for (NSInteger i = 0; i < amountStr.length; i++) {
        
        tmpStr = [amountStr substringWithRange:NSMakeRange(i, 1)];
        if ([self isNumber:tmpStr]) {
            hideStr = [hideStr stringByAppendingString:@"*"];
        }
    }
    return hideStr;
}
//金额字符串分隔，如1000.25转为1,000.25
+ (NSString *)separateAmountWithFloat:(CGFloat )amount {
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:@"###,##0.00;"];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:amount]];
    return formattedNumberString;
}
+ (NSString *)separateAmountWithString:(NSString* )amountStr {

    CGFloat amountF = [amountStr floatValue];
    return [self separateAmountWithFloat:amountF];
}
#pragma mark - 封装MBProgressHUD
+ (void)showHUDMessage:(NSString *)msg view:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode            = MBProgressHUDModeText;
    hud.label.text      = msg;
    hud.label.textColor = [UIColor whiteColor]; //字体白色
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor; //此style不会走添加毛玻璃效果的代码，具体看源码
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8]; //黑色背景框
    [hud hideAnimated:YES afterDelay:2.f];
}
+ (void)showHUDMessage:(NSString *)msg
{
    UIWindow * window  = [UIApplication sharedApplication].keyWindow;
    [self showHUDMessage:msg view:window];
}
+ (void)showHUDLoadingWithMessage:(NSString *)msg view:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
    MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text      = msg;
    hud.label.textColor = [UIColor whiteColor];  //字体白色
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [[UIColor blackColor] colorWithAlphaComponent:0.8]; //黑色背景框
    hud.mode            = MBProgressHUDModeIndeterminate;
    hud.activityIndicatorColor = [UIColor whiteColor]; //竟然被废弃了！！！QAQ
    [hud showAnimated:YES];
}
+ (void)showHUDLoadingWithMessage:(NSString *)msg
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [self showHUDLoadingWithMessage:msg view:window];
}

+ (void)dismissHUDInView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}
+ (void)dismissHUD
{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    [self dismissHUDInView:window];
}
@end

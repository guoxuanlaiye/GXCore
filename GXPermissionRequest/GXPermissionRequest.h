//
//  GXPermissionRequest.h
//  PermissionRequest_Demo
//
//  Created by yingcan on 17/2/27.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WQErrorDomain @"WQErrorDomain"

typedef NS_ENUM(NSInteger,GXPermission) {

    GXPhotoLibrary = 0,
    GXCamera,
    GXMicrophone,          // 麦克风
    GXLocationAllows,      // 始终定位
    GXLocationWhenInUse,   // 使用时定位
    GXCalendars,           // 日历
    GXReminders,           // 提醒事项
    GXHealth,              // 健康更新
    GXUserNotification,    // 通知
    GXContacts,            // 通讯录
};
typedef NS_ENUM(NSInteger,GXErrorCode) {
    
    GXForbidPermission = 0,
    GXfailureAuthorize,
    GXUnsuportAuthorize
};
typedef void(^GXRequestResult)(BOOL granted, NSError *error);

@interface GXPermissionRequest : NSObject

+ (GXPermissionRequest *)createGXPermissionRequest;

- (BOOL)determinePermission:(GXPermission)permission;

- (void)requestPermission:(GXPermission)permission
                    title:(NSString *)title
              description:(NSString *)description
            requestResult:(GXRequestResult)result;
@end

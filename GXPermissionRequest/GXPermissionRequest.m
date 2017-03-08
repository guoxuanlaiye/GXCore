//
//  GXPermissionRequest.m
//  PermissionRequest_Demo
//
//  Created by yingcan on 17/2/27.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import "GXPermissionRequest.h"
#import <Photos/Photos.h>
#import <Contacts/Contacts.h>
#import <EventKit/EventKit.h>
#import <HealthKit/HealthKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef NS_ENUM(NSInteger,GXPermissionAuthorizationStatus) {
    GXAuthorizationStatusNotDetermined,  // 第一次请求授权
    GXAuthorizationStatusAuthorized,     // 已经授权成功
    GXAuthorizationStatusForbid          // 非第一次请求授权
};

@interface GXPermissionRequest ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, copy, nullable) GXRequestResult locationResult;
@end

@implementation GXPermissionRequest
#pragma mark - Public
+ (GXPermissionRequest *)createGXPermissionRequest {
    return [[[self class] alloc] init];
}
#pragma mark - Private 当前top的控制器
- (UIViewController *)currentViewController {
    UIViewController *currentVC = nil;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow *tmpWindow in windows) {
            if (tmpWindow.windowLevel == UIWindowLevelNormal) {
                window = tmpWindow;
                break;
            }
        }
    }
    UIView *frontV = [[window subviews] objectAtIndex:0];
    id nextReqoner = [frontV nextResponder];
    if ([nextReqoner isKindOfClass:[UIViewController class]]) {
        currentVC = nextReqoner;
    }else {
        currentVC = window.rootViewController;
    }
    return currentVC;
}
#pragma mark - Public
- (BOOL)determinePermission:(GXPermission)permission {
    GXPermissionAuthorizationStatus determine = [self authorizationPermission:permission];
    return determine == GXAuthorizationStatusAuthorized;
}
#pragma mark - Public
- (void)requestPermission:(GXPermission)permission
                    title:(NSString *)title
              description:(NSString *)description
            requestResult:(GXRequestResult)result {
    GXPermissionAuthorizationStatus authorization = [self authorizationPermission:permission];
    if (result == nil) {
        result = ^(BOOL granted, NSError *error) {
        };;
    }
    switch (authorization) {
        case GXAuthorizationStatusNotDetermined:
            // 第一次请求
            [self requestPermission:permission requestResult:result];
            return;
            break;
        case GXAuthorizationStatusForbid:
            // 之前请求过，现在禁了权限
            //            WQLogInf(@"之前请求过，现在禁了权限");
            self.locationResult = (permission == GXLocationAllows) ||
            (permission == GXLocationWhenInUse) ? result : nil;
            break;
        case GXAuthorizationStatusAuthorized:
            // 已经授权
            //            WQLogMes(@"已经授权");
            result(YES, nil);
            return;
            break;
    }
    __weak typeof(self) weakSelf = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:description
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *setting = [UIAlertAction actionWithTitle:@"设置"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                                NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];           [[UIApplication sharedApplication] openURL:url];
                                                            }
                                                        });
                                                    }];
    UIAlertAction *dontAllows = [UIAlertAction actionWithTitle:@"不允许"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSError *error = [NSError errorWithDomain:WQErrorDomain
                                                                                                code:GXForbidPermission
                                                                                            userInfo:@{NSLocalizedDescriptionKey : @"禁止访问"}];
                                                           result(NO,error);
                                                           weakSelf.locationResult = nil;
                                                       }];
    [alert addAction:setting];
    [alert addAction:dontAllows];
    UIViewController *currentVC = [self currentViewController];
    [currentVC presentViewController:alert
                            animated:YES
                          completion:nil];
}
#pragma mark - Private -/**************************************** 权 限 请 求 ****************************************/
- (void)requestPermission:(GXPermission)permission
            requestResult:(GXRequestResult)result{
    switch (permission) {
        case GXCamera:{
            [self requestCamera:result];
            break;
        }
        case GXLocationAllows:{
            [self requestLocationAllows:result];
            break;
        }
        case GXLocationWhenInUse:{
            [self requestLocationWhenInUse:result];
            break;
        }
        case GXCalendars:{
            [self requestCalendars:result];
            break;
        }
        case GXReminders:{
            [self requestReminders:result];
            break;
        }
        case GXUserNotification:{
            [self requestUserNotification:result];
            break;
        }
        case GXPhotoLibrary:{
            [self requestPhotoLibrary:result];
            break;
        }
        case GXMicrophone:{
            [self requestMicrophone:result];
            break;
        }
        case GXHealth:{
            [self requestHealth:result];
            break;
        }
        case GXContacts:{
            [self requestContacts:result];
            break;
        }
    }
}

- (void)requestCamera:(GXRequestResult)result {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {
                                 NSError *error;
                                 if (granted) {
                                     //                                     WQLogMes(@"开启成功");
                                 }else {
                                     //                                     WQLogErr(@"开启失败");
                                     error = [NSError errorWithDomain:WQErrorDomain
                                                                 code:GXfailureAuthorize
                                                             userInfo:@{NSLocalizedDescriptionKey :@"授权失败"}];
                                 }
                                 result(granted, error);
                             }];
}

- (void)requestLocationAllows:(GXRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestAlwaysAuthorization];
}

- (void)requestLocationWhenInUse:(GXRequestResult)result {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    self.locationResult = result;
    [self.manager requestWhenInUseAuthorization];
}

- (void)requestCalendars:(GXRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  //                                  WQLogErr(@"error: %@",error);
                              }else {
                                  if (granted) {
                                      //                                      WQLogMes(@"请求成功");
                                  }else {
                                      //                                      WQLogErr(@"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestReminders:(GXRequestResult)result {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted,
                                       NSError * _Nullable error) {
                              if (error) {
                                  //                                  WQLogErr(@"error: %@",error);
                              }else {
                                  if (granted) {
                                      //                                      WQLogMes(@"请求成功");
                                  }else {
                                      //                                      WQLogErr(@"请求失败");
                                  }
                              }
                              result(granted, error);
                          }];
}

- (void)requestUserNotification:(GXRequestResult)result {
    NSAssert(0, @"* * * * * * 通知授权还未实现 * * * * * *");
}

- (void)requestPhotoLibrary:(GXRequestResult)result {
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSError *error;
            BOOL granted = NO;
            if (status == PHAuthorizationStatusAuthorized) {
                //                WQLogMes(@"授权成功");
                granted = YES;
            }else {
                //                WQLogErr(@"授权失败");
                error = [NSError errorWithDomain:WQErrorDomain
                                            code:GXfailureAuthorize
                                        userInfo:@{NSLocalizedDescriptionKey :@"授权失败"}];
            }
            result(granted, error);
        }];
    }
}

- (void)requestMicrophone:(GXRequestResult)result {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session requestRecordPermission:^(BOOL granted) {
        NSError *error;
        if (granted) {
            //            WQLogMes(@"请求成功");
        }else {
            //            WQLogErr(@"请求失败");
            error = [NSError errorWithDomain:WQErrorDomain
                                        code:GXfailureAuthorize
                                    userInfo:@{NSLocalizedDescriptionKey :@"授权失败"}];
        }
        result(granted, error);
    }];
}

- (void)requestHealth:(GXRequestResult)result {
    if (![HKHealthStore isHealthDataAvailable]) {
        //        WQLogErr(@"不支持 Health");
        NSError *error = [NSError errorWithDomain:WQErrorDomain
                                             code:GXUnsuportAuthorize
                                         userInfo:@{NSLocalizedDescriptionKey :@"不支持授权"}];
        result(NO, error);
        return;
    }
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    // Share body mass, height and body mass index
    NSSet *shareObjectTypes = [NSSet setWithObjects:
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                               nil];
    // Read date of birth, biological sex and step count
    NSSet *readObjectTypes  = [NSSet setWithObjects:
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                               [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                               [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                               nil];
    // Request access
    [healthStore requestAuthorizationToShareTypes:shareObjectTypes
                                        readTypes:readObjectTypes
                                       completion:^(BOOL success,
                                                    NSError *error) {
                                           if (error) {
                                               //                                               WQLogErr(@"error: %@",error);
                                           }else {
                                               if(success == YES){
                                                   //                                                   WQLogMes(@"请求成功");
                                               }
                                               else{
                                                   //                                                   WQLogErr(@"请求失败");
                                               }
                                           }
                                           result(success, error);
                                       }];
}

- (void)requestContacts:(GXRequestResult)result {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        CNContactStore *store = [[CNContactStore alloc] init];
        [store requestAccessForEntityType:CNEntityTypeContacts
                        completionHandler:^(BOOL granted,
                                            NSError * _Nullable error) {
                            if (error) {
                                //                                WQLogErr(@"error: %@",error);
                            }else {
                                if (granted) {
                                    //                                    WQLogMes(@"请求成功");
                                }else {
                                    //                                    WQLogErr(@"请求失败");
                                }
                            }
                            result(granted, error);
                        }];
    }else {
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook,
                                                 ^(bool granted,
                                                   CFErrorRef error) {
                                                     if (error) {
                                                         //                                                         WQLogErr(@"error: %@",error);
                                                     }else {
                                                         if (granted) {
                                                             //                                                             WQLogMes(@"请求成功");
                                                         }else {
                                                             //                                                             WQLogErr(@"请求失败");
                                                         }
                                                     }
                                                     result(granted, (__bridge NSError *)(error));
                                                 });
    }
}

#pragma mark - Private /**************************************** 权 限 判 断 ****************************************/

- (GXPermissionAuthorizationStatus)authorizationPermission:(GXPermission)permission {
    GXPermissionAuthorizationStatus authorization;
    switch (permission) {
        case GXCamera:
            authorization = [self determineCamera];
            break;
        case GXPhotoLibrary:
            authorization = [self determinePhotoLibrary];
            break;
        case GXLocationAllows:
            authorization = [self determineLocationAllows];
            break;
        case GXLocationWhenInUse:
            authorization = [self determineLocationWhenInUse];
            break;
        case GXCalendars:
            authorization = [self determineCalendars];
            break;
        case GXReminders:
            authorization = [self determineReminders];
            break;
        case GXUserNotification:
            authorization = [self determineUserNotification];
            break;
        case GXMicrophone:
            authorization = [self determineMicrophone];
            break;
        case GXHealth:
            authorization = [self determineHealth];
            break;
        case GXContacts:
            authorization = [self determineContacts];
            break;
    }
    return authorization;
}
- (GXPermissionAuthorizationStatus)determineCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determineLocationAllows {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determineLocationWhenInUse {
    if (!self.manager) {
        self.manager = [[CLLocationManager alloc] init];
        self.manager.delegate = self;
    }
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determineCalendars {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determineReminders {
    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authStatus) {
        case EKAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case EKAuthorizationStatusRestricted:
        case EKAuthorizationStatusDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case EKAuthorizationStatusAuthorized: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determinePhotoLibrary {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        ALAuthorizationStatus authStatus =[ALAssetsLibrary authorizationStatus];
        switch (authStatus) {
            case ALAuthorizationStatusNotDetermined: {
                return GXAuthorizationStatusNotDetermined;
                break;
            }
            case ALAuthorizationStatusRestricted:
            case ALAuthorizationStatusDenied: {
                return GXAuthorizationStatusForbid;
                break;
            }
            case ALAuthorizationStatusAuthorized: {
                return GXAuthorizationStatusAuthorized;
                break;
            }
        }
    } else {
        PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        switch (authStatus) {
            case PHAuthorizationStatusNotDetermined: {
                return GXAuthorizationStatusNotDetermined;
                break;
            }
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied: {
                return GXAuthorizationStatusForbid;
                break;
            }
            case PHAuthorizationStatusAuthorized: {
                return GXAuthorizationStatusAuthorized;
                break;
            }
        }
    }
}

- (GXPermissionAuthorizationStatus)determineUserNotification {
    UIUserNotificationType type = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
    switch (type) {
        case UIUserNotificationTypeNone: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case UIUserNotificationTypeBadge:
        case UIUserNotificationTypeSound:
        case UIUserNotificationTypeAlert: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}

- (GXPermissionAuthorizationStatus)determineMicrophone {
    AVAudioSessionRecordPermission authStatus = [[AVAudioSession sharedInstance] recordPermission];
    switch (authStatus) {
        case AVAudioSessionRecordPermissionUndetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case AVAudioSessionRecordPermissionDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case AVAudioSessionRecordPermissionGranted: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}
//健康
- (GXPermissionAuthorizationStatus)determineHealth {
    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
    HKObjectType *hkObjectType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:hkObjectType];
    switch (authStatus) {
        case HKAuthorizationStatusNotDetermined: {
            return GXAuthorizationStatusNotDetermined;
            break;
        }
        case HKAuthorizationStatusSharingDenied: {
            return GXAuthorizationStatusForbid;
            break;
        }
        case HKAuthorizationStatusSharingAuthorized: {
            return GXAuthorizationStatusAuthorized;
            break;
        }
    }
}
//通讯录
- (GXPermissionAuthorizationStatus)determineContacts {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 9.0) {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (authStatus) {
            case CNAuthorizationStatusNotDetermined: {
                return GXAuthorizationStatusNotDetermined;
                break;
            }
            case CNAuthorizationStatusRestricted:
            case CNAuthorizationStatusDenied: {
                return GXAuthorizationStatusForbid;
                break;
            }
            case CNAuthorizationStatusAuthorized: {
                return GXAuthorizationStatusAuthorized;
                break;
            }
        }
    }else {
        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
        switch (authStatus) {
            case kABAuthorizationStatusNotDetermined: {
                return GXAuthorizationStatusNotDetermined;
                break;
            }
            case kABAuthorizationStatusRestricted:
            case kABAuthorizationStatusDenied: {
                return GXAuthorizationStatusForbid;
                break;
            }
            case kABAuthorizationStatusAuthorized: {
                return GXAuthorizationStatusAuthorized;
                break;
            }
        }
    }
}
#pragma mark  -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //    WQLogMes(@"didChangeAuthorizationStatus: %d",status);
    if (status == kCLAuthorizationStatusAuthorizedAlways
        || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        if (self.locationResult) {
            self.locationResult(YES, nil);
            self.locationResult = nil;
        }
    }
}


@end

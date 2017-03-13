//
//  GXLocationManager.h
//  GXLocationManager
//
//  Created by yingcan on 17/3/13.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GXLocationManager : NSObject

//根据经纬度
+ (void)coordinateSystemToLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude geocodeResult:(void(^)(NSString *locaStr))result;
//根据CLlocation
+ (void)coordinateSystemToLocationWithCLLocation:(CLLocation *)location geocodeResult:(void (^)(NSString *))result;
@end

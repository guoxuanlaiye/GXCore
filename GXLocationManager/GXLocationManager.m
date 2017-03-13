//
//  GXLocationManager.m
//  GXLocationManager
//
//  Created by yingcan on 17/3/13.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import "GXLocationManager.h"

@implementation GXLocationManager
+ (void)coordinateSystemToLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude geocodeResult:(void(^)(NSString *locaStr))result {
    
    CLLocation * location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    [self coordinateSystemToLocationWithCLLocation:location geocodeResult:^(NSString *locaStr) {
        
        result(locaStr);
    }];
}
+ (void)coordinateSystemToLocationWithCLLocation:(CLLocation *)location geocodeResult:(void (^)(NSString *))result {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             NSString * subLocality = placemark.subLocality;
             if (city == nil || subLocality == nil) {
                 
                 result(@"");
             } else {
                 
                 NSString * locaName = [NSString stringWithFormat:@"%@%@",city,subLocality];
                 result(locaName);
             }
             
         }
         else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
             
             result(@"");
         }
         else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
             result(@"");
         }
     }];
}
@end

//
//  NSString+GXExtension.m
//  GXWeibo
//
//  Created by ailimac100 on 15/9/23.
//  Copyright (c) 2015年 GX. All rights reserved.
//

#import "NSString+GXExtension.h"

@implementation NSString (GXExtension)

- (CGSize)sizeWithFont:(UIFont*)font maxWidth:(CGFloat)max
{
    
    NSMutableDictionary * attrsDic = [NSMutableDictionary dictionary];
    attrsDic[NSFontAttributeName]  = font;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode            = NSLineBreakByWordWrapping;
    attrsDic[NSParagraphStyleAttributeName] = paragraphStyle.copy;

    CGSize nameSize = [self boundingRectWithSize:CGSizeMake(max, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attrsDic context:nil].size;
    
    return nameSize;
}
- (CGSize)sizeWithFont:(UIFont*)font
{
    return [self sizeWithFont:font maxWidth:MAXFLOAT];
}
//有效的URL地址(以http:// 或者 https://开头)
- (BOOL)isValidUrlPath {
    
    if (self.length == 0) {
        return NO;
    }
    // http://
    if (self.length > 7 && [[self substringToIndex:7] isEqualToString:@"http://"]) {
        return YES;
    }
    // https://
    if (self.length > 8 && [[self substringToIndex:8] isEqualToString:@"https://"]) {
        return YES;
    }
    return NO;
}

@end

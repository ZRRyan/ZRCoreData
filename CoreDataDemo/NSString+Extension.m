//
//  NSString+Extension.m
//  CoreDataDemo
//
//  Created by Ryan on 16/9/16.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString*) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}


@end

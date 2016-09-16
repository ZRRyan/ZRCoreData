//
//  Person.h
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
/** 唯一标识 */
@property (nonatomic, copy) NSString *rid;
/** 姓名 */
@property (nonatomic, copy) NSString *name;
/** 描述 */
@property (nonatomic, copy) NSString *desc;
@end

//
//  CoreDataManager.h
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZRCoreDataManager : NSObject

/**
 *  单例
 */
+ (instancetype)shareManager;


/**
 *  插入
 *
 *  @param model 对象模型
 */
- (BOOL)insertWithModel: (id)model;


/**
 *  查询所有
 *
 *  @param classM 实体类
 *
 *  @return 结果
 */
- (NSArray *)queryWithClassM: (Class)classM;

/**
 *  根据调价查询
 *
 *  @param classM       实体类
 *  @param predicateStr 谓词条件
 *
 *  @return 结果
 */
- (NSArray *)queryWithClassM: (Class)classM predicateStr: (NSString *)predicateStr;


/**
 *  修改
 *
 *  @param model        对象模型
 *  @param predicateStr 条件谓词
 *
 *  @return 结果
 */
- (BOOL)updateWithModel: (id)model predicateStr: (NSString *)predicateStr;

/**
 *  删除
 *
 *  @param classM       实体类
 *  @param predicateStr 条件谓词
 *
 *  @return 结果
 */
- (BOOL)deleteWithClass : (Class)classM predicateStr: (NSString *)predicateStr;


@end

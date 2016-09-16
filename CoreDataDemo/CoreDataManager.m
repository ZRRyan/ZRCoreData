
//
//  CoreDataManager.m
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

#define SQLITENAME @"person.sqlite"
#define CLASS_NAME(PRAM) NSStringFromClass([PRAM class])

@interface CoreDataManager ()
/** NSManagedObjectContext对象 */
@property (nonatomic, strong) NSManagedObjectContext *context;
@end

@implementation CoreDataManager



+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static CoreDataManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}


/**
 *  单例
 */
+ (instancetype)shareManager {
   return [[self alloc] init];
}

- (NSManagedObjectContext *)context
{
    if (!_context) {
        // 从应用程序包中加载模型文件
        NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
        // 传入模型对象，初始化NSPersistentStoreCoordinator
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        // 构建SQLite数据库文件的路径
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSURL *url = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:SQLITENAME]];
        // 添加持久化存储库，这里使用SQLite作为存储库
        NSError *error = nil;
        NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
        if (store == nil) { // 直接抛异常
            [NSException raise:@"添加数据库错误" format:@"%@", [error localizedDescription]];
        }
        // 初始化上下文，设置persistentStoreCoordinator属性
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        context.persistentStoreCoordinator = psc;
        _context = context;
    }
    return _context;
}

/**
 *  保存
 *
 *  @return 结果
 */
- (BOOL)saveContext {
    if (self.context) {
        NSError *error = nil;
        if ([self.context hasChanges] && ![self.context save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
            abort();
            return NO;
        }
    }
    return YES;
}

/**
 *  获取对象的成员变量
 *
 *  @param classModel 对象模型
 *
 *  @return 成员变量名数组
 */
- (NSArray *)classAttributesWithModel: (id)model {

    
    Class classM = object_getClass(model);
    
    NSArray *arr = [self classAttributes:classM];
    
    return arr;
}



/**
 *  获取类的成员变量
 *
 *  @param classM 实体类
 *
 *  @return 成员变量名数组
 */
- (NSArray *)classAttributes: (Class)classM {
    
    unsigned int count;
    
    objc_property_t *properties = class_copyPropertyList([classM class], &count);
    NSMutableArray *arrM = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        [arrM addObject:[NSString stringWithFormat:@"%s", property_getName(property)]];
    }
    
    
    return arrM;
}

- (NSFetchRequest *)fetchRequestWithClassName: (NSString *)className predicate: (NSString *)predicateStr {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:self.context]];
    if (predicateStr) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateStr];
        [request setPredicate:predicate];
    }
    return  request;
}

#pragma mark - 增加

/**
 *  插入
 *
 *  @param model 对象模型
 */
- (BOOL)insertWithModel: (id)model {
    NSString *entityName = [NSString stringWithUTF8String:object_getClassName(model)];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
    for (NSString *propertyName in [self classAttributesWithModel:model]) {
        [object setValue:[model valueForKey:propertyName] forKey:propertyName];
    }
    
    BOOL result = [self saveContext];
    
    return result;
}



- (void)deleteWithModel: (id)model {

}

#pragma mark - 查
/**
 *  查询所有
 *
 *  @param classM 实体类
 *
 *  @return 结果
 */
- (NSArray *)queryWithClassM: (Class)classM {

   NSArray *arr =  [self queryWithClassM:classM predicateStr:nil];
    
    return arr;
}

/**
 *  根据调价查询
 *
 *  @param classM       实体类
 *  @param predicateStr 谓词条件
 *
 *  @return 结果
 */
- (NSArray *)queryWithClassM: (Class)classM predicateStr: (NSString *)predicateStr {
    
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:[self fetchRequestWithClassName:CLASS_NAME(classM) predicate:predicateStr] error:&error];
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSManagedObject *obj in array) {
        id model = [[classM alloc] init];
        for (NSString *property in [self classAttributes:classM]) {
            [model setValue:[obj valueForKey:property] forKey:property];
        }
        [arrM addObject:model];
    }
    
    return arrM;
    
}


#pragma mark - 改
/**
 *  修改
 *
 *  @param model        对象模型
 *  @param predicateStr 条件谓词
 *
 *  @return 结果
 */
- (BOOL)updateWithModel: (id)model predicateStr: (NSString *)predicateStr {

    NSString *className = [NSString stringWithUTF8String:object_getClassName(model)];
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:[self fetchRequestWithClassName:className predicate:predicateStr] error:&error];
    if (array.count > 0) {
        for (NSManagedObject *obj in array) {
            for (NSString *property in [self classAttributesWithModel:model]) {
                [obj setValue:[model valueForKey:property] forKey:property];
            }
        }
    }
    return  [self saveContext];
}


#pragma mark - 删

/**
 *  删除
 *
 *  @param classM       实体类
 *  @param predicateStr 条件谓词
 *
 *  @return 结果
 */
- (BOOL)deleteWithClass : (Class)classM predicateStr: (NSString *)predicateStr {
    NSString *className = CLASS_NAME(classM);
    NSError *error = nil;
    NSArray *array = [self.context executeFetchRequest:[self fetchRequestWithClassName:className predicate:predicateStr] error:&error];
    if (array.count > 0) {
        for (NSManagedObject *obj in array) {
            [self.context deleteObject:obj];
        }
    }
    return [self saveContext];
}


@end

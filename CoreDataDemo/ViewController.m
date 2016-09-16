//
//  ViewController.m
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataManager.h"
#import "Person.h"
#import "AddViewController.h"
#import "SVProgressHUD.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, AddViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** person对象模型数组 */
@property (nonatomic, copy) NSArray *arrPerson;
/** <#content#> */
@property (nonatomic, strong) CoreDataManager *coreDataManager;

@end

@implementation ViewController


- (CoreDataManager *)coreDataManager
{
    if (!_coreDataManager) {
        _coreDataManager = [CoreDataManager shareManager];
    }
    return _coreDataManager;
}

- (NSArray *)arrPerson
{
    if (!_arrPerson) { // 从数据库中读取
        _arrPerson =  [self.coreDataManager queryWithClassM:[Person class]];
    }
    return _arrPerson;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"CoreData";
}

/*
 * 控制器push时调用此方法
 */
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id page2 = segue.destinationViewController;
    [page2 setValue:self forKey:@"delegate"];

}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPerson.count;
}

/**
 *  每当有一个cell进入视野范围内,就会调用
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // static修饰局部变量:可以保证局部变量只分配一次存储空间(只初始化一次)
    static NSString * const ID = @"Person";
    
    // 1.通过一个标识去缓存池中寻找可循环利用的cell
    // dequeue : 出列 (查找)
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 2.如果没有可循环利用的cell
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    
    Person *person = self.arrPerson[indexPath.row];
    cell.textLabel.text = person.name;
    cell.detailTextLabel.text = person.desc;
    
    
    return cell;
}



#pragma mark - UITableViewDelegate
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    // 删除
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        Person *p = self.arrPerson[indexPath.row];
        BOOL result = [self.coreDataManager deleteWithClass:[Person class] predicateStr:[NSString stringWithFormat:@"rid = '%@'", p.rid]];
        if (result) {
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.arrPerson];
            [arrM removeObject:p];
            self.arrPerson = arrM;
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    // 编辑
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [self editWithIndex:indexPath.row];
    }];
    editAction.backgroundColor = [UIColor orangeColor];
    
    return @[deleteAction, editAction];
}

/*
 * 编辑
 */
- (void)editWithIndex: (NSInteger)index {
    
    Person *p = self.arrPerson[index];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"编辑" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"姓名";
        textField.text = p.name;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"描述";
        textField.text = p.desc;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *nameTextField = alertController.textFields[0];
        UITextField *descTextField = alertController.textFields[1];
        if (!nameTextField.text || [nameTextField.text isEqualToString:@""]) {
            [SVProgressHUD showInfoWithStatus:@"姓名不能为空"];
            return;
        }
    
        p.name = nameTextField.text;
        p.desc = descTextField.text;
        
        BOOL result = [self.coreDataManager updateWithModel:p predicateStr:[NSString stringWithFormat:@"rid = '%@'", p.rid]];
        if (result) {
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.arrPerson];
            [arrM replaceObjectAtIndex:index withObject:p];
            self.arrPerson = arrM;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - AddViewControllerDelegate
- (void)addViewControllerWithVC:(AddViewController *)vc successWithPerson:(Person *)person {
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:self.arrPerson];
    [arrM addObject:person];
    self.arrPerson = arrM;
    
    //    self.arrPerson =  [self.coreDataManager queryWithClassM:[Person class]];
    [self.tableView reloadData];
}




@end

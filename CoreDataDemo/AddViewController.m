//
//  AddViewController.m
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import "AddViewController.h"
#import "CoreDataManager.h"
#import "Person.h"
#import "NSString+Extension.h"
#import "SVProgressHUD.h"

@interface AddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *descTextField;
@property (nonatomic, strong) CoreDataManager *coreDataManager;
@end

@implementation AddViewController

- (CoreDataManager *)coreDataManager
{
    if (!_coreDataManager) {
        _coreDataManager = [CoreDataManager shareManager];
    }
    return _coreDataManager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加";

    
}

/**
 *  确定
 */
- (IBAction)confirmBtnClick:(id)sender {
   
    if (!self.nameTextField.text || [self.nameTextField.text isEqualToString:@""]) {
        [SVProgressHUD showInfoWithStatus:@"姓名不能为空"];
        return;
    }
    
    [self add];
    
}


- (void)add {
    Person *p = [[Person alloc] init];
    p.name = self.nameTextField.text;
    p.desc = self.descTextField.text;
    p.rid = [NSString uuid];
    
    BOOL result = [self.coreDataManager insertWithModel:p];
    if (result) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addViewControllerWithVC:successWithPerson:)]) {
            [self.delegate addViewControllerWithVC:self successWithPerson:p];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}



@end

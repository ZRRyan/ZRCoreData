//
//  AddViewController.h
//  CoreDataDemo
//
//  Created by Ryan on 16/9/13.
//  Copyright © 2016年 monkey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person;
@class AddViewController;

@protocol AddViewControllerDelegate <NSObject>

@optional
- (void)addViewControllerWithVC: (AddViewController *)vc successWithPerson: (Person *)person;

@end



@interface AddViewController : UIViewController
/** 代理 */
@property (nonatomic, weak) id<AddViewControllerDelegate>  delegate;
@end

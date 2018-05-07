//
//  ViewController.m
//  CMSSDKDemo
//
//  Created by 陈剑东 on 17/3/27.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "ViewController.h"
#import <CMSSDKUI/CMSArticleListViewController.h>
#import <MOBFoundation/MOBFUser.h>

#import <UMSSDK/UMSSDK.h>
#import <UMSSDKUI/UMSLoginViewController.h>
#import <UMSSDKUI/UMSBaseNavigationController.h>

@interface ViewController () <UITableViewDelegate,
                              UITableViewDataSource>

/**
 *  表格视图
 */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 80;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CMSCellI";
    
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = @"游客身份";
            cell.detailTextLabel.text = @"点击演示";
            break;
        case 1:

            cell.textLabel.text = @"自定义用户身份";
            cell.detailTextLabel.text = @"点击演示";
            break;
        case 2:

            cell.textLabel.text = @"UMS用户身份";
            cell.detailTextLabel.text = @"点击演示";
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 0:
            [self loginWithGuest];
            break;
        case 1:
            [self loginWithCustomUser];
            break;
        case 2:
            [self loginWithUMSSDK];
            break;
        default:
            break;
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIBarButtonItem *)backItem
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/return_w.png",sourceBundle.resourcePath];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 13.5, 22);
    [backBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    return item;
}

- (void)loginWithGuest
{
    CMSArticleListViewController *controller = [[CMSArticleListViewController alloc] init];
    
    [MobSDK clearUser];
    
    controller.CMSTitle = @"游客登录";
    controller.leftBarButtonItem = [self backItem];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)loginWithCustomUser
{
    CMSArticleListViewController *controller = [[CMSArticleListViewController alloc] init];
    
    [MobSDK setUserWithUid:@"uid-12345600"
                  nickName:@"自定义用户的名字"
                    avatar:@"http://tva1.sinaimg.cn/crop.0.2.508.508.180/006qwgkSjw8fbtm8a1ifej30e40e8q3f.jpg"
                  userData:nil];
    
    controller.CMSTitle = @"自定义用户";
    controller.leftBarButtonItem = [self backItem];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)loginWithUMSSDK
{
    __weak typeof(self) theController = self;
    [UMSSDK getUserInfoWithResult:^(UMSUser *user, NSError *error) {
        
        if (error == nil && user)
        {
            CMSArticleListViewController *controller = [[CMSArticleListViewController alloc] init];
            
            controller.CMSTitle = @"UMS用户";
            controller.leftBarButtonItem = [self backItem];
            [theController presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UMSLoginViewController *login = [[UMSLoginViewController alloc] init];
            login.leftBarButtonItem = [self backItem];
            login.loginHandler = ^(NSError *error){
                
                if (!error)
                {
                    [theController dismissViewControllerAnimated:YES completion:^{
                        
                        if ([UMSSDK currentUser])
                        {
                            CMSArticleListViewController *controller = [[CMSArticleListViewController alloc] init];
                            
                            controller.CMSTitle = @"UMS用户";
                            controller.leftBarButtonItem = [self backItem];
                            [theController presentViewController:controller animated:YES completion:nil];
                        }
                        
                    }];
                }
                
            };
            
            UMSBaseNavigationController *nav = [[UMSBaseNavigationController alloc] initWithRootViewController:login];
            [theController presentViewController:nav animated:YES completion:nil];
        }
    }];
}

@end

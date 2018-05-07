//
//  CMSArticleListViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MOBFoundation/MOBFUser.h>

/**
 *  文章列表控制器
 */
@interface CMSArticleListViewController : UIViewController

/**
 *  文章列表控制器总标题
 */
@property (nonatomic, copy) NSString *CMSTitle;

/**
 *  用户 (若传空,则以游客身份进入;用户可体现在发表评论等相关功能中)
 */
@property (nonatomic, strong) MOBFUser *user;

/**
 *  控制器导航栏左按钮
 */
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;

/**
 *  控制器导航栏右按钮
 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end

//
//  CMSCommentListViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/21.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMSSDK/CMSSDK.h>

/**
 *  评论列表控制器
 */
@interface CMSCommentListViewController : UIViewController

/**
 *  文章
 */
@property (nonatomic, strong) CMSSDKArticle *article;

@end

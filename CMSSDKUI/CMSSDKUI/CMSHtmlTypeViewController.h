//
//  CMSHtmlTypeViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMSSDK/CMSSDKArticle.h>

/**
 *  普通文章类型控制器
 */
@interface CMSHtmlTypeViewController : UIViewController

/**
 *  文章标识
 */
@property (nonatomic, copy) NSString *artileID;

/**
 *  初始化方法
 *
 *  @param articleID 文章标识
 *
 *  @return 实例对象
 */
- (instancetype)initWithArticleID:(NSString *)articleID;

@end

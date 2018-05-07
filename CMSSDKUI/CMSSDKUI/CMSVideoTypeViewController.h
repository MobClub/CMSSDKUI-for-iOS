//
//  CMSVideoTypeViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/12.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMSSDK/CMSSDK.h>
#import "CMSVideoPlayer.h"
@interface CMSVideoTypeViewController : UIViewController

/**
 *  文章ID
 */
@property (nonatomic, copy) NSString *artileID;

/**
 *  初始化方法
 *
 *  @param articleID 文章ID
 *
 *  @return 实例对象
 */
- (instancetype)initWithArticleID:(NSString *)articleID;

@end

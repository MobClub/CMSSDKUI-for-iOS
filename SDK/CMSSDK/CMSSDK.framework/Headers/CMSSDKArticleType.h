//
//  CMSSDKArticleType.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <JiMu/JIMUDataModel.h>
#import "CMSSDKArticle.h"

@interface CMSSDKArticleType : JIMUDataModel

/**
 *  分类ID
 */
@property (nonatomic, copy) NSString *typeID;

/**
 *  分类名称
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 *  分类序列
 */
@property (nonatomic, readonly) NSInteger order;

/**
 *  分类下文章数
 */
@property (nonatomic, readonly) NSInteger articleNumber;

/**
 制定文章类型，如果不设置，默认获取所有类型的文章
 */
@property (nonatomic, assign) CMSArticleType type;

@end

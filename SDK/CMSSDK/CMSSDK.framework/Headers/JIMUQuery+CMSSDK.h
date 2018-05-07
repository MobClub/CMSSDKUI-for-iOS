//
//  JIMUQuery+CMSSDK.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/3/8.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <JiMu/JiMu.h>

/**
 *  Query类目,用于快速获取CMSSDK的相关视图查询
 */
@interface JIMUQuery (CMSSDK)

/**
 *  获取文章类型查询
 *
 *  @return 查询对象
 */
+ (JIMUQuery *)articleTypesQuery;

/**
 *  获取文章列表查询
 *
 *  @return 查询对象
 */
+ (JIMUQuery *)articleListQuery;

/**
 *  获取文章评论列表查询
 *
 *  @return 查询对象
 */
+ (JIMUQuery *)commentListQuery;

/**
 *  获取文章列点赞状态查询
 *
 *  @return 查询对象
 */
+ (JIMUQuery *)praiseStatusQuery;

/**
 *  获取推荐文章列表查询
 *
 *  @return 查询对象
 */
+ (JIMUQuery *)recommendListQuery;

+ (JIMUQuery *)userBehaviorQuery;

@end

//
//  CMSSDK.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/2/20.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMSSDKTypeDefine.h"

#import "CMSSDKArticle.h"
#import "CMSSDKArticleType.h"
#import "CMSSDKComment.h"
#import "CMSSDKUserBehavior.h"

@interface CMSSDK : NSObject

/**
 *  获取文章类型列表
 *
 *  @param result 回调结果
 */
+ (void)getArticleTypes:(CMSSDKArticleTypesHandler)result;

/**
 *  获取某种类型的文章列表
 *
 *  @param articleType      文章类型
 *  @param pageNo           文章页码
 *  @param pageSize         文章数量
 *  @param result           回调结果
 */
+ (void)getArticleList:(CMSSDKArticleType *)articleType
                pageNo:(NSInteger)pageNo
              pageSize:(NSInteger)pageSize
                result:(CMSSDKArticleListHandler)result;

/**
 *  获取文章详情
 *
 *  @param articleID 文章ID
 *  @param result    回调结果
 */
+ (void)getArticleDetail:(NSString *)articleID
                  result:(CMSSDKArticleDetailHandler)result;

/**
 *  获取推荐相关文章列表
 *
 *  @param articleID 目标文章ID
 *  @param pageNo    文章页码
 *  @param pageSize  文章数量
 *  @param result    回调结果
 */
+ (void)getRecommendArticles:(NSString *)articleID
                      pageNo:(NSInteger)pageNo
                    pageSize:(NSInteger)pageSize
                      result:(CMSSDKArticleListHandler)result;

/**
 *  获取文章的评论列表
 *
 *  @param article  文章对象
 *  @param pageNo   文章页码
 *  @param pageSize 文章数量
 *  @param result   回调结果
 */
+ (void)getCommentsList:(CMSSDKArticle *)article
                 pageNo:(NSInteger)pageNo
               pageSize:(NSInteger)pageSize
                 result:(CMSSDKCommentsListHandler)result;

/**
 *  给某篇文章添加评论
 *
 *  @param comment   评论内容
 *  @param article   文章对象
 *  @param result    回调结果
 */
+ (void)addComment:(NSString *)comment
         toArticle:(CMSSDKArticle *)article
            result:(CMSSDKAddCommentHandler)result;

/**
 *  给某篇文章点赞
 *  @param airticle   文章对象
 *  @param result     回调结果
 */
+ (void)praiseArticle:(CMSSDKArticle *)article
               result:(CMSSDKPraiseHandler)result;

/**
 *  获取某篇文章对于某个用户的点赞状态
 *
 *  @param article 文章对象
 *  @param result  回调结果
 */
+ (void)checkArticlePraiseStatus:(CMSSDKArticle *)article
                          result:(CMSSDKPraiseStatusHandler)result;

/**
 获取某个用户的用户行为列表

 @param userID 用户id
 @param type 用户行为类型
 @param pageNo 页码
 @param pageSize 页数
 @param result 结果
 */
+ (void)getUserBehaviorWithUserID:(NSString *)userID
                 userBehaviorType:(CMSUserBehaviorType)type
                           pageNo:(NSInteger)pageNo
                         pageSize:(NSInteger)pageSize
                           result:(CMSSDKUserBehaviorListHandler)result;

/**
 获取某个文章的用户行为列表

 @param articleID 文章id
 @param type 用户行为类型
 @param pageNo 页码
 @param pageSize 页数
 @param result 结果
 */
+ (void)getUserBehaviorWithArticleID:(NSString *)articleID
                    userBehaviorType:(CMSUserBehaviorType)type
                              pageNo:(NSInteger)pageNo
                            pageSize:(NSInteger)pageSize
                              result:(CMSSDKUserBehaviorListHandler)result;

@end

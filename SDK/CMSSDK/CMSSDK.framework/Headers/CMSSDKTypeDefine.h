//
//  CMSSDKTypeDefine.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#ifndef CMSSDKTypeDefine_h
#define CMSSDKTypeDefine_h

@class MOBFUser;
@class CMSSDKArticle;
@class CMSSDKArticleType;
@class CMSSDKComment;
@class CMSSDKUserBehavior;

#define CMSSDKTimeOutError          700002
#define CMSSDKInvalidParamsError    700003
#define CMSSDKInvalidAppKeyError    700004
#define CMSSDKBussinessFailedError  700007
/**
 *  获取文章类型列表回调
 *
 *  @param typeList 文章列表
 *  @param error    错误
 */
typedef void(^CMSSDKArticleTypesHandler) (NSArray<CMSSDKArticleType *> *typeList, NSError *error);

/**
 *  获取文章列表回调
 *
 *  @param articleList 文章列表数组
 *  @param error       错误
 */
typedef void(^CMSSDKArticleListHandler) (NSArray<CMSSDKArticle *> *articleList,
                                         NSError *error);


/**
 *  获取文章详情回调
 *
 *  @param article 文章
 *  @param error   错误
 */
typedef void(^CMSSDKArticleDetailHandler) (CMSSDKArticle *article, NSError *error);

/**
 *  获取文章评论列表回调
 *
 *  @param commentsList 评论列表
 *  @param error        错误
 */
typedef void(^CMSSDKCommentsListHandler) (NSArray<CMSSDKComment *> *commentsList, NSError *error);

/**
 *  添加评论回调
 *
 *  @param newComment 所评论的内容
 *  @param error 错误（error为空即成功）
 */
typedef void(^CMSSDKAddCommentHandler) (CMSSDKComment *newComment, MOBFUser *user, NSError *error);

/**
 *  给文章点赞回调
 *
 *  @param error 错误（error为空即成功）
 */
typedef void(^CMSSDKPraiseHandler) (NSError *error);

/**
 *  检测文章是否被点赞回调
 *  
 *  @param isPraised 文章是否被点赞
 *  @param error 错误（error为空即成功）
 */
typedef void(^CMSSDKPraiseStatusHandler) (BOOL isPraised, NSError *error);

/**
 用户行为类型

 - CMSUserBehaviorTypeAll: 所有类型
 - CMSUserBehaviorTypeReading: 阅读
 - CMSUserBehaviorTypeComment: 评论
 - CMSUserBehaviorTypePraise: 点赞
 */
typedef NS_ENUM(NSInteger, CMSUserBehaviorType) {
    CMSUserBehaviorTypeAll = 0,
    CMSUserBehaviorTypeReading = 1,
    CMSUserBehaviorTypeComment = 2,
    CMSUserBehaviorTypePraise = 3,
};

/**
 获取用户行为列表
 
 @param userBehaviorList 用户行为列表
 @param error 错误
 */
typedef void(^CMSSDKUserBehaviorListHandler) (NSArray<CMSSDKUserBehavior *> *userBehaviorList, NSError *error);

#endif /* CMSSDKTypeDefine_h */

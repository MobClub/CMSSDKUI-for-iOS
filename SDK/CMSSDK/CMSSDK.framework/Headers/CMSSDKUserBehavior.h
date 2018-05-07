//
//  CMSSDKUserBehavior.h
//  CMSSDK
//
//  Created by 刘靖煌 on 2018/2/1.
//  Copyright © 2018年 Mob. All rights reserved.
//

#import <JiMu/JIMUDataModel.h>

/**
 用户行为对象，如点赞、阅读、评论
 */
@interface CMSSDKUserBehavior : JIMUDataModel

/**
 *  文章ID
 */
@property (nonatomic, copy, readonly) NSString *articleID;

/**
 *  文章标题
 */
@property (nonatomic, copy, readonly) NSString *articleTitle;

/**
 *  文章发布时间
 */
@property (nonatomic, readonly) NSTimeInterval updateAt;

/**
 文章分类
 */
@property (nonatomic, strong) NSArray<NSString *> *categoryName;

/**
 *  评论ID
 */
@property (nonatomic, copy, readonly) NSString *commentID;

/**
 评论内容
 */
@property (nonatomic, copy, readonly) NSString *commentContent;

/**
 *  文章阅读数
 */
@property (nonatomic, readonly) NSInteger readTimes;

/**
 *  文章评论数
 */
@property (nonatomic, readonly) NSInteger commentTimes;

/**
 *  文章点赞数
 */
@property (nonatomic, readonly) NSInteger praiseTimes;

/**
 *  Mob用户系统id
 */
@property (nonatomic, copy, readonly) NSString *mobUserId;

/**
 *  昵称
 */
@property (nonatomic, copy, readonly) NSString *nickname;

/**
 *  头像
 */
@property (nonatomic, copy, readonly) NSString *avatar;

/**
 *  自有系统的用户id
 */
@property (nonatomic, copy, readonly) NSString *appUserId;

@end

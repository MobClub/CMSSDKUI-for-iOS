//
//  CMSSDKArticle.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <JiMu/JIMUDataModel.h>

@interface CMSSDKArticle : JIMUDataModel

/**
 *  文章ID
 */
@property (nonatomic, copy, readonly) NSString *articleID;

/**
 *  文章标题
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 *  文章类型
 */
@property (nonatomic, readonly) NSInteger articleType;

/**
 *  文章展示类型
 */
@property (nonatomic, readonly) NSInteger displayType;

/**
 *  文章封面图列表
 */
@property (nonatomic, strong, readonly) NSArray *displayImgs;

/**
 *  文章标签
 */
@property (nonatomic, strong, readonly) NSArray *tags;

/**
 *  相关文章列表
 */
@property (nonatomic, strong, readonly) NSArray *categoryIds;

/**
 *  图片列表(仅当文章类型为 - 4图片文章 时才有)
 */
@property (nonatomic, strong, readonly) NSArray *imgList;

/**
 *  置顶状态 0=非置顶，1=当前分类下置顶，2=全部分类下置顶
 */
@property (nonatomic, readonly) NSInteger top;

/**
 *  是否热门
 */
@property (nonatomic, readonly) BOOL hot;

/**
 *  阅读次数
 */
@property (nonatomic, readonly) NSInteger readTimes;

/**
 *  评论数
 */
@property (nonatomic, readonly) NSInteger commentTimes;

/**
 *  称赞数
 */
@property (nonatomic, readonly) NSInteger praiseTimes;

/**
 *  是否允许评论
 */
@property (nonatomic, readonly) BOOL comment;

/**
 *  文章发布时间
 */
@property (nonatomic, readonly) NSTimeInterval updateAt;

/**
 *  图片文章数量
 */
@property (nonatomic, readonly) NSInteger imgSize;

/**
 *  视频地址(仅当文章类型为 - 3视频文章 时才有)
 */
@property (nonatomic, copy, readonly) NSString *videoUrl;

/**
 *  视频时长(仅当文章类型为 - 3视频文章 时才有)
 */
@property (nonatomic, readonly) NSInteger videoTime;

/**
 *  视频介绍(仅当文章类型为 - 3视频文章 时才有)
 */
@property (nonatomic, copy, readonly) NSString *videoDesc;

/**
 *  文章内容(当文章类型为：普通或站外跳转文章时，出现该字段。 普通文章：文章的具体内容;跳转文章：站外链接地址)
 */
@property (nonatomic, copy, readonly) NSString *content;

@end

//
//  CMSSDKComment.h
//  CMSSDK
//
//  Created by 陈剑东 on 17/2/20.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JiMu/JIMUDataModel.h>

@interface CMSSDKComment : JIMUDataModel

/**
 *  评论ID
 */
@property (nonatomic, copy, readonly) NSString *commentID;

/**
 *  所属文章ID
 */
@property (nonatomic, copy, readonly) NSString *articleID;

/**
 *  用户头像地址
 */
@property (nonatomic, copy, readonly) NSString *avatar;

/**
 *  用户昵称
 */
@property (nonatomic, copy, readonly) NSString *nickName;

/**
 *  评论内容
 */
@property (nonatomic, copy, readonly) NSString *content;

/**
 *  评论时间
 */
@property (nonatomic, readonly) NSTimeInterval updateAt;

@end

//
//  JIMUQuery+UMS.h
//  UMSSDK
//
//  Created by 刘靖煌 on 17/3/10.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <JiMu/JiMu.h>

/**
 数据查询类
 */
@interface JIMUQuery (UMS)

/**
 用户数据查询

 @return 用户数据查询结果
 */
+ (JIMUQuery *)usersQuery;

/**
 绑定数据查询

 @return 绑定数据查询结果
 */
+ (JIMUQuery *)bindingDataQuery;

/**
 好友列表查询

 @return 好友列表查询结果
 */
+ (JIMUQuery *)friendListQuery;

/**
 好友申请查询

 @return 好友申请结果
 */
+ (JIMUQuery *)addFriendRequestQuery;

/**
 好友申请列表查询
 */
+ (JIMUQuery *)invitedFriendListQuery;

/**
 用户黑名单查询

 @return 黑名单查询结果
 */
+ (JIMUQuery *)blockUserQuery;

/**
 粉丝列表查询
 
 @return 粉丝列表查询结果
 */
+ (JIMUQuery *)fansListQuery;

@end

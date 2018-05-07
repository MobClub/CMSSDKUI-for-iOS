//
//  UMSVip.h
//  UMSSDK
//
//  Created by wukx on 2017/12/25.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JiMu/JIMUDataModel.h>

@interface UMSVip : JIMUDataModel

/**
 *  vip 产品规格 ID
 */
@property (nonatomic, copy) NSString *vipProductSpeciId;

/**
 *  vip 产品标识
 */
@property (nonatomic, copy) NSString *vipProductMark;

/**
 *  vip 产品规格 名称
 */
@property (nonatomic, copy) NSString *vipProductSpeciName;

/**
 *  vip 过期时间
 */
@property (nonatomic, assign) NSTimeInterval expireTime;

/**
 *  vip 是否免费领取
 */
@property (nonatomic, assign) BOOL free;

@end

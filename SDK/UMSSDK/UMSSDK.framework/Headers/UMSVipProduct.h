//
//  UMSVipProduct.h
//  UMSSDK
//
//  Created by wukx on 2017/12/25.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JiMu/JIMUDataModel.h>

@class UMSVipProductSpeci;

@interface UMSVipProduct : JIMUDataModel

/**
 *  vip 产品ID
 */
@property (nonatomic, copy) NSString *vipProductId;

/**
 *  vip 产品标识
 */
@property (nonatomic, copy) NSString *vipProductMark;

/**
 *  vip 产品名称
 */
@property (nonatomic, copy) NSString *vipProductName;

/**
 *  vip 产品规格列表
 */
@property (nonatomic, strong) NSMutableArray<UMSVipProductSpeci *> *vipProductSpeciList;

@end


// vip 产品规格
@interface UMSVipProductSpeci : JIMUDataModel

/**
 *  vip 产品规格 ID
 */
@property (nonatomic, copy) NSString *vipProductSpeciId;

/**
 *  vip 产品规格 名称
 */
@property (nonatomic, copy) NSString *vipProductSpeciName;

/**
 *  vip 产品规格 价格 单位分
 */
@property (nonatomic, assign)NSUInteger  vipProductSpeciPrice;

/**
 *  vip 会员时长 单位毫秒
 */
@property (nonatomic, assign)NSUInteger duration;

/**
 *  1-注册时免费赠送 ,2-免费领取
 */
@property (nonatomic, assign) NSInteger freeWay;

/**
 *  vip 是否免费
 */
@property (nonatomic, assign) BOOL free;

@end

//
//  UMSVipOrder.h
//  UMSSDK
//
//  Created by wukx on 2017/12/27.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JiMu/JIMUDataModel.h>

@interface UMSVipOrder : JIMUDataModel

/**
 *  订单ID
 */
@property (nonatomic, assign) NSInteger orderId;

/**
 *  vip 产品规格 ID
 */
@property (nonatomic, copy) NSString *vipProductSpeciId;

/**
 *  vip 产品规格 名称
 */
@property (nonatomic, copy) NSString *vipProductSpeciName;

/**
 *  订单金额 单位分100=1元
 */
@property (nonatomic, assign) NSUInteger amount;

/**
 *  1-等待支付，2-支付成功，3-支付失败
 */
@property (nonatomic, assign) NSInteger status;

/**
 *  支付渠道 22-微信支付，50支付宝支付
 */
@property (nonatomic, assign) NSInteger channel;

/**
 *  付款时间
 */
@property (nonatomic, strong) NSDate *payAt;

/**
 *  更新时间
 */
@property (nonatomic, strong) NSDate *updateAt;

/**
 *  vip 是否免费领取
 */
@property (nonatomic, assign) BOOL isFree;

/**
 *  消费用户昵称
 */
@property (nonatomic, copy) NSString *nickname;

@end

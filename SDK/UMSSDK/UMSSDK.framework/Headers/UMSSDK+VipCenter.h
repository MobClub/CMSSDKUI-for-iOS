//
//  UMSSDK+VipCenter.h
//  UMSSDK
//
//  Created by wukx on 2017/12/25.
//  Copyright © 2017年 mob.com. All rights reserved.
//

#import <UMSSDK/UMSSDK.h>
#import "UMSTypeDefine.h"
#import "UMSVip.h"
#import "UMSVipProduct.h"
#import "UMSVipOrder.h"

@interface UMSSDK (VipCenter)

#pragma mark -
#pragma mark 会员中心

/**
 获取注册的用户订购的所有类型的会员信息(用户可以订购多个会员种类)
 
 @param handler 获取用户会员资料结果
 */
+ (void)getVipInfoWithResult:(UMSGetVipInfoResult)handler;

/**
 获取所有会员产品信息
 
 @param handler 获取会员产品数据列表
 */
+ (void)getVipProductListWithResult:(UMSGetVipProductListResult)handler;

/**
 创建订单(购买会员)
 
 @param speciId   订购会员产品规格ID
 @param type      标识是否是免费 1-免费 ， 2-非免费
 @param handler   创建订单(购买会员)回调
 */
+ (void)createOrderWithSpeciId:(NSString *)speciId
                          type:(NSInteger)type
                        result:(UMSCreateVipOrderResult)handler;

/**
 提交订单并支付
 
 @param orderId 订单ID
 @param channel 支付SDK目前支持的支付渠道 22-微信 50-支付宝
 @param handler 订单预支付回调
 */
+ (void)sumbitOrderToPayWithOrderId:(NSString *)orderId
                            channel:(NSInteger)channel
                             result:(UMSPayOrderResult)handler;

/**
 购买会员交易记录
 
 @param user     用户
 @param pageNum  第pageNum条开始
 @param pageSize 条数
 @param handler  结果
 */
+ (void)getOrderRecordWithUser:(UMSUser *)user
                       pageNum:(NSUInteger)pageNum
                      pageSize:(NSUInteger)pageSize
                        result:(UMSOrderRecordResult)handler;

/**
 通过订单号获取订单信息
 
 @param user     用户
 @param orderId  订单号
 */
+ (void)getOrderInfoWithUser:(UMSUser *)user
                     orderId:(NSString *)orderId
                      result:(UMSOrderInfoResult)handler;

@end

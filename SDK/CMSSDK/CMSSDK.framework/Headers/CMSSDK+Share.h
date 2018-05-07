//
//  CMSSDK+Share.h
//  CMSSDK
//
//  Created by 陈剑东 on 2017/9/19.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <CMSSDK/CMSSDK.h>
#import <UIKit/UIKit.h>

@interface CMSSDK (Share)

/**
 是否支持分享
 
 @return 是/否
 */
+ (BOOL)isSupportShare;

/**
 *  分享内容
 *
 *  @param platformType             平台类型
 *  @param parameters               分享参数
 *  @param stateChangedHandler       状态变更回调处理
 */
+ (void) share:(NSInteger)platformType
    parameters:(NSMutableDictionary *)parameters
onStateChanged:(void (^)(NSInteger state, NSDictionary *userData, NSDictionary *contentEntity,  NSError *error))stateChangedHandler;


/**
 通过菜单分享
 
 @param view 锚点视图
 @param url 文章的分享链接地址
 @param imageUrl 图片链接
 @param title 标题
 @param text 文本
 @param shareStateChangedHandler 回调
 */
+ (void)showShareActionSheet:(UIView *)view
                       items:(NSArray *)items
                         url:(NSString *)url
                    imageUrl:(NSString *)imageUrl
                       title:(NSString *)title
                        text:(NSString *)text
         onShareStateChanged:(void (^) (NSInteger state,
                                        NSInteger platformType,
                                        NSDictionary *userData,
                                        NSDictionary *contentEntity,
                                        NSError *error,
                                        BOOL end))shareStateChangedHandler;

@end

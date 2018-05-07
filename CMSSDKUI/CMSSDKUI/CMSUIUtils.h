//
//  CMSUIUtils.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/27.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MOBFoundation/MOBFUser.h>
#import <MOBFoundation/MOBFImageGetter.h>
@interface CMSUIUtils : NSObject

/**
 *  用户
 */
@property (nonatomic, strong) MOBFUser *user;

/**
 *  获取单例
 *
 *  @return 单例对象
 */
+ (CMSUIUtils *)sharedInstance;

/**
 *  展示评论编辑界面
 *
 *  @param controller 目标控制器
 *  @param result     回调
 */
+ (void)presentToCommentEditFromController:(UIViewController *)controller result:(void (^)(BOOL isSend, NSString *comment))result;

/**
 *  获取CMSSDKUI.bundle路径
 *
 *  @return 路径
 */
+ (NSString *)UIBundleResourcePath;

/**
 *  评论成功提示
 *
 *  @param view 容器视图
 */
+ (void)showCommentSuccessAlertInView:(UIView *)view;

/**
 *  禁止评论提示
 *
 *  @param view 容器视图
 */
+ (void)showCommentNotAllowedAlertInView:(UIView *)view;

/**
 *  评论失败提示
 *
 *  @param view 容器视图
 */
+ (void)showCommentFailedAlertInView:(UIView *)view;

/**
 *  分享结果提示
 *
 *  @param view 容器视图
 */
+ (void)showShareResultInView:(UIView *)view withState:(NSUInteger)state;


/**
 *  获取字符串高度
 *
 *  @param width 宽度
 *  @param title 文本内容
 *  @param font  字体尺寸
 *
 *  @return 高度
 */
+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font;

/**
 *  获取表格图片获取器 (UITableViewCell专用)
 *
 *  @return 图片获取器
 */
+ (MOBFImageGetter *)cellImageGetter;

+ (BOOL)isIPhoneX;

@end

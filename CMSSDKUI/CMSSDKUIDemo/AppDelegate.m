//
//  AppDelegate.m
//  CMSSDKUIDemo
//
//  Created by 陈剑东 on 17/2/27.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "AppDelegate.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ShareSDK registerActivePlatforms:@[
                                        @(SSDKPlatformTypeSinaWeibo),
                                        @(SSDKPlatformTypeFacebook),
                                        @(SSDKPlatformTypeQQ),
                                        @(SSDKPlatformTypeMail),
                                        @(SSDKPlatformSubTypeWechatSession),
                                        @(SSDKPlatformSubTypeWechatTimeline),
                                        ]
                             onImport:^(SSDKPlatformType platformType) {
                                 
                                 switch (platformType)
                                 {
                                     case SSDKPlatformTypeWechat:
                                         [ShareSDKConnector connectWeChat:[WXApi class]];
                                         break;
                                     case SSDKPlatformTypeQQ:
                                         [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                                         break;
                                     case SSDKPlatformTypeSinaWeibo:
                                         [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                                         break;
                                     default:
                                         break;
                                 }
                                 
                             }
                      onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
                          
                          switch (platformType)
                          {
                              case SSDKPlatformTypeSinaWeibo:
                                  //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                                  [appInfo SSDKSetupSinaWeiboByAppKey:@"1065584115"
                                                            appSecret:@"ca6260e975e1ccd0787216f12adf7de6"
                                                          redirectUri:@"http://cmssdk.mob.com"
                                                             authType:SSDKAuthTypeBoth];
                                  break;
                              case SSDKPlatformTypeFacebook:
                                  //设置Facebook应用信息，其中authType设置为只用SSO形式授权
                                  [appInfo SSDKSetupFacebookByApiKey:@"139095546583473"
                                                           appSecret:@"7a88cd42e2a6ac171606df65f9c2738b"
                                                         displayName:@"CMSSDK"
                                                            authType:SSDKAuthTypeBoth];
                                  break;
                              case SSDKPlatformTypeWechat:
                                  [appInfo SSDKSetupWeChatByAppId:@"wxb4de64c75a0924bf"
                                                        appSecret:@"c57c9b8cd22383612e79d1881c3f9942"];
                                  break;
                              case SSDKPlatformTypeQQ:
                                  [appInfo SSDKSetupQQByAppId:@"1106255273"
                                                       appKey:@"BGyUOnkOROW8IFid"
                                                     authType:SSDKAuthTypeBoth];
                                  break;
                              default:
                                  break;
                          }
                      }];
    return YES;
}

@end

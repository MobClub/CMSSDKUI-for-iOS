//
//  CMSSDKComment+Cell.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/14.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <CMSSDK/CMSSDK.h>
#import <UIKit/UIKit.h>
/**
 *  CMSSDKComment类目
 *  专用于计算评论列表单元高度
 */
@interface CMSSDKComment (Cell)

/**
 *  获取评论对应的单元高度
 *
 *  @return 高度
 */
- (CGFloat)theCellHeight;

@end

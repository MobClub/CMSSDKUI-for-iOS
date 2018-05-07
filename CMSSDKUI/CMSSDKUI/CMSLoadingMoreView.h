//
//  CMSLoadingMoreView.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/4/10.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRPLoadingSpinner.h"
/**
 *  加载更多视图
 */
@interface CMSLoadingMoreView : UIView

@property (nonatomic, retain) DRPLoadingSpinner *spinner;
@property (nonatomic, retain) UILabel *tipsLabel;

/**
 *  开始动画
 */
- (void)startAnimation;

/**
 *  结束动画
 */
- (void)stopAnimation;

/**
 *  是否展示动画
 *
 *  @return 状态
 */
- (BOOL)isAnimating;

/**
 *  没有更多数据
 */
- (void)noMoreData;

/**
 *  重新录入数据
 */
- (void)restartLoadData;

@end

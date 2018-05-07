//
//  CMSRefreshItem.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CMSRefreshItem : NSObject

- (instancetype)initWithView:(UIView *)view
                   centerEnd:(CGPoint)centerEnd
               parallaxRatio:(CGFloat)parallaxRatio
                 sceneHeight:(CGFloat)sceneHeight;

- (void)centerForProgress:(CGFloat)progress;

@property (nonatomic, weak) UIView *view;


@end

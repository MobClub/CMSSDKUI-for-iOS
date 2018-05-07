//
//  CMSRefreshItem.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSRefreshItem.h"

@interface CMSRefreshItem ()

@property (nonatomic, assign) CGPoint centerStart;

@property (nonatomic, assign) CGPoint centerEnd;

@end

@implementation CMSRefreshItem

- (instancetype)initWithView:(UIView *)view
                   centerEnd:(CGPoint)centerEnd
               parallaxRatio:(CGFloat)parallaxRatio
                 sceneHeight:(CGFloat)sceneHeight
{
    self = [super init];
    if (self)
    {
        _centerEnd = centerEnd;
        _centerStart = CGPointMake(centerEnd.x, centerEnd.y + (parallaxRatio * sceneHeight));
        _view = view;
        _view.center = _centerStart;
    }
    return self;
}

- (void)centerForProgress:(CGFloat)progress
{
    self.view.center = CGPointMake(self.centerStart.x + ((self.centerEnd.x - self.centerStart.x) * progress),
                                   self.centerStart.y + ((self.centerEnd.y - self.centerStart.y) * progress));
}


@end

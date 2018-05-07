//
//  CMSNavigationController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/1.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSNavigationController.h"
#import "CMSMainViewController.h"
@interface CMSNavigationController ()

@end

@implementation CMSNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end

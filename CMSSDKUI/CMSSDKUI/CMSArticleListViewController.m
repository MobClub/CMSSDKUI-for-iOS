//
//  CMSArticleListViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSArticleListViewController.h"
#import "CMSNavigationController.h"
#import "CMSMainViewController.h"
#import "CMSUIUtils.h"

@interface CMSArticleListViewController ()

@property (nonatomic) BOOL isVideoTypeControllerHideStatusBar;

@property (nonatomic, strong) CMSNavigationController *navi;

@end

@implementation CMSArticleListViewController


- (instancetype)init
{
    if (self = [super init])
    {
        CMSMainViewController *cmsVC = [[CMSMainViewController alloc] init];
        
        self.navi = [[CMSNavigationController alloc] initWithRootViewController:cmsVC];
        [self addChildViewController:self.navi];
        self.isVideoTypeControllerHideStatusBar = NO;
    }
    return self;
}

- (void)setUser:(MOBFUser *)user
{
    _user = user;
    [CMSUIUtils sharedInstance].user = user;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.navi.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_didChagneOrientation:)
                                                 name:@"VideoTypeControllerHideStatusBar"
                                               object:nil];
    
}

- (void)_didChagneOrientation:(NSNotification *)notif
{
    BOOL isHide = [notif.object boolValue];
    self.isVideoTypeControllerHideStatusBar = isHide;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.isVideoTypeControllerHideStatusBar)
    {
        return YES;
    }
    
    return NO;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    //必须要返回子控制器(这里是CMSNavigationController)
    return self.childViewControllers[0];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

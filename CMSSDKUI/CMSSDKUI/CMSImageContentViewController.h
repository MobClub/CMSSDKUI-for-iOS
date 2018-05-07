//
//  CMSImageContentViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 2017/4/20.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  图片详情控制器
 */
@interface CMSImageContentViewController : UIViewController

/**
 *  图片地址
 */
@property (nonatomic, strong) NSURL *imageURL;

/**
 *  当前图片下标
 */
@property (nonatomic) NSInteger current;

@end

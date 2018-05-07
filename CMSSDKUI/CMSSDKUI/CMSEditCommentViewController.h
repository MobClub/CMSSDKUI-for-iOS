//
//  CMSEditCommentViewController.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/13.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  评论编辑控制器
 */
@interface CMSEditCommentViewController : UIViewController

/**
 *  编辑控制器回调
 */
@property (nonatomic, copy) void (^editResult) (BOOL isSend, NSString *comment);

@end

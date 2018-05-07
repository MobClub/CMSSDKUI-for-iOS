//
//  CMSCommentCell.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/14.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMSSDK/CMSSDKComment.h>

/**
 *  评论列表单元
 */
@interface CMSCommentCell : UITableViewCell

/**
 *  设置评论内容
 *
 *  @param comment 评论对象
 */
- (void)setComment:(CMSSDKComment *)comment;

@end

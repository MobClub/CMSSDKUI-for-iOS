//
//  CMSSDKArticle+Cell.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/9.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <CMSSDK/CMSSDKArticle.h>
#import <UIKit/UIKit.h>

@interface CMSSDKArticle (Cell)

//获取本文章对应的cellID
- (NSString *)cellIdentifier;

//获取对应cell高度
//- (CGFloat)theCellHeight;

@end

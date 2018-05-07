//
//  CMSBaseCell.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CMSSDK/CMSSDKArticle.h>

#import <MOBFoundation/MOBFoundation.h>
#import "View+MASAdditions.h"
#import "CMSUIUtils.h"

@interface CMSBaseCell : UITableViewCell

- (void)setUpUI;

- (void)setArticle:(CMSSDKArticle *)article withTitleHeight:(CGFloat)titleHeight;

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font;

- (NSArray *)sortDataArray:(NSArray *)displayImgs;

- (void)setHasBeenRead;

@end

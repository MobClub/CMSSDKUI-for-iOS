//
//  CMSSDKComment+Cell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/14.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSSDKComment+Cell.h"

@implementation CMSSDKComment (Cell)

- (CGFloat)theCellHeight
{
    CGFloat otherHeight = 80;//头像以及其他间隙的总高度
    CGFloat textHeight = [self getHeightByWidth:ScreenW - 65 title:self.content font:[UIFont systemFontOfSize:CMSUICommentContentFontSize]];
    
    return otherHeight + textHeight;
}

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

@end

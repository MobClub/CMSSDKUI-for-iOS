//
//  CMSUIUtils.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/27.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSUIUtils.h"
#import "CMSEditCommentViewController.h"
#import "View+MASAdditions.h"

#import <MOBFoundation/MOBFImageCachePolicy.h>
#import <MOBFoundation/MOBFImage.h>

@implementation CMSUIUtils

+ (CMSUIUtils *)sharedInstance
{
    static CMSUIUtils *_utils;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utils = [[CMSUIUtils alloc] init];
    });

    return _utils;
}

+ (void)presentToCommentEditFromController:(UIViewController *)controller result:(void (^)(BOOL, NSString *))result
{
    controller.definesPresentationContext = YES;
    CMSEditCommentViewController *commentEditor = [[CMSEditCommentViewController alloc] init];
    commentEditor.modalPresentationStyle = UIModalPresentationCustom;
    
    if (result)
    {
        commentEditor.editResult = [result copy];
    }
    
    [controller presentViewController:commentEditor animated:NO completion:nil];
}

+ (NSString *)UIBundleResourcePath
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    return sourceBundle.resourcePath;
}

+ (void)showCommentSuccessAlertInView:(UIView *)view
{
    UIView *containView = [[UIView alloc] init];
    containView.center = view.center;
    containView.layer.cornerRadius = 5;
    containView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/cg",[self UIBundleResourcePath]];
    imageView.image = [UIImage imageWithContentsOfFile:imgPath];
    [containView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.text = @"发送成功";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
    [containView addSubview:label];
    
    [view addSubview:containView];
    
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-100);
        make.height.mas_equalTo(120);
        make.width.mas_equalTo(120);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containView.mas_centerX);
        make.top.equalTo(containView.mas_top).with.offset(20);
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(38);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(containView.mas_centerX);
        make.top.equalTo(imageView.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    
    
    containView.alpha = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        containView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:^{
            containView.alpha = 0;
        } completion:^(BOOL finished) {
            [containView removeFromSuperview];
        }];
    }];

}

+ (void)showCommentNotAllowedAlertInView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"本文章禁止评论";
    label.textColor = [UIColor whiteColor];
    label.layer.cornerRadius = 5;
    label.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-50);
    }];
    
    label.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];

}

+ (void)showCommentFailedAlertInView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"评论失败";
    label.textColor = [UIColor whiteColor];
    label.layer.cornerRadius = 5;
    label.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-50);
    }];
    
    label.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];

}

+ (void)showShareResultInView:(UIView *)view withState:(NSUInteger)state
{
    //只对成功失败取消进行处理
    if (state == 0 || state == 4)
    {
        return;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString *result = nil;
    
    switch (state)
    {
        case 1:
            result = @"分享成功";
            break;
        case 2:
            result = @"分享失败";
            break;
        case 3:
            result = @"取消分享";
            break;
    }
    
    label.text = result;
    label.textColor = [UIColor whiteColor];
    label.layer.cornerRadius = 5;
    label.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY).with.offset(-50);
    }];
    
    label.alpha = 0;
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:1 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
    
}


+ (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 2;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

+ (MOBFImageGetter *)cellImageGetter
{
    static MOBFImageGetter *getter;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        MOBFImageCachePolicy *policy =  [[MOBFImageCachePolicy alloc] init];
        policy.cacheName = @"CMSSDK_CellImage";
        policy.cacheHandler = ^NSData *(NSData *imageData) {
            
            UIImage *image = [UIImage imageWithData:imageData];
            if (image.size.width > ScreenW * 2)
            {
                 image = [MOBFImage scaleImage:image withSize:CGSizeMake(ScreenW * 2, ScreenW * 2)];
            }
            
            NSData *data = UIImageJPEGRepresentation(image, 0.5);
            if (data.length > imageData.length)
            {
                return imageData;
            }
            
            return data;
        };

        getter = [[MOBFImageGetter alloc] initWithCachePolicy:policy];
    });
    
    return getter;
}
+ (BOOL)isIPhoneX
{
    if (ScreenW == 375 && ScreenH == 812)
    {
        return YES;
    }

    return NO;
}

@end

//
//  CMSRefreshView.h
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMSRefreshView;

@protocol CMSRefreshViewDelegate <NSObject>

- (void)refreshViewDidRefresh:(CMSRefreshView *)refreshView;

@end

@interface CMSRefreshView : UIView<UIScrollViewDelegate>

@property (nonatomic, weak) id <CMSRefreshViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView;

- (void)beginRefreshing;

- (void)endRefreshing;

@end

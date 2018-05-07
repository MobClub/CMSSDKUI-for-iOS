//
//  CMSRefreshView.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSRefreshView.h"
#import "CMSRefreshItem.h"
#import "DRPLoadingSpinner.h"
#import <MOBFoundation/MOBFColor.h>

static CGFloat kSceneHeight = 70.f;

@interface CMSRefreshView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat progress;

@property (strong, nonatomic) NSMutableArray *refreshItems;
@property (assign, nonatomic) BOOL refreshing;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) DRPLoadingSpinner *spin;
@property (strong, nonatomic) UIImageView *sign;
@property (strong, nonatomic) CMSRefreshItem *readyItem;
@property (assign, nonatomic) BOOL showingReadyItem;

@end

@implementation CMSRefreshView

- (instancetype)initWithFrame:(CGRect)frame scrollView:(UIScrollView *)scrollView
{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollView = scrollView;
        _refreshItems = [NSMutableArray array];
//        _scrollView.backgroundColor = [MOBFColor colorWithRGB:0xF4F5F6];
//        self.backgroundColor = [MOBFColor colorWithRGB:0xF4F5F6];

        [self setupItems];
    }
    return self;
}

- (void)setupItems
{
    //refresh
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
    self.textLabel.text = @"下拉刷新";
    self.textLabel.font = [UIFont systemFontOfSize:13];
    self.textLabel.textColor = [MOBFColor colorWithRGB:0x999999];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    CMSRefreshItem *item1 = [[CMSRefreshItem alloc] initWithView:self.textLabel centerEnd:CGPointMake(ScreenW /2, kSceneHeight - 20)parallaxRatio:0.f sceneHeight:kSceneHeight];
    
    [self addRefreshItem:item1];
    
    self.spin = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    self.spin.maximumArcLength = 6.28;
    self.spin.rotationCycleDuration = 1.0;
    self.spin.drawCycleDuration = 0.75;
    self.spin.drawTimingFunction = [DRPLoadingSpinnerTimingFunction sharpEaseInOut];
    self.spin.colorSequence = @[[UIColor redColor]];
    CMSRefreshItem *item2 = [[CMSRefreshItem alloc] initWithView:self.spin centerEnd:CGPointMake(ScreenW /2, kSceneHeight - 50) parallaxRatio:0.f sceneHeight:kSceneHeight];
    
    [self addRefreshItem:item2];

}
- (void)addRefreshItem:(CMSRefreshItem *)item
{
    [self addSubview:item.view];
    [self.refreshItems addObject:item];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (self.refreshing) return;

    if (-scrollView.contentOffset.y > 0)
    {
        //refresh
        CGFloat visibleHeight = MAX(-scrollView.contentOffset.y - scrollView.contentInset.top, 0);
        self.progress = MIN(MAX(visibleHeight / kSceneHeight, 0.f), 1.f);
    }
    
    if (self.progress >= 1.0 )
    {
        self.spin.staticArcLength = self.spin.maximumArcLength;
        self.textLabel.text = @"松开刷新";
    }
    else
    {
        CGFloat length = self.progress * 6.28;
        self.spin.staticArcLength = length;
        self.textLabel.text = @"下拉刷新";
    }
    
//    else
//    {
//        //load more
//        CGFloat visibleHeight = MAX(scrollView.frame.size.height - scrollView.contentSize.height  + scrollView.contentOffset.y, 0);
//        self.progress = -MIN(MAX(visibleHeight / kLoadMoreHeight, 0.f), 1.f);
//    }
    
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (self.progress >= 1.f)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewDidRefresh:)])
        {
            [self beginRefreshing];
            *targetContentOffset = CGPointMake(0, -self.scrollView.contentInset.top);
            [self.delegate refreshViewDidRefresh:self];
        }
    }
//    else if (self.progress <= -1.f)
//    {
//        
//        if (self.delegate && [self.delegate respondsToSelector:@selector(refreshViewDidLoadingMore:)])
//        {
//            [self beginLoadingMore];
//            *targetContentOffset = CGPointMake(0,scrollView.contentOffset.y);
//            [self.delegate refreshViewDidLoadingMore:self];
//        }
//    }
    
    
}

- (void)beginRefreshing
{
    self.refreshing = YES;
    self.textLabel.text = @"刷新中";
    [self.spin startAnimating];
    
    __weak typeof(self) theView = self;
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        UIEdgeInsets newInsets = theView.scrollView.contentInset;
        newInsets.top += kSceneHeight;
        [theView.scrollView setContentInset:newInsets];
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self showReadyItem:NO];
}

- (void)endRefreshing
{
    __weak typeof(self) theView = self;
    [UIView animateWithDuration:0.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        UIEdgeInsets newInsets = theView.scrollView.contentInset;
        newInsets.top -= kSceneHeight;
        [theView.scrollView setContentInset:newInsets];
        
    } completion:^(BOOL finished) {
        
        theView.refreshing = NO;
        self.textLabel.text = @"下拉刷新";
        [theView.spin stopAnimating];
    }];
    
}

- (void)showReadyItem:(BOOL)show
{
    if (self.showingReadyItem == show) return;
    
    __weak typeof(self) theView = self;
    self.showingReadyItem = show;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        [theView.readyItem centerForProgress:show ? 1.f : 0.f];
    } completion:nil];
}

@end

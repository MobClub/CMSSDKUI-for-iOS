//
//  CMSLoadingMoreView.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/4/10.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSLoadingMoreView.h"

@implementation CMSLoadingMoreView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.spinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, frame.size.height - 5, frame.size.height - 5)];
        self.spinner.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.spinner.rotationCycleDuration = 1.5;
        self.spinner.drawCycleDuration = 0.75;
        self.spinner.drawTimingFunction = [DRPLoadingSpinnerTimingFunction sharpEaseInOut];
        self.spinner.colorSequence = @[[UIColor grayColor]];
        [self addSubview:self.spinner];
        
        self.tipsLabel = [[UILabel alloc] initWithFrame:frame];
        self.tipsLabel.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.tipsLabel.text = @"没有更多数据";
        self.tipsLabel.hidden = YES;
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.textColor = [UIColor lightGrayColor];
        self.tipsLabel.font = [UIFont systemFontOfSize:14.0];;
        [self addSubview: self.tipsLabel];

//        self.backgroundColor = [UIColor whiteColor];
        
    }
    
    return self;
}


- (void)startAnimation
{
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    self.tipsLabel.hidden = YES;
}

- (void)stopAnimation
{
    if (self.spinner.isAnimating == NO)
    {
        return;
    }
    
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
}

- (BOOL)isAnimating
{
    return self.spinner.isAnimating;
}

- (void)noMoreData
{
    self.tipsLabel.hidden = NO;
}

- (void)restartLoadData
{
    self.tipsLabel.hidden = YES;
}
@end

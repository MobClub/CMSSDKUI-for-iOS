//
//  CMSBaseCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSBaseCell.h"

@interface CMSBaseCell ()


@property (nonatomic, weak) UILabel *topLabel;

@property (nonatomic, weak) UILabel *hotLabel;

@property (nonatomic, weak) UILabel *commentAndTimeLabel;

@property (nonatomic, weak) UIView *lineView;

@end

@implementation CMSBaseCell

#pragma mark - Public Method
- (void)setUpUI
{
    //View上限为90

    UIView *contentView = self.contentView;

    UILabel *topL = [[UILabel alloc] init];
    topL.textAlignment = NSTextAlignmentCenter;
    topL.font = [UIFont systemFontOfSize:10];
    topL.text = @"置顶";
    topL.textColor = [MOBFColor colorWithRGB:0xE66159];
    topL.layer.cornerRadius = 5;
    topL.layer.borderWidth = 0.5;
    topL.layer.borderColor = [MOBFColor colorWithRGB:0xE66159].CGColor;
    
    UILabel *hotL = [[UILabel alloc] init];
    hotL.textAlignment = NSTextAlignmentCenter;
    hotL.font = [UIFont systemFontOfSize:10];
    hotL.text = @"热";
    hotL.textColor = [MOBFColor colorWithRGB:0xE66159];
    hotL.layer.cornerRadius = 5;
    hotL.layer.borderWidth = 0.5;
    hotL.layer.borderColor = [MOBFColor colorWithRGB:0xE66159].CGColor;
    
    
    UILabel *commentAndTimeLabel = [[UILabel alloc] init];
    commentAndTimeLabel.font = [UIFont systemFontOfSize:12];
    commentAndTimeLabel.textColor = [MOBFColor colorWithRGB:0x999999];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = [MOBFColor colorWithRGB:0xE1E1E1];
    
    self.topLabel = topL;
    self.hotLabel = hotL;
    self.commentAndTimeLabel = commentAndTimeLabel;
    self.lineView = lineV;
    
    [contentView addSubview:topL];
    [contentView addSubview:hotL];
    [contentView addSubview:commentAndTimeLabel];
    [contentView addSubview:lineV];
    
    [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).with.offset(CellBorderWidth);
        make.right.equalTo(contentView).with.offset(-CellBorderWidth);
        make.bottom.equalTo(contentView).with.offset(-1);
        make.height.mas_equalTo(@0.5);
    }];
    
}
- (void)setArticle:(CMSSDKArticle *)article withTitleHeight:(CGFloat)titleHeight
{
    __weak typeof(self) theCell = self;
    
    CGFloat leftImgOffset = 0 ;
    if (article.displayType == 1) leftImgOffset = 140;
    
    CGFloat sideOffset = CellBorderWidth;
    
    if (article.top == 0)
    {
        self.topLabel.hidden = YES;
    }
    else
    {
        self.topLabel.hidden = NO;
        sideOffset += 40;
    }
    
    if (article.hot)
    {
        self.hotLabel.hidden = NO;
        sideOffset += 25;
    }
    else
    {
        self.hotLabel.hidden = YES;
    }
    
    if (article.top == 0)
    {
        if (article.hot)
        {
            [self.hotLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(theCell.contentView.mas_left).with.offset(CellBorderWidth + leftImgOffset);
                make.bottom.equalTo(theCell.contentView.mas_bottom).with.offset(-10);
                make.height.mas_equalTo(@15);
                make.width.mas_equalTo(@20);
                
            }];
        }
    }
    else
    {
    
        [self.topLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(theCell.contentView.mas_left).with.offset(CellBorderWidth + leftImgOffset);
            make.bottom.equalTo(theCell.contentView.mas_bottom).with.offset(-10);
            make.height.mas_equalTo(@15);
            make.width.mas_equalTo(@30);
            
            
        }];
        
        if (article.hot)
        {
            [self.hotLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                
                make.left.equalTo(theCell.topLabel.mas_right).with.offset(10);
                make.centerY.equalTo(theCell.topLabel.mas_centerY);
                make.height.equalTo(theCell.topLabel.mas_height);
                make.width.mas_equalTo(@20);
                
            }];
            
        }

    }
    
    [self.commentAndTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(theCell.contentView.mas_left).with.offset(sideOffset + leftImgOffset);
        make.bottom.equalTo(theCell.contentView.mas_bottom).with.offset(-10);
        make.height.mas_equalTo(@15);
        make.width.mas_equalTo(@120);
    }];

    NSString *commentAndTime = nil;
    if (article.comment)
    {
        commentAndTime = [NSString stringWithFormat:@"%@  %@",[self _getCommmentTimes:article.commentTimes],[self _getArticleCreatTime:article.updateAt]];
    }
    else
    {
        commentAndTime = [NSString stringWithFormat:@"%@",[self _getArticleCreatTime:article.updateAt]];
    }
    
    self.commentAndTimeLabel.text = commentAndTime;
}

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 2;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

- (NSArray *)sortDataArray:(NSArray *)displayImgs
{
    NSArray *imgList = displayImgs;
    return [imgList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

#pragma mark - Private Method
- (NSString *)_getArticleCreatTime:(NSTimeInterval )updateAt
{
    NSTimeInterval time =  [NSDate date].timeIntervalSince1970 - updateAt / 1000;
    
    int month = ((int)time) / (3600 * 24 * 30);
    int days = ((int)time) / (3600 * 24);
    int hours = ((int)time) % (3600 * 24) / 3600;
    int minute = ((int)time) % (3600 * 24) / 60;
    
    NSString *timeText;
    
    if (month != 0)
    {
        timeText = [NSString stringWithFormat:@"%i%@", month, @"个月前"];
    }
    else if (days != 0)
    {
        timeText = [NSString stringWithFormat:@"%i%@", days, @"天前"];
    }
    else if (hours != 0)
    {
        timeText = [NSString stringWithFormat:@"%i%@", hours, @"小时前"];
    }
    else if (minute != 0)
    {
        timeText = [NSString stringWithFormat:@"%i%@", minute, @"分钟前"];
    }
    else
    {
        timeText = @"刚刚";
    }
    
    return timeText;
}

- (NSString *)_getCommmentTimes:(NSInteger)commentTimes
{
    NSString *labelText = [NSString stringWithFormat:@"%ld评论",(long)commentTimes];
    
    if (commentTimes > 10000)
    {
        labelText = [NSString stringWithFormat:@"%.1f万评论",commentTimes/10000.0];
    }
    
    return labelText;
}


@end

//
//  CMSTextCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSTextCell.h"

@interface CMSTextCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation CMSTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI
{
    [super setUpUI];
    
    UIView *contentView = self.contentView;
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.numberOfLines = 0;
    titleL.lineBreakMode = NSLineBreakByWordWrapping;
    titleL.textAlignment = NSTextAlignmentLeft;
    titleL.font = [UIFont systemFontOfSize:CMSUICellTitleFontSize];
    self.titleLabel = titleL;

    [contentView addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).with.offset(10);
        make.left.equalTo(contentView).with.offset(CellBorderWidth);
        make.right.equalTo(contentView).with.offset(-CellBorderWidth);
        make.height.mas_equalTo(@40);
    }];
    
}

- (void)setArticle:(CMSSDKArticle *)article withTitleHeight:(CGFloat)titleHeight
{
    [super setArticle:article withTitleHeight:titleHeight];
    self.titleLabel.text = article.title;
    BOOL isRead = [[[MOBFDataService sharedInstance] cacheDataForKey:article.articleID domain:CMSUICacheDomain] boolValue];
    if (isRead)
    {
        self.titleLabel.textColor = [MOBFColor colorWithRGB:0x868686];
    }
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(titleHeight);
    }];

}

- (void)setHasBeenRead
{
    self.titleLabel.textColor = [MOBFColor colorWithRGB:0x868686];
}

@end

//
//  CMSThreeImageCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSThreeImageCell.h"

@interface CMSThreeImageCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIImageView *displayImageViewA;

@property (nonatomic, weak) UIImageView *displayImageViewB;

@property (nonatomic, weak) UIImageView *displayImageViewC;

@property (nonatomic, strong) NSArray *displayViews;

@property (nonatomic, strong) NSMutableDictionary  *obvs;

@end

@implementation CMSThreeImageCell

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
    
    UIImageView *displayA = [[UIImageView alloc] init];
    displayA.contentMode = UIViewContentModeScaleAspectFill;
    displayA.clipsToBounds = YES;
    self.displayImageViewA = displayA;
    
    UIImageView *displayB = [[UIImageView alloc] init];
    displayB.contentMode = UIViewContentModeScaleAspectFill;
    displayB.clipsToBounds = YES;
    self.displayImageViewB = displayB;
    
    UIImageView *displayC = [[UIImageView alloc] init];
    displayC.contentMode = UIViewContentModeScaleAspectFill;
    displayC.clipsToBounds = YES;
    self.displayImageViewC = displayC;

    [contentView addSubview:titleL];
    [contentView addSubview:displayA];
    [contentView addSubview:displayB];
    [contentView addSubview:displayC];
    self.displayViews = @[displayA,displayB,displayC];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).with.offset(10);
        make.left.equalTo(contentView).with.offset(CellBorderWidth);
        make.right.equalTo(contentView).with.offset(-10);
        make.height.mas_equalTo(@40);
    }];

    [displayA mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.top.equalTo(contentView.mas_top).with.offset(60);
        make.top.equalTo(titleL.mas_bottom).with.offset(10);
        make.left.equalTo(contentView.mas_left).with.offset(CellBorderWidth);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-42.5);
        make.width.mas_equalTo((ScreenW - 2 * CellBorderWidth - 2 * 5) / 3);
    }];
    
    [displayB mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerY.equalTo(displayA.mas_centerY);
        make.height.equalTo(displayA);
        make.width.equalTo(displayA);
        make.left.equalTo(displayA.mas_right).with.offset(5);
    }];
    
    [displayC mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(displayB.mas_centerY);
        make.height.equalTo(displayB);
        make.width.equalTo(displayB);
        make.left.equalTo(displayB.mas_right).with.offset(5);
        
    }];
    
    self.obvs = [NSMutableDictionary dictionary];
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
    
    NSInteger imgCount = article.displayImgs.count;
    
    if (article.displayImgs.count > 0)
    {
        
        NSArray *orderArray = [self sortDataArray:article.displayImgs];
        
        for (int i = 0 ; i < imgCount; i++)
        {
            NSDictionary *dict = orderArray[i];
            NSURL *imgURL = [NSURL URLWithString:dict[@"url"]];
            UIImageView *imgView = self.displayViews[i];
            NSString *keyNumber = [NSString stringWithFormat:@"%d",i];
            MOBFImageObserver *obv = self.obvs[keyNumber];
            [[CMSUIUtils cellImageGetter] removeImageObserver:obv];
            imgView.image = nil;

            obv = [[CMSUIUtils cellImageGetter] getImageWithURL:imgURL result:^(UIImage *image, NSError *error) {
                
                if (image)
                {
                    
                    //新方案
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        imgView.image = image;
                        imgView.alpha = 0;
                        [UIView beginAnimations:@"CellAlpha" context:nil];
                        [UIView setAnimationDuration:0.2];
                        imgView.alpha = 1;
                        [UIView commitAnimations];
                    });
                    
                }
                
            }];
            
            [self.obvs setObject:obv forKey:keyNumber];
            
        }
    }
}

- (void)setHasBeenRead
{
    self.titleLabel.textColor = [MOBFColor colorWithRGB:0x868686];
}

- (void)dealloc
{
    [self.obvs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        MOBFImageObserver *obv = obj;
        [[CMSUIUtils cellImageGetter] removeImageObserver:obv];
    }];
}
@end

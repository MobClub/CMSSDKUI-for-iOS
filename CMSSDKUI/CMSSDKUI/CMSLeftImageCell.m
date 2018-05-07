//
//  CMSLeftImageCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/28.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSLeftImageCell.h"

@interface CMSLeftImageCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIImageView *displayImageView;

@property (nonatomic, weak) UILabel *videoTimeLabel;

@property (nonatomic, weak) MOBFImageObserver *obs;

@end

@implementation CMSLeftImageCell

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
    
    UIImageView *displayV = [[UIImageView alloc] init];
    displayV.contentMode = UIViewContentModeScaleAspectFill;
    displayV.clipsToBounds = YES;
    self.displayImageView = displayV;
    
    UILabel *videoTimeLabel = [[UILabel alloc] init];
    videoTimeLabel.textAlignment = NSTextAlignmentCenter;
    videoTimeLabel.font = [UIFont systemFontOfSize:10];
    videoTimeLabel.textColor = [UIColor whiteColor];
    videoTimeLabel.backgroundColor = [UIColor clearColor];
    videoTimeLabel.layer.cornerRadius = 10;
    videoTimeLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.videoTimeLabel = videoTimeLabel;
    
    [displayV addSubview:videoTimeLabel];
    [contentView addSubview:displayV];
    [contentView addSubview:titleL];
    
    [displayV mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(contentView).with.offset(10);
        make.left.equalTo(contentView).with.offset(CellBorderWidth);
        make.bottom.equalTo(contentView).with.offset(-12.5);
        make.width.mas_equalTo(@130);
    }];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(displayV.mas_top);
        make.left.equalTo(displayV.mas_right).with.offset(10);
        make.right.equalTo(contentView.mas_right).with.offset(-CellBorderWidth);
        make.height.mas_equalTo(@40);
    }];
    
    [videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(displayV.mas_right).with.offset(-5);
        make.bottom.equalTo(displayV.mas_bottom).with.offset(-5);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
    }];

}

- (void)setArticle:(CMSSDKArticle *)article withTitleHeight:(CGFloat)titleHeight
{
    [[CMSUIUtils cellImageGetter] removeImageObserver:self.obs];
    
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
    
    
    if (article.displayImgs.count > 0)
    {
        
        NSDictionary * displayDict = [self sortDataArray:article.displayImgs].firstObject;
        
        NSURL *imgURL = [NSURL URLWithString:displayDict[@"url"]];
        
        if (imgURL)
        {
            __weak typeof(self) theCell = self;
            self.displayImageView.image = nil;
            self.obs = [[CMSUIUtils cellImageGetter] getImageWithURL:imgURL result:^(UIImage *image, NSError *error) {
                
                if (image)
                {
                    //新方案
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        theCell.displayImageView.image = image;
                        theCell.displayImageView.alpha = 0;
                        [UIView beginAnimations:@"CellAlpha" context:nil];
                        [UIView setAnimationDuration:0.2];
                        theCell.displayImageView.alpha = 1;
                        [UIView commitAnimations];
                        
                    });
                    
                }
                else
                {
                    NSString *errorPath = [NSString stringWithFormat:@"%@/Resource/mrtp.png",[CMSUIUtils UIBundleResourcePath]];
                    theCell.displayImageView.image = [UIImage imageWithContentsOfFile:errorPath];
                }
                
            }];

        }
        else
        {
            NSString *defaultPath = [NSString stringWithFormat:@"%@/Resource/mrtp.png",[CMSUIUtils UIBundleResourcePath]];
            self.displayImageView.image = [UIImage imageWithContentsOfFile:defaultPath];
        }
        
    }
    
    if (article.articleType == 3 && article.videoTime > 0)
    {
        self.videoTimeLabel.hidden = NO;
        self.videoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)article.videoTime / 60, (int)article.videoTime % 60];
    }
    else
    {
        self.videoTimeLabel.hidden = YES;
    }
    
}

- (void)setHasBeenRead
{
    self.titleLabel.textColor = [MOBFColor colorWithRGB:0x868686];
}

- (void)dealloc
{   
    [[CMSUIUtils cellImageGetter] removeImageObserver:self.obs];
}

@end

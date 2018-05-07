//
//  CMSBottomImageCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/6.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSBottomImageCell.h"

@interface CMSBottomImageCell ()

@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UIImageView *displayImageView;

@property (nonatomic, weak) UILabel *videoTimeLabel;

@property (nonatomic, weak) MOBFImageObserver *obs;

@property (nonatomic, weak) UIImageView *playButton;

@end

@implementation CMSBottomImageCell

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
    videoTimeLabel.font = [UIFont systemFontOfSize:12];
    videoTimeLabel.textColor = [UIColor whiteColor];
    videoTimeLabel.backgroundColor = [UIColor clearColor];
    videoTimeLabel.layer.cornerRadius = 10;
    videoTimeLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    videoTimeLabel.hidden = YES;
    self.videoTimeLabel = videoTimeLabel;
    
    
    UIImageView *playButton = [[UIImageView alloc] init];
    playButton.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Resource/bofang.png",[CMSUIUtils UIBundleResourcePath]]];
    self.playButton = playButton;

    [displayV addSubview:videoTimeLabel];
    [displayV addSubview:playButton];
    [contentView addSubview:displayV];
    [contentView addSubview:titleL];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).with.offset(10);
        make.left.equalTo(contentView).with.offset(CellBorderWidth);
        make.right.equalTo(contentView).with.offset(-CellBorderWidth);
        make.height.mas_equalTo(@40);
    }];
    
    [displayV mas_makeConstraints:^(MASConstraintMaker *make) {
        
//        make.top.equalTo(contentView.mas_top).with.offset(60);
        make.top.equalTo(titleL.mas_bottom).with.offset(10);
        make.left.equalTo(contentView.mas_left).with.offset(CellBorderWidth);
        make.right.equalTo(contentView).with.offset(-CellBorderWidth);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-42.5);
        
    }];
    
    [videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.equalTo(displayV.mas_right).with.offset(-5);
        make.bottom.equalTo(displayV.mas_bottom).with.offset(-5);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(20);
        
    }];
    
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(displayV.mas_centerX);
        make.centerY.equalTo(displayV.mas_centerY);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        
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
                
                if (image != nil)
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
        self.playButton.hidden = NO;
    }
    else
    {
        self.videoTimeLabel.hidden = YES;
        self.playButton.hidden = YES;
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

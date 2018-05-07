//
//  CMSVideoRelatedCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/15.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSVideoRelatedCell.h"
#import "View+MASAdditions.h"
#import <MOBFoundation/MOBFColor.h>
#import <MOBFoundation/MOBFImageGetter.h>

@interface CMSVideoRelatedCell ()


@property (nonatomic, weak) UILabel *titleLabel;

@property (nonatomic, weak) UILabel *readTimesLabel;

@property (nonatomic, weak) UIImageView *displayImageView;

@property (nonatomic, weak) UILabel *videoTimeLabel;

@property (nonatomic, weak) MOBFImageObserver *obs;

@end

@implementation CMSVideoRelatedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self _setUpUI];
    }
    return self;
}

- (void)_setUpUI
{
    UILabel *titleL = [[UILabel alloc] init];
    titleL.numberOfLines = 0;
    titleL.lineBreakMode = NSLineBreakByWordWrapping;
    titleL.textAlignment = NSTextAlignmentLeft;
    titleL.font = [UIFont systemFontOfSize:16];
    self.titleLabel = titleL;
    
    UILabel *readTimesLabel = [[UILabel alloc] init];
    readTimesLabel.font = [UIFont systemFontOfSize:13];
    readTimesLabel.textColor = [MOBFColor colorWithRGB:0x999999];
    self.readTimesLabel = readTimesLabel;
    
    UIImageView *imgView = [[UIImageView alloc] init];
    self.displayImageView = imgView;
    
    UILabel *videoTimeLabel = [[UILabel alloc] init];
    videoTimeLabel.textAlignment = NSTextAlignmentCenter;
    videoTimeLabel.font = [UIFont systemFontOfSize:10];
    videoTimeLabel.textColor = [UIColor whiteColor];
    videoTimeLabel.backgroundColor = [UIColor clearColor];
    videoTimeLabel.layer.cornerRadius = 10;
    videoTimeLabel.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.videoTimeLabel = videoTimeLabel;
    [imgView addSubview:videoTimeLabel];
    
    [self.contentView addSubview:titleL];
    [self.contentView addSubview:readTimesLabel];
    [self.contentView addSubview:imgView];
    
    __weak typeof(self) theCell = self;
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(theCell.contentView.mas_top).with.offset(10);
        make.right.equalTo(theCell.contentView.mas_right).with.offset(-10);
        make.bottom.equalTo(theCell.contentView.mas_bottom).with.offset(-12.5);
        make.width.mas_equalTo(@130);
    }];
    
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_top);
        make.left.equalTo(theCell.contentView.mas_left).with.offset(10);
        make.right.equalTo(imgView.mas_left).with.offset(-15);
        make.height.mas_equalTo(@40);
    }];

    [readTimesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(theCell.contentView).with.offset(10);
        make.bottom.equalTo(theCell.contentView).with.offset(-12.5);
        make.width.mas_equalTo(@130);
    }];
    
    [videoTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(imgView.mas_right).with.offset(-10);
        make.bottom.equalTo(imgView.mas_bottom).with.offset(-5);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(15);
        
    }];

}

- (void)setArticle:(CMSSDKArticle *)article
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
    
    self.titleLabel.text = article.title;
    [self.titleLabel sizeToFit];
    self.readTimesLabel.text = [self _getReadTimes:article.readTimes];
    self.videoTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)article.videoTime / 60, (int)article.videoTime % 60];

    if (article.displayImgs.count > 0)
    {
        NSDictionary *imgDict= [self _sortDataArray:article.displayImgs].firstObject;
        NSURL *imgURL = [NSURL URLWithString:imgDict[@"url"]];
        
        self.displayImageView.image = nil;
        if (imgURL)
        {
            __weak typeof(self) theCell = self;
            self.obs = [[MOBFImageGetter sharedInstance] getImageWithURL:imgURL result:^(UIImage *image, NSError *error) {
                theCell.displayImageView.image = image;
            }];
        }
    }
}

- (NSArray *)_sortDataArray:(NSArray *)displayImgs
{
    NSArray *imgList = displayImgs;
    return [imgList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

- (NSString *)_getReadTimes:(NSInteger)commentTimes
{
    NSString *labelText = [NSString stringWithFormat:@"%ld次播放",(long)commentTimes];
    
    if (commentTimes > 10000)
    {
        labelText = [NSString stringWithFormat:@"%.1f万次播放",commentTimes/10000.0];
    }
    
    return labelText;
}

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
}

@end

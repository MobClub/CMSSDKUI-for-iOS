//
//  CMSCommentCell.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/14.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSCommentCell.h"
#import "View+MASAdditions.h"
#import <MOBFoundation/MOBFJson.h>
#import <MOBFoundation/MOBFColor.h>
#import <MOBFoundation/MOBFImageGetter.h>

/**
 *  评论列表单元
 */
@interface CMSCommentCell ()

/**
 *  头像
 */
@property (nonatomic, weak) UIImageView *iconView;

/**
 *  昵称
 */
@property (nonatomic, weak) UILabel *nickNameLabel;

/**
 *  发表时间
 */
@property (nonatomic, weak) UILabel *updateLabel;

/**
 *  评论内容
 */
@property (nonatomic, weak) UILabel *commentLabel;

//图片观察器
@property (nonatomic, weak) MOBFImageObserver *obs;

@end

@implementation CMSCommentCell

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
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 35 / 2;
    
    UILabel *nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.textColor = [MOBFColor colorWithRGB:0x406599];
    nickNameLabel.font = [UIFont systemFontOfSize:CMSUICommentNickNameFontSize];
    
    UILabel *updateLabel = [[UILabel alloc] init];
    updateLabel.textColor = [MOBFColor colorWithRGB:0x979fac];
    updateLabel.font = [UIFont systemFontOfSize:CMSUICommentUpdateTextFontSize];
    
    UILabel *commentLabel = [[UILabel alloc] init];
    commentLabel.font = [UIFont systemFontOfSize:CMSUICommentContentFontSize];
    commentLabel.numberOfLines = 0;
    commentLabel.textColor = [MOBFColor colorWithRGB:0x222222];
    
    self.iconView = iconView;
    self.nickNameLabel = nickNameLabel;
    self.updateLabel = updateLabel;
    self.commentLabel = commentLabel;
    
    [self.contentView addSubview:iconView];
    [self.contentView addSubview:nickNameLabel];
    [self.contentView addSubview:updateLabel];
    [self.contentView addSubview:commentLabel];
    
    __weak typeof(self) theCell = self;
    
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(theCell.contentView.mas_top).with.offset(10);
        make.left.equalTo(theCell.contentView.mas_left).with.offset(10);
        make.width.mas_equalTo(@35);
        make.height.mas_equalTo(@35);
    }];
    
    [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(iconView.mas_right).with.offset(10);
        make.centerY.equalTo(iconView.mas_centerY);
        make.width.mas_equalTo(@200);
        make.height.mas_equalTo(@20);

    }];
    
    [updateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(theCell.contentView.mas_bottom).with.offset(-10);
        make.left.equalTo(iconView.mas_right).with.offset(10);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@15);
        
    }];
    
}

- (void)setComment:(CMSSDKComment *)comment
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
    
    NSURL *avatarURL = nil;
    if (comment.avatar.length > 0)
    {
        NSArray *avatarArr = (NSArray *)[MOBFJson objectFromJSONString:comment.avatar];
        if (avatarArr.count > 0)
        {
            avatarURL = [NSURL URLWithString:avatarArr.lastObject];
        }
        else
        {
            avatarURL = [NSURL URLWithString:comment.avatar];
        }
    }
    
    __weak typeof(self) theCell = self;
    if (avatarURL == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
        NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
        NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/tx.png",sourceBundle.resourcePath];
        self.iconView.image = [UIImage imageWithContentsOfFile:imgPath];
    }
    else
    {
        self.iconView.image = nil;
        self.obs = [[MOBFImageGetter sharedInstance] getImageWithURL:avatarURL result:^(UIImage *image, NSError *error) {
            theCell.iconView.image = image;
        }];
    }
    
    self.nickNameLabel.text = comment.nickName ? comment.nickName : @"游客";
    self.updateLabel.text = [self getCommentCreatTime:comment.updateAt];
    self.commentLabel.text = comment.content;
    
    
    [self.commentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(theCell.nickNameLabel.mas_left);
        make.top.equalTo(theCell.iconView.mas_bottom);
        make.width.mas_equalTo(@(ScreenW - 65));

    }];
    
    [self.commentLabel sizeToFit];
    
}

- (CGFloat)getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
}

- (NSString *)getCommentCreatTime:(NSTimeInterval )updateAt
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

- (void)dealloc
{
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
}

@end

//
//  CMSVideoTypeViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/12.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSVideoTypeViewController.h"
#import "CMSVideoRelatedCell.h"
#import "CMSVideoPlayer.h"
#import "CMSCommentListViewController.h"
#import "View+MASAdditions.h"
#import "CMSUIUtils.h"
#import <MOBFoundation/MOBFColor.h>
#import <MOBFoundation/MOBFImageGetter.h>
#import <MOBFoundation/MOBFApplication.h>
#import <CMSSDK/CMSSDK+Share.h>
#import "DRPLoadingSpinner.h"
#import "CMSLoadingMoreView.h"

@interface CMSVideoTypeViewController ()<UITableViewDelegate,
                                         UITableViewDataSource,
                                         UITextFieldDelegate,
                                         CMSVideoPlayerDelegate,
                                         UIGestureRecognizerDelegate>

//数据相关
@property (nonatomic, strong) CMSSDKArticle *currentArticle;
@property (nonatomic, strong) NSMutableArray <CMSSDKArticle *> *recommendDataArray;

//中间介绍视图相关
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *openBtn;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *readTimesLabel;
@property (nonatomic, strong) UILabel *creatTimesLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *praiseBtn;
@property (nonatomic, strong) UILabel *praiseTimesLabel;

//底部评论浮层视图相关
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UILabel *commentTimesLabel;

//推荐列表相关
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger currentPageNo;
@property (nonatomic) BOOL isLoadingRecommend;
@property (nonatomic, weak) UIView *recommendErrorView;

//视频视图相关
@property (nonatomic, strong) CMSVideoPlayer *player;
@property (nonatomic, strong) MOBFImageObserver *obs;
@property (nonatomic, strong) UIImageView *videoPreview;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic) BOOL isDetailOpen;
@property (nonatomic, strong) UIProgressView *loadingProgress;
@property (nonatomic, strong) UIProgressView *playingProgress;
@property (nonatomic, strong) UITapGestureRecognizer *controlTap;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic) BOOL isControlShowing;
@property (nonatomic, strong) UISlider *controlSlider;
@property (nonatomic) BOOL isSliding;
@property (nonatomic, strong) UIProgressView *controlProgress;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *totalTimeLabel;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic) double currentAngle;
@property (nonatomic, weak) UIView *videoErrorView;

//其他视图
@property (nonatomic, weak) UIView *netErrorView;
@property (nonatomic, weak) DRPLoadingSpinner *spin;
@property (nonatomic, strong) CMSLoadingMoreView *loadMoreView;

@end

@implementation CMSVideoTypeViewController

- (instancetype)initWithArticleID:(NSString *)articleID
{
    if (self = [super init])
    {
        self.artileID = articleID;
        self.recommendDataArray = [NSMutableArray array];
        self.isDetailOpen = NO;
        self.isLoadingRecommend = NO;
        self.currentPageNo = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    //iPhoneX 底部填白
    if ([CMSUIUtils isIPhoneX])
    {
        UIView *bottomWhite = [[UIView alloc] init];
        bottomWhite.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomWhite];
        __weak typeof(CMSVideoTypeViewController) *theController = self;
        [bottomWhite mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(theController.view);
            make.right.equalTo(theController.view);
            make.bottom.equalTo(theController.view);
            make.bottom.height.equalTo(@34);
        }];
    }
    
    [self _setNavigaitonUI];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //隐藏状态栏
    [self _loadData];
    
}

- (void)_loadData
{
    [self.spin startAnimating];
    self.netErrorView.hidden = YES;
    __weak typeof(self) theController = self;
    [CMSSDK getArticleDetail:self.artileID result:^(CMSSDKArticle *article, NSError *error) {
        
        [theController.spin stopAnimating];
        
        if (error == nil)
        {
            theController.currentArticle = article;
            
            [theController _setCommentViewUI];
            [theController _updateUI];
            theController.tableView.tableHeaderView = [theController _getViewWithOpen:theController.isDetailOpen];
            [theController _reloadRecommendData];
            
            theController.netErrorView.hidden = YES;
            theController.spin.hidden = YES;
        }
        else
        {
            //加载文章详情失败
            theController.netErrorView.hidden = NO;
        }
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL hideStatusBar = YES;
    if ([CMSUIUtils isIPhoneX])
    {
         hideStatusBar = NO;//iphone x 不隐藏导航栏
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                        object:@(hideStatusBar)];
    self.tabBarController.tabBar.hidden = YES;
    [self _setNavigaitonUI];
    
    if (self.player != nil)
    {
        CGFloat videoViewH = ScreenW * 9 / 16;
        self.player.frame = CGRectMake(0, [CMSUIUtils isIPhoneX] ? 44 : 0, ScreenW, videoViewH);
        [self.view addSubview:self.player];
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                        object:@(NO)];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.recommendDataArray.count <= 0)
    {
        return 1;
    }
    
    return self.recommendDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.recommendDataArray.count <= 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NonDataCELL"];
        cell.textLabel.text = @"无相关内容";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    
    CMSSDKArticle *relateArticle = self.recommendDataArray[indexPath.row];
    CMSVideoRelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMSVideoRelatedCell"];
    
    [cell setArticle:relateArticle];
    
    return cell;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.isLoadingRecommend)
    {
        float height = scrollView.contentSize.height > self.tableView.frame.size.height ? self.tableView.frame.size.height : scrollView.contentSize.height;
        
        if ((height - scrollView.contentSize.height + scrollView.contentOffset.y) / height > 0.2)
        {
            //上拉刷新方法
            [self _reloadRecommendData];
        }
    }
    
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击相关文章，替换当前Article,并将当前Article放入 related 数组
    CMSSDKArticle *chosenArticle = (CMSSDKArticle *)self.recommendDataArray[indexPath.row];
    self.artileID = chosenArticle.articleID;
    [self.recommendDataArray removeObject:chosenArticle];
    [self.recommendDataArray addObject:self.currentArticle];
    [self.tableView reloadData];
    
    __weak typeof(self) theControlelr = self;
    [CMSSDK getArticleDetail:self.artileID result:^(CMSSDKArticle *article, NSError *error) {
       
        if (error == nil)
        {
            theControlelr.currentArticle = article;
            [theControlelr.player dispose];
            [theControlelr.player removeFromSuperview];
            theControlelr.player = nil;
            [theControlelr _updateUI];
            
            [[NSNotificationCenter defaultCenter] removeObserver:theControlelr];
        }
        
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.currentArticle.comment)
    {
        __weak typeof(self) theController = self;
        //弹出评论编辑框
        
        [CMSUIUtils presentToCommentEditFromController:self result:^(BOOL isSend, NSString *comment) {
            if (isSend)
            {
                [CMSSDK addComment:comment
                         toArticle:theController.currentArticle
                            result:^(CMSSDKComment *newComment,MOBFUser *user, NSError *error) {
                                
                                if (error == nil)
                                {
                                    [CMSUIUtils showCommentSuccessAlertInView:theController.view];
                                }
                                else
                                {
                                    [CMSUIUtils showCommentFailedAlertInView:theController.view];
                                }
                                
                            }];
            }
        }];
    }
    else
    {
        [CMSUIUtils showCommentNotAllowedAlertInView:self.view];
    }
    
    return NO;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //通过手势区分slider,以免在点击slider时隐藏了;同时能够避免slider的结束时的正常取值
    if ([touch.view isDescendantOfView:self.controlSlider])
    {
        return NO;
    }
    
    if ([touch.view isDescendantOfView:self.fullScreenButton])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - Button Touch Event Selector
- (void)_sliderFinishedValueChange:(UISlider *)slider
{
    self.isSliding = NO;
    [self.player seek:slider.value completion:nil];
}

- (void)_sliderValueChange:(UISlider *)slider
{
    self.isSliding = YES;
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)slider.value / 60,(int)slider.value % 60];
}

- (void)_fullScreen:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        self.navigationController.navigationBarHidden = YES;
        [self _setAutoresizing];
        __weak typeof(self) theControlelr = self;
        [UIView animateWithDuration:0.5 animations:^{
            
            if ([CMSUIUtils isIPhoneX])
            {
                theControlelr.player.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
            else
            {
                theControlelr.player.transform = CGAffineTransformMakeRotation(M_PI_2);
            }
            
            theControlelr.player.frame = CGRectMake(0, [CMSUIUtils isIPhoneX] ? 44 : 0, ScreenW, ScreenH);
            
        }];
        
        self.currentAngle = M_PI_2;
    }
    else
    {
        if ([CMSUIUtils isIPhoneX])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                                object:@(NO)];//iphonex 竖屏时不隐藏
        }
        
        self.navigationController.navigationBarHidden = NO;
        __weak typeof(self) theControlelr = self;
        [UIView animateWithDuration:0.5 animations:^{
            theControlelr.player.transform = CGAffineTransformIdentity;
            theControlelr.player.frame = CGRectMake(0, [CMSUIUtils isIPhoneX] ? 44 : 0, ScreenW, ScreenW * 9 / 16);
        }];
        
        self.currentAngle = 0;
    }

}

- (void)_showOrHideControl
{
    __weak typeof(self) theController = self;
    if (_isControlShowing)
    {
        self.loadingProgress.hidden = NO;
        self.playingProgress.hidden = NO;
        [UIView animateWithDuration:0.5 animations:^{
            theController.controlView.alpha = 0;
            theController.controlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            theController.isControlShowing = NO;
        }];
    }
    else
    {
        self.loadingProgress.hidden = YES;
        self.playingProgress.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            theController.controlView.alpha = 1;
            theController.controlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            
        } completion:^(BOOL finished) {
            theController.isControlShowing = YES;
        }];
    }
}

- (void)_pauseVideo:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

- (void)_changeOpenStatus:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.isDetailOpen = sender.selected;
    self.tableView.tableHeaderView = [self _getViewWithOpen:self.isDetailOpen];
}

- (void)_popController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                        object:@(NO)];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_praise:(UIButton *)sender
{
    sender.userInteractionEnabled = NO;
    __weak typeof(self) theController = self;
    [CMSSDK praiseArticle:self.currentArticle result:^(NSError *error) {
        if (error == nil)
        {
            sender.selected = !sender.selected;
            sender.userInteractionEnabled = NO;
            self.praiseTimesLabel.text = [NSString stringWithFormat:@"%lu", theController.currentArticle.praiseTimes + 1];
        }
        else
        {
            sender.userInteractionEnabled = YES;
        }
    }];
}

- (void)_playVideo
{
    self.controlView.frame = self.player.bounds;//每次播放前,controlView都应该衣服player的bounds
    [self.player addSubview:self.controlView];
    self.controlTap.enabled = YES;
    [self.player play];
    
    self.videoPreview.hidden = YES;
    self.playButton.hidden = YES;
    
    self.loadingProgress.hidden = NO;
    self.playingProgress.hidden = NO;
    
}

- (void)_reloadVideo
{
    self.videoErrorView.hidden = YES;
    
    [self.player dispose];
    [self.player removeFromSuperview];
    self.player = nil;
    [self _updateUI];
}

#pragma mark - CMSVideoPlayerDelegate
- (void)videoPlayerReadyToPlay:(CMSVideoPlayer *)videoPlayer
{
    [videoPlayer addSubview:self.videoPreview];
    [self.videoPreview addSubview:self.playButton];
    self.videoPreview.hidden = NO;
    self.playButton.hidden = NO;
    self.controlSlider.maximumValue = videoPlayer.duration;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",(int)videoPlayer.duration / 60,(int)videoPlayer.duration % 60];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_orientChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];

    
    [self _playVideo];
    
}

- (void)videoPlayerFinishedPlay:(CMSVideoPlayer *)videoPlayer
{
    [self.controlView removeFromSuperview];
    
    self.videoPreview.hidden = NO;
    self.playButton.hidden = NO;
    
    self.loadingProgress.hidden = YES;
    self.loadingProgress.progress = 0;
    self.playingProgress.hidden = YES;
    self.playingProgress.progress = 0;
}

- (void)videoPlayerLoadedDurationChange:(CMSVideoPlayer *)videoPlayer
{
    float progress = videoPlayer.loadedDuration / videoPlayer.duration;
    [self.loadingProgress setProgress:progress animated:YES];
    [self.controlProgress setProgress:progress animated:YES];
}

- (void)videoPlayerTimeUpdate:(CMSVideoPlayer *)videoPlayer
{
    float progress = videoPlayer.currentTime / videoPlayer.duration;
    [self.playingProgress setProgress:progress animated:YES];
    
    if (!self.isSliding)
    {
        [self.controlSlider setValue:videoPlayer.currentTime animated:YES];
        self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",
                                      (int)videoPlayer.currentTime / 60,
                                      (int)videoPlayer.currentTime % 60];
    }
    
}

- (void)videoPlayer:(CMSVideoPlayer *)videoPlayer loadedFailWithError:(NSError *)error
{
    self.videoErrorView.hidden = NO;
}

#pragma mark - Lazy Method
- (UIView *)recommendErrorView
{
    if (_recommendErrorView == nil)
    {
        UIView *errorView = [[UIView alloc] init];
        CGFloat videoViewH = ScreenW * 9 / 16;
        errorView.frame = CGRectMake(0, videoViewH, ScreenW, ScreenH - videoViewH - 49);
        _recommendErrorView = errorView;
        
        UILabel *lalbel = [[UILabel alloc] init];
        lalbel.text = @"推荐信息加载失败";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [UIColor blackColor];
        lalbel.font = [UIFont systemFontOfSize:14];
        [errorView addSubview:lalbel];
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_reloadRecommendData) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        reloadBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = [UIColor blackColor].CGColor;
        [reloadBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [errorView addSubview:reloadBtn];
        
        [self.view addSubview:_recommendErrorView];
        
        [lalbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(errorView.mas_centerX);
            make.centerY.equalTo(errorView.mas_centerY).with.offset(-30);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(40);
        }];
        
        [reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(errorView.mas_centerX);
            make.centerY.equalTo(errorView.mas_centerY).with.offset(30);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(30);
        }];
    }
    
    return _recommendErrorView;
}

- (DRPLoadingSpinner *)spin
{
    if (_spin == nil)
    {
        DRPLoadingSpinner *spinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        spinner.rotationCycleDuration = 1;
        spinner.drawCycleDuration = .5;
        spinner.lineWidth = 2;
        spinner.colorSequence = @[[MOBFColor colorWithRGB:0xe66159]];
        spinner.maximumArcLength = M_PI ;
        spinner.minimumArcLength = M_PI ;

        _spin = spinner;
        [self.view addSubview:_spin];
        
        __weak typeof(self) theController = self;
        [spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(theController.view.mas_centerX);
            make.centerY.equalTo(theController.view.mas_centerY).with.offset(-100);
        }];
    }
    
    return _spin;
}

- (UIView *)videoErrorView
{
    if (_videoErrorView == nil)
    {
        UIView *videoErrorView = [[UIView alloc] initWithFrame:self.player.frame];
        
        _videoErrorView = videoErrorView;
        
        UILabel *lalbel = [[UILabel alloc] init];
        lalbel.text = @"视频加载失败";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [UIColor whiteColor];
        [videoErrorView addSubview:lalbel];
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_reloadVideo) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [reloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [videoErrorView addSubview:reloadBtn];
        
        [self.player addSubview:_videoErrorView];
        
        [lalbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(videoErrorView.mas_centerX);
            make.centerY.equalTo(videoErrorView.mas_centerY).with.offset(-30);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(40);
        }];
        
        [reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(videoErrorView.mas_centerX);
            make.centerY.equalTo(videoErrorView.mas_centerY).with.offset(30);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(30);
        }];
        
    }
    return _videoErrorView;
}

- (UIView *)netErrorView
{
    if (_netErrorView == nil)
    {
        UIView *netErrorView = [[UIView alloc] initWithFrame:self.view.frame];
        netErrorView.backgroundColor = [UIColor whiteColor];
        _netErrorView = netErrorView;
        [self.view addSubview:_netErrorView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/wwl.png",[CMSUIUtils UIBundleResourcePath]];
        imageView.image = [UIImage imageWithContentsOfFile:imgPath];
        [netErrorView addSubview:imageView];
        
        UILabel *lalbel = [[UILabel alloc] init];
        lalbel.text = @"当前网络异常";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [MOBFColor colorWithRGB:0x999999];
        [netErrorView addSubview:lalbel];
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_loadData) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = [MOBFColor colorWithRGB:0xE66159].CGColor;
        [reloadBtn setTitleColor:[MOBFColor colorWithRGB:0xE66159] forState:UIControlStateNormal];
        [netErrorView addSubview:reloadBtn];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(netErrorView.mas_centerX);
            make.centerY.equalTo(netErrorView.mas_centerY).with.offset(-100);
            make.height.mas_equalTo(100);
            make.width.mas_equalTo(100);
        }];
        
        [lalbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(netErrorView.mas_centerX);
            make.top.equalTo(imageView.mas_bottom).with.offset(20);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(40);
        }];
        
        [reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(netErrorView.mas_centerX);
            make.top.equalTo(lalbel.mas_bottom).with.offset(60);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(30);
        }];
        
    }
    
    return _netErrorView;
}

- (UIButton *)playButton
{
    if (_playButton == nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 40, 40);
        button.center = self.videoPreview.center;
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
        NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
        NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/bofang.png",sourceBundle.resourcePath];
        [button setImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_playVideo) forControlEvents:UIControlEventTouchUpInside];
        _playButton = button;
    }
    
    return _playButton;
}

- (UIImageView *)videoPreview
{
    if (_videoPreview == nil)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.player.bounds];
        imageView.userInteractionEnabled = YES;
        _videoPreview = imageView;
    }
    
    return _videoPreview;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [tableView registerClass:[CMSVideoRelatedCell class] forCellReuseIdentifier:@"CMSVideoRelatedCell"];
        tableView.delegate = self;
        tableView.dataSource = self;
        
        self.loadMoreView = [[CMSLoadingMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 35)];
        tableView.tableFooterView = self.loadMoreView;
        
        CGFloat videoViewH = ScreenW * 9 / 16;
        tableView.frame = CGRectMake(0, videoViewH, ScreenW, ScreenH - videoViewH - 49);
        _tableView = tableView;
//        [self.view addSubview:tableView];
    }
    
    return _tableView;
}

- (UIView *)headerView
{
    if (_headerView == nil)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenH, self.isDetailOpen ? 230 : 130)];
        _headerView = headerView;
    }
    
    return _headerView;
}

- (UIButton *)openBtn
{
    if (_openBtn == nil)
    {
        UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [openBtn setImage:[self _getStatusImageWith:NO] forState:UIControlStateNormal];
        [openBtn setImage:[self _getStatusImageWith:YES] forState:UIControlStateSelected];
        [openBtn addTarget:self action:@selector(_changeOpenStatus:) forControlEvents:UIControlEventTouchUpInside];
        _openBtn = openBtn;
        [self.headerView addSubview:openBtn];
    }
    
    return _openBtn;
}

- (UILabel *)titleLable
{
    if (_titleLable == nil)
    {
        UILabel *titleLabel = [[UILabel alloc] init];
        //titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];//加粗
        _titleLable = titleLabel;
        [self.headerView addSubview:titleLabel];
    }
    
    return _titleLable;
}

- (UILabel *)readTimesLabel
{
    if (_readTimesLabel == nil)
    {
        UILabel *timesLabel = [[UILabel alloc] init];
        timesLabel.textColor = [MOBFColor colorWithRGB:0x999999];
        timesLabel.font = [UIFont systemFontOfSize:13];
        timesLabel.numberOfLines = 1;
        _readTimesLabel = timesLabel;
        [self.headerView addSubview:timesLabel];
    }
    
    return _readTimesLabel;
}

- (UILabel *)creatTimesLabel
{
    if (_creatTimesLabel == nil)
    {
        UILabel *creatLabel = [[UILabel alloc] init];
        creatLabel.textColor = [MOBFColor colorWithRGB:0x999999];
        creatLabel.font = [UIFont systemFontOfSize:13];
        creatLabel.numberOfLines = 1;
        _creatTimesLabel = creatLabel;
        [self.headerView addSubview:creatLabel];
    }
    
    return _creatTimesLabel;
}

- (UILabel *)descLabel
{
    if (_descLabel == nil)
    {
        UILabel *descLabel = [[UILabel alloc] init];
        descLabel.textColor = [MOBFColor colorWithRGB:0x999999];
        descLabel.font = [UIFont systemFontOfSize:13];
        descLabel.numberOfLines = 0;
        _descLabel = descLabel;
        [self.headerView addSubview:descLabel];
    }
    
    return _descLabel;
}

- (UIButton *)praiseBtn
{
    if (_praiseBtn == nil)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[self _getPraiseImageWith:NO] forState:UIControlStateNormal];
        [button setImage:[self _getPraiseImageWith:YES] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(_praise:) forControlEvents:UIControlEventTouchUpInside];
        _praiseBtn = button;
        [self.headerView addSubview:button];
    }
    return _praiseBtn;
}

- (UILabel *)praiseTimesLabel
{
    if (_praiseTimesLabel == nil)
    {
        UILabel *timesLabel = [[UILabel alloc] init];
//        timesLabel.textColor = [MOBFColor colorWithRGB:0x999999];
        timesLabel.font = [UIFont systemFontOfSize:13];
        timesLabel.numberOfLines = 1;
        _praiseTimesLabel = timesLabel;
        [self.headerView addSubview:timesLabel];
    }
    
    return _praiseTimesLabel;
}

#pragma mark - Private

- (CGFloat)_getWidthWithTitle:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width + 5;
}

- (void)_setAutoresizing
{
    self.controlView.autoresizingMask =  UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    self.loadingProgress.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.playingProgress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.controlSlider.translatesAutoresizingMaskIntoConstraints = YES;
    self.controlSlider.autoresizingMask =  UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.pauseButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.pauseButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.controlProgress.translatesAutoresizingMaskIntoConstraints = YES;
    self.controlProgress.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.fullScreenButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.currentTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    
    self.totalTimeLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.totalTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.videoPreview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.playButton.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    
}

- (void)_orientChange
{
    [self _setAutoresizing];
    
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    switch (orient)
    {
        case UIDeviceOrientationPortrait:
        {
            if ([CMSUIUtils isIPhoneX])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                                    object:@(NO)];//iphonex 竖屏时不隐藏
            }
            
            __weak typeof(self) theControlelr = self;
            self.navigationController.navigationBarHidden = NO;
            self.fullScreenButton.selected = NO;
            double oldAngel = self.currentAngle;
            if (oldAngel == 0)
            {
                return;
            }
            else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    theControlelr.player.transform = CGAffineTransformIdentity;
                    theControlelr.player.frame = CGRectMake(0,
                                                            [CMSUIUtils isIPhoneX] ? 44 : 0,
                                                            ScreenW,
                                                            ScreenW * 9 / 16);
                    
                }];
            }
            
            self.currentAngle = 0;
            break;
        }
            
        case UIDeviceOrientationLandscapeLeft:
        {
            
            if ([CMSUIUtils isIPhoneX])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                                    object:@(NO)];//iphonex 非刘海遮挡时不隐藏
            }
            
            __weak typeof(self) theControlelr = self;
            self.navigationController.navigationBarHidden = YES;
            self.fullScreenButton.selected = YES;
            double oldAngel = self.currentAngle;
            
            if (oldAngel == 0)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    theControlelr.player.transform = CGAffineTransformMakeRotation(M_PI_2);
                    theControlelr.player.frame = CGRectMake(0, 0, ScreenW, ScreenH);
                    
                }];
            }
            else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    theControlelr.player.frame = CGRectMake(0, 0, ScreenW, ScreenH);
                    theControlelr.player.transform = CGAffineTransformMakeRotation(M_PI_2);
                    
                }];
            }
            
            self.currentAngle = M_PI_2;
            
            break;
        }
            
        case UIDeviceOrientationLandscapeRight:
        {
            if ([CMSUIUtils isIPhoneX])
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                                    object:@(YES)];//iphonex 楼海遮挡避免
            }
            
            __weak typeof(self) theControlelr = self;
            self.navigationController.navigationBarHidden = YES;
            self.fullScreenButton.selected = YES;
            double oldAngel = self.currentAngle;
            
            if (oldAngel == 0)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    theControlelr.player.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    theControlelr.player.frame = CGRectMake(0, 0, ScreenW, ScreenH);
                    
                }];
            }
            else
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    theControlelr.player.frame = CGRectMake(0, 0, ScreenW, ScreenH);
                    theControlelr.player.transform = CGAffineTransformMakeRotation(-M_PI_2);
                }];
                
            }
            
            self.currentAngle = - M_PI_2;
            break;
        }
        default:
            break;
    }
}

- (void)_resetPlayer
{
    CGFloat videoViewH = ScreenW * 9 / 16;
    
    CGFloat nomalHeight = 0;
    
    if ([CMSUIUtils isIPhoneX])
    {
        nomalHeight = 44; //iphone x 需要往下移44,避免刘海遮挡
    }

    CMSVideoPlayer *player = [[CMSVideoPlayer alloc] initWithFrame:CGRectMake(0, nomalHeight, ScreenW, videoViewH)];
    player.delegate = self;
    self.player = player;
    [self.view addSubview:player];
}
- (UIView *)_getViewWithOpen:(BOOL)isOpen
{
    CGFloat headerHeight = 0;
    
    __weak typeof(self) theController = self;
    [self.openBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(theController.headerView.mas_top).with.offset(25);
        make.right.equalTo(theController.headerView.mas_right).with.offset(-10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(15);
    }];
    
    headerHeight += 20;//上间隙
    
    self.titleLable.numberOfLines = isOpen? 0 : 1;
    [self.titleLable mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(theController.headerView.mas_top).with.offset(20);
        make.left.equalTo(theController.headerView.mas_left).with.offset(10);
        make.right.equalTo(theController.openBtn.mas_left).with.offset(-10);
    }];
    [self.titleLable sizeToFit];
    headerHeight += self.titleLable.frame.size.height;
    
    [self.readTimesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.titleLable.mas_bottom).with.offset(10);
        make.left.equalTo(theController.headerView.mas_left).with.offset(10);
        
    }];
    headerHeight += 20 + 10;//自身高度 + 间隙
    
    if (isOpen)
    {
        self.creatTimesLabel.hidden = NO;
    }
    else
    {
        self.creatTimesLabel.hidden = YES;
    }
    [self.creatTimesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(theController.readTimesLabel.mas_bottom).with.offset(20);
        make.left.equalTo(theController.headerView.mas_left).with.offset(10);
        
    }];
    headerHeight += isOpen? self.creatTimesLabel.frame.size.height + 20 : 0;
    
    if (isOpen)
    {
        self.descLabel.hidden = NO;
    }
    else
    {
        self.descLabel.hidden = YES;
    }
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.creatTimesLabel.mas_bottom).with.offset(5);
        make.left.equalTo(theController.headerView.mas_left).with.offset(10);
        make.width.mas_equalTo(@(ScreenW - 20));
    }];
    [self.descLabel sizeToFit];
    headerHeight += isOpen? self.descLabel.frame.size.height + 5: 0;
    
    [self.praiseBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@30);
        make.height.mas_equalTo(@30);
        make.left.equalTo(theController.headerView.mas_left).with.offset(10);
        if (isOpen)
        {
            make.top.equalTo(theController.descLabel.mas_bottom).with.offset(20);
        }
        else
        {
            make.top.equalTo(theController.readTimesLabel.mas_bottom).with.offset(20);
        }
        
    }];
    
    headerHeight += 15 + 20;//bt
    headerHeight += 20;//下间隙
    
    [self.praiseTimesLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(theController.praiseBtn.mas_right).with.offset(10);
        make.centerY.equalTo(theController.praiseBtn.mas_centerY);
        make.width.mas_equalTo(100);
        
    }];
    
    self.headerView.frame = CGRectMake(0, 0, ScreenW, headerHeight);
    
    return self.headerView;
}

- (void)_setNavigaitonUI
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //设置在导航栏任由滚动视图遮盖
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //返回按钮
    self.navigationItem.hidesBackButton = YES;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/return_w.png",sourceBundle.resourcePath];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 13.5, 22);
    [backBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(_popController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
}

- (void)_share
{
    __weak typeof (self) theController = self;
    
    NSString *imgUrl = self.currentArticle.displayImgs.firstObject[@"url"];
    
    if (!imgUrl)
    {
        imgUrl = [[NSBundle bundleWithPath:[CMSUIUtils UIBundleResourcePath]] pathForResource:@"/Resource/defaultShare@2x"
                                                                                       ofType:@"png"];
    }
    
    NSString *desc = [MOBFApplication name];
    if (self.currentArticle.videoDesc)
    {
        desc = [self.currentArticle.videoDesc stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        desc = [desc stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    }
    
    [CMSSDK showShareActionSheet:nil
                           items:@[
                                   @(1),
                                   @(10),
                                   @(998),
                                   @(18),
                                   @(22),
                                   @(23),
                                   ]
                             url:self.currentArticle.shareUrl
                        imageUrl:imgUrl
                           title:self.currentArticle.title
                            text:desc
             onShareStateChanged:^(NSInteger state, NSInteger platformType, NSDictionary *userData, NSDictionary *contentEntity, NSError *error, BOOL end) {
                 
                 if (platformType != 0)
                 {
                     [CMSUIUtils showShareResultInView:theController.view withState:state];
                     
                 }                 
             }];
    
}

- (void)_setCommentViewUI
{
    self.commentView = [[UIView alloc] init];
    self.commentView.backgroundColor = [MOBFColor colorWithRGB:0xFFFFFF];
    self.commentView.layer.borderWidth = 0.5;
    self.commentView.layer.borderColor = [MOBFColor colorWithRGB:0xC8C8C8].CGColor;
    [self.view addSubview:self.commentView];
    
    __weak typeof(self) theController = self;
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(theController.view.mas_bottom).with.offset([CMSUIUtils isIPhoneX] ? -34 : 0 );
        make.width.mas_equalTo(ScreenW);
        make.height.mas_equalTo(CommentToolViewH);
        
    }];
    
    UITextField *textField = [[UITextField alloc] init];
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:CMSUICommentBottomText
                                                                      attributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:CMSUICommentBottomTextFontSize]}];
    textField.tintColor = [UIColor clearColor];
    textField.attributedPlaceholder = placeholder;
    textField.backgroundColor = [MOBFColor colorWithRGB:0xF4F5F6];
    textField.layer.cornerRadius = 17;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [MOBFColor colorWithRGB:0xE3E3E3].CGColor;
    textField.delegate = self;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
//    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/pls.png",sourceBundle.resourcePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/pinglun.png",sourceBundle.resourcePath];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(_showCommentsController) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    label.layer.cornerRadius = 6;
    label.layer.backgroundColor = [MOBFColor colorWithRGB:0xFF2B2B].CGColor;
    if (self.currentArticle.commentTimes == 0)
    {
        label.hidden = YES;
    }
    self.commentTimesLabel = label;
    
    NSString *writeImgPath = [NSString stringWithFormat:@"%@/Resource/xiepl.png",sourceBundle.resourcePath];
    UIImageView *writeIcon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:writeImgPath]];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.hidden = YES;
    NSString *shareImgPath = [NSString stringWithFormat:@"%@/Resource/fx.png",sourceBundle.resourcePath];
    [shareBtn setBackgroundImage:[UIImage imageWithContentsOfFile:shareImgPath] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(_share) forControlEvents:UIControlEventTouchUpInside];

    [self.commentView addSubview:textField];
    [self.commentView addSubview:commentBtn];
    [self.commentView addSubview:label];
    [self.commentView addSubview:writeIcon];
    [self.commentView addSubview:shareBtn];

    if ([CMSSDK isSupportShare] && self.currentArticle.shareUrl)
    {
        shareBtn.hidden = NO;
    }
    else
    {
        shareBtn.hidden = YES;
    }
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(theController.commentView.mas_left).with.offset(10);
        make.right.equalTo(commentBtn.mas_left).with.offset(-30);
        make.centerY.equalTo(theController.commentView.mas_centerY);
        make.height.mas_equalTo(@35);
    }];
    
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(theController.commentView.mas_centerY);
        make.right.equalTo(theController.commentView.mas_right).with.offset(-15);
        make.height.mas_equalTo(@20);
        make.width.mas_equalTo(@20);
        
    }];
    
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(theController.commentView.mas_centerY);
        if (!shareBtn.hidden)
        {
            make.right.equalTo(shareBtn.mas_left).with.offset(-25);
        }
        else
        {
            make.right.equalTo(theController.commentView.mas_right).with.offset(-15);
        }
        
        make.height.mas_equalTo(@20);
        make.width.mas_equalTo(@20);
        
    }];

    
    [writeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textField.mas_left).with.offset(10);
        make.centerY.equalTo(textField.mas_centerY).with.offset(-2);
        make.height.mas_equalTo(@14);
        make.width.mas_equalTo(@15);
    }];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(commentBtn.mas_top).with.offset(-5);
        make.left.equalTo(commentBtn.mas_centerX);
    }];

}

- (void)_updateUI
{
    __weak typeof(self) theController = self;
    
    self.videoErrorView.hidden = YES;
    [self _prepareControlUI];

    self.player.url = [NSURL URLWithString:self.currentArticle.videoUrl];
    self.titleLable.text = [NSString stringWithFormat:@"%@",self.currentArticle.title];
    self.readTimesLabel.text = [self _getReadTimes:self.currentArticle.readTimes];
    self.creatTimesLabel.text = [self _getCreatDateStr:self.currentArticle.updateAt];
    NSString *desc = [self.currentArticle.videoDesc stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    desc = [desc stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    self.descLabel.text = desc;
    
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
    
    NSDictionary *imgDict = self.currentArticle.displayImgs.firstObject;
    NSURL *url = [NSURL URLWithString:imgDict[@"url"]];
    
    if (url)
    {
        self.obs = [[MOBFImageGetter sharedInstance] getImageWithURL:url result:^(UIImage *image, NSError *error) {
            
            if (image)
            {
                theController.videoPreview.image = image;
            }
        }];

    }

    self.praiseTimesLabel.text = [NSString stringWithFormat:@"%lu", self.currentArticle.praiseTimes];
    self.commentTimesLabel.text = [self _getCommmentTimes:self.currentArticle.commentTimes];
    CGFloat labelWidth = [self _getWidthWithTitle: self.commentTimesLabel.text font:[UIFont systemFontOfSize:8]];
    [self.commentTimesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@11);
        make.width.mas_equalTo(labelWidth);
    }];
    
    
    [CMSSDK checkArticlePraiseStatus:self.currentArticle
                              result:^(BOOL isPraised, NSError *error) {
        
                                  if (error == nil)
                                  {
                                      if (isPraised)
                                      {
                                          theController.praiseBtn.selected = YES;
                                          theController.praiseBtn.userInteractionEnabled = NO;
                                      }
                                      else
                                      {
                                          theController.praiseBtn.selected = NO;
                                      }
                                  }
                                  else
                                  {
                                      theController.praiseBtn.userInteractionEnabled = NO;
                                  }
                                  
    }];
    
}

- (void)_prepareControlUI
{
    [self _resetPlayer];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];

    __weak typeof(self) theController = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_showOrHideControl)];
    tap.enabled = NO;
    tap.delegate = self;
    self.controlTap = tap;
    [self.player addGestureRecognizer:tap];
    
    UIView *controlView = [[UIView alloc] init];
    controlView.frame = self.player.bounds;
    controlView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    controlView.alpha = 0;
    self.controlView = controlView;
    
    UILabel *curTimeLabel = [[UILabel alloc] init];
    curTimeLabel.font = [UIFont systemFontOfSize:13];
    curTimeLabel.textColor = [UIColor whiteColor];
    curTimeLabel.backgroundColor = [UIColor clearColor];
    [self.controlView addSubview:curTimeLabel];
    [curTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(theController.controlView.mas_left).with.offset(10);
        make.bottom.equalTo(theController.controlView.mas_bottom).with.offset(-20);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(40);
    }];
    self.currentTimeLabel = curTimeLabel;

    UISlider *slide = [[UISlider alloc] initWithFrame:CGRectZero];
    slide.minimumValue = 0;
    slide.maximumValue = 0;
    slide.minimumTrackTintColor = [MOBFColor colorWithRGB:0xE66159];
    slide.maximumTrackTintColor = [UIColor clearColor];
    [slide addTarget:self action:@selector(_sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [slide addTarget:self action:@selector(_sliderFinishedValueChange:) forControlEvents:UIControlEventTouchUpInside];
    NSString *imgPath =  [NSString stringWithFormat:@"%@/Resource/bf",sourceBundle.resourcePath];
    [slide setThumbImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [self.controlView addSubview:slide];
    [slide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(theController.currentTimeLabel.mas_centerY);
        make.left.equalTo(theController.currentTimeLabel.mas_right).with.offset(10);
        make.width.mas_equalTo(ScreenW - 60 * 2 - 20);
        make.height.mas_equalTo(8);
    }];
    self.controlSlider = slide;
    
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.trackTintColor = [MOBFColor colorWithRGB:0x999999];
    progress.progressTintColor = [UIColor whiteColor];
    [self.controlView addSubview:progress];
    [progress mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(theController.controlSlider);
        make.height.mas_equalTo(1);
        make.left.equalTo(theController.controlSlider);
        make.top.equalTo(theController.controlSlider.mas_top).with.offset(4.0);
    }];
    self.controlProgress = progress;
    [self.controlView bringSubviewToFront:slide];
    
    UILabel *totalTimeLabel = [[UILabel alloc] init];
    totalTimeLabel.font = [UIFont systemFontOfSize:13];
    totalTimeLabel.textColor = [UIColor whiteColor];
    totalTimeLabel.backgroundColor = [UIColor clearColor];
    [self.controlView addSubview:totalTimeLabel];
    [totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(theController.controlSlider.mas_right).with.offset(10);
        make.centerY.equalTo(theController.controlSlider);
        make.height.mas_equalTo(14);
        make.width.mas_equalTo(40);
    }];
    
    self.totalTimeLabel = totalTimeLabel;
    
    UIButton *fullSrceen = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *minImgPath =  [NSString stringWithFormat:@"%@/Resource/quanping.png",sourceBundle.resourcePath];
    NSString *maxImgPath =  [NSString stringWithFormat:@"%@/Resource/suoxiao.png",sourceBundle.resourcePath];
    [fullSrceen setImage:[UIImage imageWithContentsOfFile:minImgPath] forState:UIControlStateNormal];
    [fullSrceen setImage:[UIImage imageWithContentsOfFile:maxImgPath] forState:UIControlStateSelected];
    [fullSrceen addTarget:self action:@selector(_fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:fullSrceen];
    
    [fullSrceen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(theController.controlSlider.mas_centerY);
        make.right.equalTo(theController.controlView.mas_right).with.offset(-5);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
        
    }];
    self.fullScreenButton = fullSrceen;
    
    UIButton *pause = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *playImgPath =  [NSString stringWithFormat:@"%@/Resource/bofang.png",sourceBundle.resourcePath];
    NSString *pauseImgPath =  [NSString stringWithFormat:@"%@/Resource/zt.png",sourceBundle.resourcePath];
    [pause setImage:[UIImage imageWithContentsOfFile:pauseImgPath] forState:UIControlStateNormal];
    [pause setImage:[UIImage imageWithContentsOfFile:playImgPath] forState:UIControlStateSelected];
    [pause addTarget:self action:@selector(_pauseVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlView addSubview:pause];
    [pause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(40);
        make.centerX.equalTo(theController.controlView.mas_centerX);
        make.centerY.equalTo(theController.controlView.mas_centerY);
    }];
    self.pauseButton = pause;
    
    UIProgressView *loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    loadingProgress.frame = CGRectMake(0, self.player.frame.size.height - 1, ScreenW, 0);
    loadingProgress.trackTintColor = [UIColor clearColor];
    loadingProgress.progressTintColor = [MOBFColor colorWithRGB:0xE0E0E0];
    [self.player addSubview:loadingProgress];
    self.loadingProgress = loadingProgress;
    
    UIProgressView *playingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    playingProgress.frame = CGRectMake(0, 0, ScreenW, 0);
    playingProgress.trackTintColor = [UIColor clearColor];
    playingProgress.progressTintColor = [MOBFColor colorWithRGB:0xE66159];
    [self.loadingProgress addSubview:playingProgress];
    self.playingProgress = playingProgress;
    
    self.loadingProgress.hidden = YES;
    self.playingProgress.hidden = YES;

}

- (void)_showCommentsController
{
    CMSCommentListViewController *commentVC = [[CMSCommentListViewController alloc] init];
    commentVC.article = self.currentArticle;
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (UIImage *)_getStatusImageWith:(BOOL)isOpen
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = nil;
    
    if (isOpen)
    {
        imgPath =  [NSString stringWithFormat:@"%@/Resource/zhankai.png",sourceBundle.resourcePath];
    }
    else
    {
        imgPath =  [NSString stringWithFormat:@"%@/Resource/yincang.png",sourceBundle.resourcePath];
    }
    
    return [UIImage imageWithContentsOfFile:imgPath];
}

- (UIImage *)_getPraiseImageWith:(BOOL)isPraised
{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = nil;
    
    if (isPraised)
    {
        imgPath =  [NSString stringWithFormat:@"%@/Resource/zan_2.png",sourceBundle.resourcePath];
    }
    else
    {
        imgPath =  [NSString stringWithFormat:@"%@/Resource/zan.png",sourceBundle.resourcePath];
    }
    
    return [UIImage imageWithContentsOfFile:imgPath];
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

- (NSString *)_getCreatDateStr:(NSTimeInterval)updateAt
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:updateAt/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日发布"];
    
    return [dateFormatter stringFromDate:date];
}

- (NSString *)_getCommmentTimes:(NSInteger)commentTimes
{
    NSString *labelText = [NSString stringWithFormat:@"%ld",(long)commentTimes];
    
    if (commentTimes > 1000)
    {
        labelText = [NSString stringWithFormat:@"%.1f万",commentTimes/10000.0];
    }
    
    return labelText;
}

- (void)_reloadRecommendData
{
    self.recommendErrorView.hidden = YES;
    self.isLoadingRecommend = YES;
    
    [self.loadMoreView startAnimation];
    
    __weak typeof(self) theController = self;
    [CMSSDK getRecommendArticles:self.artileID
                          pageNo:self.currentPageNo
                        pageSize:20
                          result:^(NSArray<CMSSDKArticle *> *articleList, NSError *error) {
                              
                              theController.isLoadingRecommend = NO;
                              [theController.loadMoreView stopAnimation];
                              
                              if (error == nil)
                              {
                                  if (theController.currentPageNo == 0)
                                  {
                                      //当第一次加载成功的时候才将列表添加出来
                                      [theController.view insertSubview:theController.tableView atIndex:0];
                                  }
                                  
                                  if (articleList.count > 0)
                                  {
                                      theController.currentPageNo += articleList.count;
                                      [theController.recommendDataArray addObjectsFromArray:articleList];
                                  }
                                  
                                  [theController.tableView reloadData];
                                  
                                  if (articleList.count < 20)
                                  {
                                      [theController.loadMoreView noMoreData];
                                  }
                                  
                              }
                              else
                              {
                                  //评论列表加载失败
                                  if (theController.currentPageNo == 0)
                                  {
                                      //当第一次加载且加载失败时显示 失败重试界面
                                      theController.recommendErrorView.hidden = NO;
                                      
                                  }
                              }
                              
                          }];
    
}

#pragma mark - UIViewController Method
- (void)dealloc
{
    [self.player dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //控制器销毁是 通知,显示导航栏
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VideoTypeControllerHideStatusBar"
                                                        object:@(NO)];
    
    [[MOBFImageGetter sharedInstance] removeImageObserver:self.obs];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end

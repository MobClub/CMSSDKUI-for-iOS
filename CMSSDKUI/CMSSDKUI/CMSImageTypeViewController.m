//
//  CMSImageTypeViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSImageTypeViewController.h"
#import "CMSCommentListViewController.h"
#import "View+MASAdditions.h"
#import "CMSUIUtils.h"
#import "DRPLoadingSpinner.h"

#import "CMSImageContentViewController.h"

#import <MOBFoundation/MOBFApplication.h>
#import <MOBFoundation/MOBFImageGetter.h>
#import <MOBFoundation/MOBFColor.h>
#import <CMSSDK/CMSSDK+Share.h>

@interface CMSImageTypeViewController () <UIScrollViewDelegate,
                                          UITextFieldDelegate,
                                          UIPageViewControllerDelegate,
                                          UIPageViewControllerDataSource>

@property (nonatomic, strong) CMSSDKArticle *currentArticle;

@property (nonatomic, weak) UITextView *textView;

@property (nonatomic, weak) UIView *commentView;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic) BOOL isHiddenAll;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSMutableArray *contentControllers;

@property (nonatomic, strong) DRPLoadingSpinner *spinner;

/**
 *  网络错误视图
 */
@property (nonatomic, weak) UIView *netErrorView;

@end

@implementation CMSImageTypeViewController

- (instancetype)initWithArticleID:(NSString *)articleID
{
    if (self = [super init])
    {
        self.artileID = articleID;
        self.isHiddenAll = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_changeCurrentIndex:)
                                                 name:@"CMSImageTypeCurrenIndex"
                                               object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_showOrHide)];
    [self.view addGestureRecognizer:tap];
    
    [self _loadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];

    [self _setNavigaitonUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)_changeCurrentIndex:(NSNotification *)notif
{
    NSInteger currentIndex = [notif.object integerValue];
    self.currentIndex = currentIndex;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    //翻页替换文字
    _currentIndex = currentIndex;
    
    int total = (int)self.dataArray.count;

    NSString *countStr = [NSString stringWithFormat:@"%d/%d", (int)currentIndex, total];
    NSDictionary *dict = self.dataArray[currentIndex - 1];
    NSString *text = [NSString stringWithFormat:@"  %@",dict[@"desc"]];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",countStr,text]];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, countStr.length - 2)];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(countStr.length, attStr.length - countStr.length)];
    
    //设置行间距
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.f];
    //把行间距模型加入NSMutableAttributedString模型
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attStr length])];
    
    self.textView.attributedText = attStr;
    [self.view bringSubviewToFront:self.textView];
    CGFloat textViewH = [self _getHeightByWidth:ScreenW  title:text font:[UIFont systemFontOfSize:19]] + 10;
    
    self.textView.scrollEnabled = textViewH > 200 ? YES : NO;
    textViewH = MIN(200, textViewH);
    
    __weak typeof(self) theController = self;
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.commentView.mas_top).with.offset(-textViewH);
        make.width.mas_equalTo(ScreenW);
        make.bottom.equalTo(theController.commentView.mas_top);
        
    }];
    
}

#pragma mark - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
               viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    NSUInteger index = [self.contentControllers indexOfObject:((CMSImageContentViewController *)viewController)];
    
    // index 为 0 表示已经翻到最前页
    if (index == 0 || index == NSNotFound)
    {
        return  nil;
    }
    
    // 下标自减
    index --;
    
    return self.contentControllers[index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController
                viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.contentControllers indexOfObject:((CMSImageContentViewController *)viewController)];
    
    // index为数组最末表示已经翻至最后页
    if (index == NSNotFound || index == (self.contentControllers.count - 1))
    {
        return nil;
    }
    
    // 下标自增
    index ++;
    
    return self.contentControllers[index];
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
                            result:^(CMSSDKComment *newComment, MOBFUser *user,NSError *error) {
                                
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

#pragma mark - Lazy Method
- (DRPLoadingSpinner *)spinner
{
    if (_spinner == nil)
    {
        DRPLoadingSpinner *spinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake((ScreenW - 50 ) / 2,
                                                                                         (ScreenH - 50 ) / 2 - 100,
                                                                                         50,
                                                                                         50)];
        
        spinner.rotationCycleDuration = 1.5;
        spinner.drawCycleDuration = 0.75;
        spinner.drawTimingFunction = [DRPLoadingSpinnerTimingFunction sharpEaseInOut];
        spinner.colorSequence = @[[UIColor whiteColor]];
        _spinner = spinner;
        [self.view insertSubview:spinner atIndex:0];
    }
    return _spinner;
}

- (UIPageViewController *)pageViewController
{
    if (_pageViewController == nil)
    {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:@{UIPageViewControllerOptionInterPageSpacingKey : @(5)}];
        
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
    
    return _pageViewController;
}

- (NSMutableArray *)contentControllers
{
    if (_contentControllers == nil)
    {
        _contentControllers = [NSMutableArray array];
    }
    return _contentControllers;
}

- (UIView *)netErrorView
{
    if (_netErrorView == nil)
    {
        UIView *netErrorView = [[UIView alloc] initWithFrame:self.view.frame];
        netErrorView.backgroundColor = [UIColor blackColor];
        _netErrorView = netErrorView;
        [self.view addSubview:_netErrorView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/wwl.png",[CMSUIUtils UIBundleResourcePath]];
        imageView.image = [UIImage imageWithContentsOfFile:imgPath];
        [netErrorView addSubview:imageView];
        
        UILabel *lalbel = [[UILabel alloc] init];
        lalbel.text = @"加载文章失败";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [MOBFColor colorWithRGB:0x999999];
        [netErrorView addSubview:lalbel];
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_loadData) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [reloadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [netErrorView addSubview:reloadBtn];
        
        netErrorView.hidden = YES;
        
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

#pragma mark - Private Method

- (void)_share
{
    __weak typeof (self) theController = self;
    
    NSString *imgUrl = self.currentArticle.displayImgs.firstObject[@"url"];
    
    if (!imgUrl)
    {
        imgUrl = [[NSBundle bundleWithPath:[CMSUIUtils UIBundleResourcePath]] pathForResource:@"/Resource/defaultShare@2x"
                                                                                       ofType:@"png"];
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
                            text:[MOBFApplication name]
             onShareStateChanged:^(NSInteger state, NSInteger platformType, NSDictionary *userData, NSDictionary *contentEntity, NSError *error, BOOL end) {
                 
                 if (platformType != 0)
                 {
                     [CMSUIUtils showShareResultInView:theController.view withState:state];
                     
                 }
                 
             }];
    
}

- (void)_loadData
{
    __weak typeof(self) theController = self;
    self.netErrorView.hidden = YES;
    
    [self.spinner startAnimating];
    [CMSSDK getArticleDetail:self.artileID result:^(CMSSDKArticle *article, NSError *error) {
        
        if (error == nil)
        {
            theController.currentArticle = article;
            theController.dataArray = [theController _sortDataArray];
            
            [theController _setTextViewUI];
            [theController _setCommentViewUI];
            
            [theController.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSDictionary *dict = obj;
                CMSImageContentViewController *contentVC = [[CMSImageContentViewController alloc] init];
                contentVC.imageURL = [NSURL URLWithString:dict[@"url"]];
                contentVC.current = idx + 1;
                
                [theController.contentControllers addObject:contentVC];
                
            }];
            
            [theController addChildViewController:theController.pageViewController];
            [theController.view addSubview:theController.pageViewController.view];
            
            [theController.pageViewController.view setFrame:CGRectMake(0, 0, ScreenW, ScreenH - CommentToolViewH)];
            
            CMSImageContentViewController *firstVC = theController.contentControllers[0];
            [theController.pageViewController setViewControllers:@[firstVC]
                                                       direction:UIPageViewControllerNavigationDirectionForward
                                                        animated:YES
                                                      completion:nil];
            
            [theController.view bringSubviewToFront:theController.commentView];
            
        }
        else
        {
            theController.netErrorView.hidden = NO;
        }
        
        [theController.spinner stopAnimating];
    }];
    
}

- (void)_showOrHide
{
    __weak typeof(self) theController = self;
    
    self.isHiddenAll = !self.isHiddenAll;
    if (self.isHiddenAll)
    {
        [UIView animateWithDuration:0.5 animations:^{
            theController.navigationController.navigationBar.alpha = 0;
            theController.textView.alpha = 0;
            theController.commentView.alpha = 0;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            theController.navigationController.navigationBar.alpha = 1;
            theController.textView.alpha = 1;
            theController.commentView.alpha = 1;
        }];
    }
    
}

- (void)_setTextViewUI
{
    UITextView *textView = [[UITextView alloc] init];
    textView.alwaysBounceVertical = YES;
    textView.textContainerInset = UIEdgeInsetsMake(10, 10, 0, 10);
    textView.textAlignment = NSTextAlignmentCenter;
    textView.editable = NO;
    textView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.textView = textView;
    [self.view insertSubview:textView atIndex:0];
}

- (void)_setCommentViewUI
{
    __weak typeof(self) theController = self;
    
    UIView *commentView = [[UIView alloc] init];
    self.commentView = commentView;
    [self.view addSubview:commentView];
    [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(theController.view.mas_bottom).with.offset([CMSUIUtils isIPhoneX] ? -34 : 0 );
        make.width.mas_equalTo(ScreenW);
        make.height.mas_equalTo(CommentToolViewH);
        
    }];
    
    UITextField *textField = [[UITextField alloc] init];
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:CMSUICommentBottomText
                                                                      attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                   NSFontAttributeName : [UIFont systemFontOfSize:CMSUICommentBottomTextFontSize]}];
    textField.tintColor = [UIColor clearColor];
    textField.attributedPlaceholder = placeholder;
    textField.backgroundColor = [MOBFColor colorWithRGB:0x181818];
    textField.layer.cornerRadius = 17;
    textField.delegate = self;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
//    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/pls_w.png",sourceBundle.resourcePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/pinglun_W.png",sourceBundle.resourcePath];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(_showCommentsController) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    label.text = [self _getCommmentTimes:self.currentArticle.commentTimes];
    CGFloat labelWidth = [self _getWidthWithTitle:label.text font:[UIFont systemFontOfSize:8]];
    
    label.layer.cornerRadius = 5;
    label.layer.backgroundColor = [MOBFColor colorWithRGB:0xFF2B2B].CGColor;
    if (self.currentArticle.commentTimes == 0)
    {
        label.hidden = YES;
    }
    
    NSString *writeImgPath = [NSString stringWithFormat:@"%@/Resource/xiepl_w.png",sourceBundle.resourcePath];
    UIImageView *writeIcon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:writeImgPath]];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.hidden = YES;
    NSString *shareImgPath = [NSString stringWithFormat:@"%@/Resource/fx_w.png",sourceBundle.resourcePath];
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
        make.height.mas_equalTo(@11);
        make.width.mas_equalTo(labelWidth);
    }];
}

- (void)_showCommentsController
{
    CMSCommentListViewController *commentVC = [[CMSCommentListViewController alloc] init];
    commentVC.article = self.currentArticle;
    [self.navigationController pushViewController:commentVC animated:YES];
}

- (void)_setNavigaitonUI
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //返回按钮
    self.navigationItem.hidesBackButton = YES;
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/close.png",sourceBundle.resourcePath];
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 18, 18);
    [backBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(_popController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
}

- (NSArray *)_sortDataArray
{
    NSArray *imgList = self.currentArticle.imgList;
    return [imgList sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES]]];
}

- (void)_popController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)_getWidthWithTitle:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width + 5;
}

- (CGFloat)_getHeightByWidth:(CGFloat)width title:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenW - 30, 0)];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return height;
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

#pragma mark - UIViewController Method
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

@end

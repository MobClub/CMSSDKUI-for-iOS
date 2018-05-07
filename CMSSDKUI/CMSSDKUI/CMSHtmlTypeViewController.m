//
//  CMSHtmlTypeViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/7.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSHtmlTypeViewController.h"
#import "View+MASAdditions.h"
#import "CMSCommentListViewController.h"
#import "CMSUIUtils.h"
#import <MOBFoundation/MOBFoundation.h>
#import <MOBFoundation/MOBFJSContext.h>
#import <CMSSDK/CMSSDK+Share.h>
#import "DRPLoadingSpinner.h"

@interface CMSHtmlTypeViewController () <UITextFieldDelegate,
                                         UIWebViewDelegate>

/**
 *  当前文章
 */
@property (nonatomic, strong) CMSSDKArticle *currentArticle;

/**
 *  内容页
 */
@property (nonatomic, strong) UIWebView *webView;

/**
 *  评论视图
 */
@property (nonatomic, strong) UIView *commentView;

/**
 *  JavaScript上下文环境
 */
@property (nonatomic, strong) MOBFJSContext *jsContext;

/**
 *  等待指示器
 */
@property (nonatomic, weak) DRPLoadingSpinner *loadingSpin;

/**
 *  网络错误视图
 */
@property (nonatomic, weak) UIView *netErrorView;

@end

@implementation CMSHtmlTypeViewController

- (instancetype)initWithArticleID:(NSString *)articleID
{
    if (self = [super init])
    {
        self.artileID = articleID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view bringSubviewToFront:self.loadingSpin];
    [self _loadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self _setNavigaitonUI];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
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
                            result:^(CMSSDKComment *newComment, MOBFUser *user, NSError *error) {
                                
                                if (error == nil)
                                {
                                    [CMSUIUtils showCommentSuccessAlertInView:theController.view];
                                    [theController _addCommentToHTML:comment user:user];
                                }
                                else
                                {
                                    //评论失败?
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


#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //设定点赞状态
    [self _setPraiseStatus];
    [self.loadingSpin stopAnimating];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingSpin startAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.loadingSpin stopAnimating];
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

/**
 *  设定评论区域UI
 */
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
    [commentBtn addTarget:self action:@selector(_jumpToCommentsArea) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    label.text = [self _getCommmentTimes:self.currentArticle.commentTimes];
    
    CGFloat labelWidth = [self _getWidthWithTitle:label.text font:[UIFont systemFontOfSize:8]];
    if (self.currentArticle.commentTimes == 0)
    {
        label.hidden = YES;
    }
    
    label.layer.cornerRadius = 5;
    label.layer.backgroundColor = [MOBFColor colorWithRGB:0xFF2B2B].CGColor;
    
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
        make.right.equalTo(commentBtn.mas_left).with.offset(-25);
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

- (CGFloat)_getWidthWithTitle:(NSString *)title font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 11, 0)];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    return label.frame.size.width + 5;
}

/**
 *  设定webview
 */
- (void)_setHTMLWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, [CMSUIUtils isIPhoneX] ?  0 : 64, ScreenW, ScreenH)];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
//    NSLog(@"Safe Area:%@",NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    if ([MOBFDevice versionCompare:@"8.0"] > 0)
    {
        self.jsContext = [[MOBFJSContext alloc] initWithContext:[self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"]];
    }
    else
    {
        self.jsContext = [[MOBFJSContext alloc] initWithWebView:self.webView];
    }
    
    [self _registerJSMethod];
    
    
    NSString *htmlFilePath = [NSString stringWithFormat:@"%@/HTML/index.html",[CMSUIUtils UIBundleResourcePath]];
    NSURL *baseURL = [NSURL URLWithString:htmlFilePath];
    NSString *htmlStr = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    
    [self.webView loadHTMLString:htmlStr baseURL:baseURL];
}

- (void)_loadData
{
    [self.loadingSpin startAnimating];
    self.netErrorView.hidden = YES;
    
    __weak typeof(self) theController = self;
    [CMSSDK getArticleDetail:self.artileID result:^(CMSSDKArticle *article, NSError *error) {
        
        if (error == nil)
        {
            theController.currentArticle = article;
            [theController _setHTMLWebView];
            [theController _setCommentViewUI];
        }
        else
        {
            theController.netErrorView.hidden = NO;
        }
        
    }];

}

/**
 *  注册JS方法
 */
- (void)_registerJSMethod
{
    [self _registerPraise];
    [self _registerGetArticleDetail];
    [self _registerGetComments];
}

/**
 *  添加评论至内容页
 *
 *  @param comment 评论
 */
- (void)_addCommentToHTML:(NSString *)comment user:(MOBFUser *)user
{
    if (self.jsContext)
    {
        NSDate *dateNow = [NSDate date];
        NSTimeInterval timeNow = [dateNow timeIntervalSince1970] * 1000;
        
        NSString *userName = @"游客";
        NSString *avatar = user.avatar;
        
        if (user.nickname)
        {
            userName = user.nickname;
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        if (avatar)
        {
            dic[@"avatar"] = avatar;
        }
        
        if (userName)
        {
            dic[@"nickname"] = userName;
        }
        
        if (comment)
        {
            dic[@"content"] = comment;
        }
        
        dic[@"updateAt"] = @(timeNow);
        
        [self.jsContext callJSMethod:@"CMSSDKNative.addComment" arguments:@[dic]];
    }
}

/**
 *  移动至评论区
 */
- (void)_jumpToCommentsArea
{
    if (self.jsContext)
    {
        [self.jsContext callJSMethod:@"CMSSDKNative.ToCommentposition" arguments:@[]];
    }
}

- (void)_setPraiseStatus
{
    
    if (self.jsContext)
    {
        __weak typeof(self) theController = self;

        [CMSSDK checkArticlePraiseStatus:self.currentArticle
                                  result:^(BOOL isPraised, NSError *error) {
                                      
                                      [theController.jsContext callJSMethod:@"CMSSDKNative.isPraised" arguments:@[@(isPraised)]];

        }];
        
    }
}

/**
 *  注册点赞方法
 */
- (void)_registerPraise
{
    if (self.jsContext)
    {
        __weak typeof(self) theController = self;
        
        [self.jsContext registerJSMethod:@"praise" block:^(NSArray *arguments) {
            
            NSString *callback = nil;
            if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]])
            {
                callback = arguments [0];
            }

            [CMSSDK praiseArticle:theController.currentArticle result:^(NSError *error) {
               
                if (error == nil)
                {
                    //点赞成功
                    //当只有成功的时候才回调
                    [theController _callback:callback resultData:@{}];
                }
                
            }];
            
        }];
    }
}

/**
 *  注册获取文章详情
 */
- (void)_registerGetArticleDetail
{
    if (self.jsContext)
    {
        __weak typeof(self) theController = self;
        
        [self.jsContext registerJSMethod:@"getArticleDetail" block:^(NSArray *arguments) {
           
            NSString *callback = nil;
            if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSString class]])
            {
                callback = arguments [0];
            }
            NSDictionary *valueDict = [theController.currentArticle dictionaryValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [theController _callback:callback resultData:valueDict];
            });
            
        }];
    }
}

/**
 *  注册获取评论列表
 */
- (void)_registerGetComments
{
    if (self.jsContext)
    {
        __weak typeof (self) theController = self;
        [self.jsContext registerJSMethod:@"getComments" block:^(NSArray *arguments) {
           
            NSInteger pageNo = 0;
            NSInteger pageSize = 0;
            NSString *callback = nil;
            if (arguments.count > 0 && [arguments[0] isKindOfClass:[NSNumber class]])
            {
                pageNo = [arguments [0] integerValue];
            }
            if (arguments.count > 1 && [arguments[1] isKindOfClass:[NSNumber class]])
            {
                pageSize = [arguments [1] integerValue];
            }
            
            if (arguments.count > 2 && [arguments[2] isKindOfClass:[NSString class]])
            {
                callback = arguments [2];
            }
            
            [CMSSDK getCommentsList:theController.currentArticle
                             pageNo:pageNo
                           pageSize:pageSize
                             result:^(NSArray<CMSSDKComment *> *commentsList, NSError *error) {
                                 
                                 
                                 if (error == nil)
                                 {
                                     
                                     if (commentsList.count > 0)
                                     {
                                         
                                         NSMutableArray *array = [NSMutableArray array];
                                         
                                         for (CMSSDKComment *comment in commentsList)
                                         {
                                             NSMutableDictionary *commentDict = [NSMutableDictionary dictionaryWithDictionary:[comment dictionaryValue]];
                                             
                                             NSString *avatar = commentDict[@"avatar"];
                                             
                                             if (avatar.length > 0)
                                             {
                                                 
                                                 NSArray *avatarArr = [MOBFJson objectFromJSONString:avatar];
                                                 if (avatarArr && avatarArr.count > 0)
                                                 {
                                                     avatar = avatarArr.lastObject;
                                                 }
                                                 
                                                 commentDict[@"avatar"] = avatar;
                                             }
                                             
                                             [array addObject:commentDict];
                                         }
                                         
                                         NSDictionary *dataDict = @{@"comments" : array};
 
                                         [theController _callback:callback resultData:dataDict];
                                     }
                                     else
                                     {
                                         [theController _callback:callback resultData:nil];
                                     }
                                     
                                 }
                
            }];
            
        }];
    }
}

/**
 *  设置导航栏UI
 */
- (void)_setNavigaitonUI
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    
    //返回按钮
    self.navigationItem.hidesBackButton = YES;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"CMSSDKUI" ofType:@"bundle"];
    NSBundle *sourceBundle = [NSBundle bundleWithPath:bundlePath];
    NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/return.png",sourceBundle.resourcePath];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 18, 18);
    [backBtn setBackgroundImage:[UIImage imageWithContentsOfFile:imgPath] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(_popController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)_popController
{
    [self.navigationController popViewControllerAnimated:YES];
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

/**
 *  JS回调方法
 *
 *  @param callback   回调名称
 *  @param resultData 回调数据
 */
- (void)_callback:(NSString *)callback resultData:(NSDictionary *)resultData
{
    if (callback)
    {
        if (resultData == nil)
        {

            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(null)", callback]];
        }
        else
        {
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@)", callback, [MOBFJson jsonStringFromObject:resultData]]];
        }
    }
}

#pragma mark - Lazy Method
/**
 *  获取等待指示器
 *
 *  @return 指示器
 */
- (DRPLoadingSpinner *)loadingSpin
{
    if (_loadingSpin == nil)
    {
        DRPLoadingSpinner *spin = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake((ScreenW - 50) / 2, (ScreenH - 50) / 2 - 100, 50,50 )];
        spin.rotationCycleDuration = 500000;
        spin.maximumArcLength = M_PI;
        spin.drawCycleDuration = 0.5;
        spin.drawTimingFunction = [DRPLoadingSpinnerTimingFunction easeInOut];
        spin.colorSequence = @[ [UIColor lightGrayColor] ];
        spin.lineWidth = 3.;

        _loadingSpin = spin;
        [self.view addSubview:_loadingSpin];
    }
    
    return _loadingSpin;
}

/**
 *  网络错误视图
 *
 *  @return 视图对象
 */
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
        lalbel.text = @"加载文章失败";
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

#pragma mark - UIViewController Method
- (void)dealloc
{
    self.webView.delegate = nil;
    self.webView = nil;
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

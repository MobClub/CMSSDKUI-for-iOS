//
//  CMSMainViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/24.
//  Copyright © 2017年 Mob. All rights reserved.
//



#define LargeFont [UIFont systemFontOfSize:15.5 * [UIScreen mainScreen].bounds.size.width / 375]
#define NomalFont [UIFont systemFontOfSize:15 * [UIScreen mainScreen].bounds.size.width / 375]
#define SmallFont [UIFont systemFontOfSize:11 * [UIScreen mainScreen].bounds.size.width / 375]

#define DefaultTitleMargin 15.0
//从上到下图层高度

#define TopViewH 60
#define TitleScrollViewH 40.0

#define TabbarH 49.0

#import "CMSLayout.h"
#import "CMSMainViewController.h"
#import "CMSArticleListViewController.h"
#import "CMSListTableViewController.h"
#import <CMSSDK/CMSSDK.h>
#import <MOBFoundation/MOBFColor.h>
#import "CMSUIUtils.h"
#import "View+MASAdditions.h"


static NSString *const cellID = @"contentCellIdentifier";

@interface CMSMainViewController ()<UICollectionViewDataSource,
                                    UICollectionViewDelegate>


//所有控件的俯视图,于self.view 之上，与所有subView之下
@property (nonatomic, weak) UIView *baseView;

//标题滚动栏
@property (nonatomic, weak) UIScrollView *titleScrollView;

//资讯主题内容页
@property (nonatomic, weak) UICollectionView *contentView;

@property (nonatomic, strong) NSMutableArray *titleLabels;
//标题宽度数组
@property (nonatomic, strong) NSMutableArray *titleWidths;
//标题间隔
@property (nonatomic, assign) CGFloat titleMargin;
//当前选中标题的下标
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, weak) UIView *netErrorView;

@end

@implementation CMSMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;//在present使用时会影响到titleScrollView布局，必须要设置成NO
    self.view.backgroundColor = [UIColor whiteColor];


    CMSArticleListViewController *listVC = (CMSArticleListViewController *)self.navigationController.parentViewController;
    
    if (listVC.leftBarButtonItem)
    {
        self.navigationItem.leftBarButtonItem = listVC.leftBarButtonItem;
    }
    
    if (listVC.rightBarButtonItem)
    {
        self.navigationItem.rightBarButtonItem = listVC.leftBarButtonItem;
    }
    
    self.title = @"MobSDK";
    
    if (listVC.CMSTitle)
    {
        self.title = listVC.CMSTitle;
    }
    
    [self _loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _setNavigationbarUI];
}

#pragma mark - Private Method
- (void)_loadData
{
    __weak typeof(self) theController = self;
    
    [CMSSDK getArticleTypes:^(NSArray<CMSSDKArticleType *> *typeList, NSError *error) {
        
        if (error == nil)
        {
            theController.netErrorView.hidden = YES;
            
            for (CMSSDKArticleType *type in typeList)
            {
                CMSListTableViewController *childListController = [[CMSListTableViewController alloc] init];
                childListController.articleType = type;
                childListController.title = type.name;
                [theController addChildViewController:childListController];
                
            }
            
            [theController _refreshView];
        }
        else
        {
            theController.netErrorView.hidden = NO;
        }
        
    }];
}

- (void)_reload
{
    [self _loadData];
}

- (void)_setNavigationbarUI
{
    //清空所有设定的图片
    self.navigationController.navigationBar.barTintColor = [MOBFColor colorWithRGB:0xFF2B2B];
//    self.title = [CMSUIUtils sharedInstance].CMSTitle ? [CMSUIUtils sharedInstance].CMSTitle : @"MobSDK";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)_calculateTitleWidth
{
    NSInteger count = self.childViewControllers.count;
    
    if (count == 0 )
    {
        return;
    }
    
    CGFloat totalWidth;
    
    NSArray *titles = [self.childViewControllers valueForKey:@"title"];
    for (NSString *title in titles)
    {
        CGRect titleBounds = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]}
                                                 context:nil];
        
        CGFloat width = titleBounds.size.width;
        
        [self.titleWidths addObject:@(width)];
        
        totalWidth += width;
    }
    
    if (totalWidth > ScreenW)
    {
        _titleMargin = DefaultTitleMargin;
        self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
    }
    
    CGFloat titleMargin = (ScreenW - totalWidth) / (count + 1);
    _titleMargin = titleMargin < DefaultTitleMargin? DefaultTitleMargin: titleMargin;
    self.titleScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, _titleMargin);
}

- (void)_setupScrollTitle
{
    NSInteger count = self.childViewControllers.count;
    
    if (count == 0)
    {
        return;
    }
    
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelW = 0;
    CGFloat labelH = TitleScrollViewH;
    
    for (int i = 0 ;i < count ; i++)
    {
        NSString *title = self.childViewControllers[i].title;
        UILabel *label = [[UILabel alloc] init];
        label.tag = i;
        label.textAlignment = NSTextAlignmentLeft;
        label.text = title;
        label.font = [UIFont systemFontOfSize:17];
        label.userInteractionEnabled = YES;
        labelW = [self.titleWidths[i] floatValue];
        
        UILabel *lastLabel = self.titleLabels.lastObject;
        labelX = DefaultTitleMargin + CGRectGetMaxX(lastLabel.frame);
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_clickTitle:)];
        [label addGestureRecognizer:tap];
        
        [self.titleLabels addObject:label];
        [self.titleScrollView addSubview:label];
        
        //应用起始选定0角标
        if (i == 0)
        {
            [self _clickTitle:tap];
        }
    }
    
    UILabel *lastLabel = self.titleLabels.lastObject;
    self.titleScrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastLabel.frame), TitleScrollViewH);
    self.contentView.contentSize = CGSizeMake(count * ScreenW, 0);
    
}

- (void)_refreshView
{
    [self.contentView reloadData];
    
    // 清空之前所有标题
    [self.titleLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.titleLabels removeAllObjects];
    
    [self _calculateTitleWidth];
    [self _setupScrollTitle];
}

/**
 *  点击标题
 *
 *  @param tap 手势
 */
- (void)_clickTitle:(UITapGestureRecognizer *)tap
{
    UILabel *label = (UILabel *)tap.view;
    [self _updateLabel:label];
    
    // 内容滚动视图滚动到对应位置
    CGFloat offsetX = label.tag * ScreenW;
    
    self.contentView.contentOffset = CGPointMake(offsetX, 0);

}

/**
 *  更新标题(颜色选中等)
 *
 *  @param selectLabel 选中的标题
 */
- (void)_updateLabel:(UILabel *)selectLabel
{
    if (self.titleLabels.count > 0)
    {
        for (UILabel *label in self.titleLabels)
        {
            if (label != selectLabel)
            {
                label.textColor = [MOBFColor colorWithRGB:0x222222];
                label.font = [UIFont systemFontOfSize:17];
            }
        }
        
        selectLabel.textColor = [MOBFColor colorWithRGB:0xE66159];
        selectLabel.font = [UIFont systemFontOfSize:19];
        [self _setLabelTitleCenter:selectLabel];
    }
}

- (void)_setLabelTitleCenter:(UILabel *)label
{
    // 设置标题滚动区域的偏移量
    CGFloat offsetX = label.center.x - ScreenW * 0.5;
    
    if (offsetX < 0)
    {
        offsetX = 0;
    }
    
    // 计算下最大的标题视图滚动区域
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - ScreenW + _titleMargin;
    
    if (maxOffsetX < 0)
    {
        maxOffsetX = 0;
    }
    
    if (offsetX > maxOffsetX)
    {
        offsetX = maxOffsetX;
    }
    // 滚动区域
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}

#pragma mark - UIScrollViewDelegate
// 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //获取位置角标
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger i = offsetX / ScreenW;
    
    if (self.titleLabels.count > 0 )
    {
        UILabel *label = [self.titleLabels objectAtIndex:i];
        
        if (label.tag == i)
        {
            //与角标吻合,updata标题
            [self _updateLabel:label];
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  
    return self.childViewControllers.count;
}

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    // 移除之前的子控件
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 添加控制器
    UIViewController *vc = self.childViewControllers[indexPath.row];
    vc.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [cell.contentView addSubview:vc.view];
    return cell;
}

#pragma mark - Lazy load
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
        lalbel.text = @"当前网络不通";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [MOBFColor colorWithRGB:0x999999];
        [netErrorView addSubview:lalbel];
        
        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_reload) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新刷新" forState:UIControlStateNormal];
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

- (UIView *)baseView
{
    if (_baseView == nil)
    {
        CGFloat naviHeight = 64;
        if ([CMSUIUtils isIPhoneX])
        {
            naviHeight = 88;//iphone x 导航栏高度为88
        }

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                self.navigationController == nil ? 0 : naviHeight,
                                                                ScreenW,
                                                                ScreenH - (self.tabBarController == nil ? 0 : TabbarH))];
        
        _baseView = view;
        [self.view addSubview:_baseView];
    }
    return _baseView;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil)
    {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (UIScrollView *)titleScrollView
{
    if (_titleScrollView == nil)
    {
        NSLog(@"navi:%@",self.navigationController);
        
        UIScrollView *titleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                       self.navigationController == nil ? 20 : 0,
                                                                                       ScreenW,
                                                                                       TitleScrollViewH)];
        
        titleScrollView.showsHorizontalScrollIndicator = NO;
        titleScrollView.backgroundColor = [MOBFColor colorWithRGB:0xFFFFFF];
        
        titleScrollView.layer.borderWidth = 0.5;
        titleScrollView.layer.borderColor = [MOBFColor colorWithRGB:0xE1E1E1].CGColor;
        _titleScrollView = titleScrollView;
        [self.baseView addSubview:_titleScrollView];
    }
    
    return _titleScrollView;
}

- (UICollectionView *)contentView
{
    if (_contentView == nil)
    {
        CMSLayout *layout = [[CMSLayout alloc] init];
        UICollectionView *colletionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                             collectionViewLayout:layout];
        _contentView = colletionView;
        _contentView.pagingEnabled = YES;
        _contentView.showsHorizontalScrollIndicator = YES;
        _contentView.bounces = NO;
        _contentView.delegate = self;
        _contentView.dataSource = self;
        _contentView.scrollsToTop = NO;
        // 注册cell
        [_contentView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        _contentView.backgroundColor = self.view.backgroundColor;
        
        [self.baseView addSubview:_contentView];
    }
    
    return _contentView;
}

- (NSMutableArray *)titleWidths
{
    if (_titleWidths == nil)
    {
        _titleWidths = [NSMutableArray array];
    }
    
    return _titleWidths;
}

#pragma mark - UIViewController Method
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat contentY = CGRectGetMaxY(self.titleScrollView.frame);
//    CGFloat contentH = CGRectGetMaxY(self.baseView.frame) - contentY - (self.tabBarController == nil ? 0 : 49);
    CGFloat contentH = CGRectGetMaxY(self.baseView.frame) - contentY;

    self.contentView.frame = CGRectMake(0, contentY, ScreenW, contentH);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

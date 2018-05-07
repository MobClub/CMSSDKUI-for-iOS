 //
//  CMSListTableViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/2/27.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSListTableViewController.h"
#import "CMSTextCell.h"
#import "CMSLeftImageCell.h"
#import "CMSThreeImageCell.h"
#import "CMSRightImageCell.h"
#import "CMSBottomImageCell.h"

#import "CMSSDKArticle+Cell.h"
#import "View+MASAdditions.h"
#import "CMSUIUtils.h"
#import "CMSRefreshView.h"
#import "CMSLoadingMoreView.h"

#import <CMSSDK/CMSSDK.h>
#import <CMSSDK/CMSSDKArticle.h>

#import "CMSHtmlTypeViewController.h"
#import "CMSOutsideTypeViewController.h"
#import "CMSVideoTypeViewController.h"
#import "CMSImageTypeViewController.h"


@interface CMSListTableViewController () <UITableViewDelegate,
                                          UITableViewDataSource,
                                          CMSRefreshViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *cellHightArray;
@property (nonatomic, strong) NSMutableArray *cellTitleHightArray;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic) NSInteger currentPageNo;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isEnd;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) UIView *netErrorView;
@property (nonatomic, weak) UIView *noneDataView;

@property (nonatomic, strong) CMSRefreshView *refreshView;
@property (nonatomic, strong) CMSLoadingMoreView *loadMoreView;

@end

@implementation CMSListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _initUI];
    [self _registerCells];
    [self _cleanAndReloadDataWithRefresh:NO];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMSSDKArticle *article = (CMSSDKArticle *)self.dataArray[indexPath.row];
    CGFloat titleHeight = [self.cellTitleHightArray[indexPath.row] floatValue];
    CMSBaseCell *cell;
    NSString *cellID = [article cellIdentifier];
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    [cell setArticle:article withTitleHeight:titleHeight];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellHightArray[indexPath.row] floatValue];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CMSSDKArticle *article = (CMSSDKArticle *)self.dataArray[indexPath.row];
    
    switch (article.articleType)
    {
        case 1:
        {
            //普通文章-html
            CMSHtmlTypeViewController *htmlViewController = [[CMSHtmlTypeViewController alloc] initWithArticleID:article.articleID];
            [self.navigationController pushViewController:htmlViewController animated:YES];
            break;
        }
        case 2:
        {
            //站外跳转文章
            CMSOutsideTypeViewController *outsideViewController = [[CMSOutsideTypeViewController alloc] initWithArticleID:article.articleID];
            [self.navigationController pushViewController:outsideViewController animated:YES];
            break;
        }
        case 3:
        {
            //短视频文章
            CMSVideoTypeViewController *videoViewController = [[CMSVideoTypeViewController alloc] initWithArticleID:article.articleID];
            
            [self.navigationController pushViewController:videoViewController animated:YES];
            
            break;
        }
            
        case 4:
        {
            //图片文章
            CMSImageTypeViewController *imageViewController = [[CMSImageTypeViewController alloc] initWithArticleID:article.articleID];
            [self.navigationController pushViewController:imageViewController animated:YES];
            break;
        }
    }
    
    CMSBaseCell *cell= (CMSBaseCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setHasBeenRead];
    //缓存文章已读
    [[MOBFDataService sharedInstance] setCacheData:@(YES) forKey:article.articleID domain:CMSUICacheDomain];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.refreshView scrollViewDidScroll:scrollView];
    
    CGFloat height = scrollView.frame.size.height;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat distanceFromBottom = scrollView.contentSize.height - offset;
    
    //滚动到底部加载更多
    if (offset > 0 && distanceFromBottom < height)
    {
        if (!self.isLoading && !self.isEnd)
        {
            [self _loadData];
        }
    }
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    
    if (!self.isLoading)
    {
        if (- scrollView.contentOffset.y / self.tableView.frame.size.height > 0.06)
        {
            //下拉刷新
            [self.refreshView scrollViewWillEndDragging:scrollView
                                           withVelocity:velocity
                                    targetContentOffset:targetContentOffset];
        }
        
    }

}

#pragma mark - RWTRefreshViewDelegate
- (void)refreshViewDidRefresh:(CMSRefreshView *)refreshView
{
    //需要加载
    [self _cleanAndReloadDataWithRefresh:YES];
}

#pragma mark - Private
- (void)_cellHightArrayAddData:(NSArray <CMSSDKArticle*> *)dataArray
{
    for (CMSSDKArticle *article in dataArray)
    {
        CGFloat cellTitleHeight = 20;
        CGFloat cellHeight = TextCellH;
        switch (article.displayType)
        {
            case 0:
            {
                cellTitleHeight = [CMSUIUtils getHeightByWidth:ScreenW - 2 * CellBorderWidth
                                                         title:article.title
                                                          font:[UIFont systemFontOfSize:CMSUICellTitleFontSize]];
                cellHeight = BaseTextCellH + cellTitleHeight;
                break;
            }
            case 1:
            {
                
                cellTitleHeight = [CMSUIUtils getHeightByWidth:ScreenW - 140 - 2 * CellBorderWidth
                                                         title:article.title
                                                          font:[UIFont systemFontOfSize:CMSUICellTitleFontSize]];
                cellHeight = BaseLeftorRightImgCellH;
                break;
            }
            case 2:
            {
                cellTitleHeight = [CMSUIUtils getHeightByWidth:ScreenW - 140 - 2 * CellBorderWidth
                                                         title:article.title
                                                          font:[UIFont systemFontOfSize:CMSUICellTitleFontSize]];
                cellHeight = BaseLeftorRightImgCellH;
                break;
            }
            case 3:
            {
                //计算文字高度
                cellTitleHeight = [CMSUIUtils getHeightByWidth:ScreenW - 2 * CellBorderWidth
                                                         title:article.title
                                                          font:[UIFont systemFontOfSize:CMSUICellTitleFontSize]];
                cellHeight = BaseBottomImgCellH + cellTitleHeight;
                break;
            }
            case 4:
            {
                cellTitleHeight = [CMSUIUtils getHeightByWidth:ScreenW - 2 * CellBorderWidth
                                                         title:article.title
                                                          font:[UIFont systemFontOfSize:CMSUICellTitleFontSize]];
                cellHeight = BaseThreeImgCellH + cellTitleHeight;
                break;
            }
        }

        [self.cellHightArray addObject:@(cellHeight)];
        [self.cellTitleHightArray addObject:@(cellTitleHeight)];
    }

}

- (void)_initUI
{
    CGFloat tabbarH = self.tabBarController ? 150 : 110;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH - tabbarH) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ([CMSUIUtils isIPhoneX])
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    
    self.loadMoreView = [[CMSLoadingMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 35)];
    self.tableView.tableFooterView = self.loadMoreView;
    
    self.refreshView = [[CMSRefreshView alloc] initWithFrame:CGRectMake(0, -60.f, ScreenW, 70.f)
                                                  scrollView:(UIScrollView *)self.tableView];
    
    self.refreshView.translatesAutoresizingMaskIntoConstraints = NO;
    self.refreshView.delegate = self;
    [self.tableView insertSubview: self.refreshView atIndex:0];
    
    //添加列表顶部横线
//    CALayer *bottomBorder = [CALayer layer];
//    bottomBorder.frame = CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.5);
//    bottomBorder.backgroundColor = [MOBFColor colorWithRGB:0xE1E1E1].CGColor;
//    [self.tableView.layer addSublayer:bottomBorder];

    [self.view addSubview:self.tableView];
}

- (void)_registerCells
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CMSTextCell class] forCellReuseIdentifier:NSStringFromClass([CMSTextCell class])];
    [self.tableView registerClass:[CMSLeftImageCell class] forCellReuseIdentifier:NSStringFromClass([CMSLeftImageCell class])];
    [self.tableView registerClass:[CMSRightImageCell class] forCellReuseIdentifier:NSStringFromClass([CMSRightImageCell class])];
    [self.tableView registerClass:[CMSBottomImageCell class] forCellReuseIdentifier:NSStringFromClass([CMSBottomImageCell class])];
    [self.tableView registerClass:[CMSThreeImageCell class] forCellReuseIdentifier:NSStringFromClass([CMSThreeImageCell class])];
}

- (void)_loadData
{
    self.isLoading = YES;
    [self.loadMoreView startAnimation];
    
    __weak typeof(self) theController = self;
    [CMSSDK getArticleList:self.articleType
                    pageNo:self.currentPageNo
                  pageSize:20
                    result:^(NSArray<CMSSDKArticle *> *articleList, NSError *error) {
         
                        theController.isLoading = NO;
                        [theController.loadMoreView stopAnimation];
                        
                        if (error == nil)
                        {
                            
                            if (articleList.count > 0)
                            {
                                int start = (int)theController.currentPageNo;
                                theController.currentPageNo += articleList.count;
                                [theController.dataArray addObjectsFromArray:articleList];
                                [theController _cellHightArrayAddData:articleList];
                                NSMutableArray *indexArr = [NSMutableArray array];
                                for (int i = start ; i < theController.currentPageNo; i ++)
                                {
                                    [indexArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                }
                                
                                [theController.tableView insertRowsAtIndexPaths:indexArr
                                                               withRowAnimation:UITableViewRowAnimationNone];
                            }
                            
                            if (articleList.count < 20)
                            {
                                [theController.loadMoreView noMoreData];
                                theController.isEnd = YES;
                            }
                            
                        }
 
     }];
}

- (void)_reload
{
    [self _cleanAndReloadDataWithRefresh:NO];
}

- (void)_cleanAndReloadDataWithRefresh:(BOOL)isRefresh
{
    self.isLoading = YES;
    self.currentPageNo = 0;
    //loadMoreVie重置
    [self.loadMoreView restartLoadData];
    self.isEnd = NO;
    __weak typeof(self) theController = self;
    [CMSSDK getArticleList:self.articleType
                    pageNo:self.currentPageNo
                  pageSize:20
                    result:^(NSArray<CMSSDKArticle *> *articleList, NSError *error) {
                        
                        int time = isRefresh ? 1 : 0;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            theController.isLoading = NO;
                            if (isRefresh) [theController.refreshView endRefreshing];
                            
                            if (error == nil)
                            {
                                theController.netErrorView.hidden = YES;
                                if (articleList.count > 0)
                                {
                                    theController.noneDataView.hidden = YES;
                                    theController.currentPageNo += articleList.count;
                                    [theController.dataArray removeAllObjects];
                                    //清理cell高度/cell中的title高度 数组
                                    [theController.cellHightArray removeAllObjects];
                                    [theController.cellTitleHightArray removeAllObjects];
                                    
                                    [theController.dataArray addObjectsFromArray:articleList];
                                    [theController _cellHightArrayAddData:articleList];
                                    [theController.tableView reloadData];
                                }
                                else
                                {
                                    //如果获取列表为0且本身也没有数据
                                    if (theController.dataArray.count == 0)
                                    {
                                        //显示没有数据
                                        theController.noneDataView.hidden = NO;
                                    }
                                }
                            }
                            else
                            {
                                //有错误，显示网络重新加载页面
                                theController.netErrorView.hidden = NO;
                            }

                        });
                        
                    }];
}


#pragma mark - Lazy Load
- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)cellHightArray
{
    if (_cellHightArray == nil)
    {
        _cellHightArray = [NSMutableArray array];
    }
    return _cellHightArray;
}

- (NSMutableArray *)cellTitleHightArray
{
    if (_cellTitleHightArray == nil)
    {
        _cellTitleHightArray = [NSMutableArray array];
    }
    return _cellTitleHightArray;
}

- (UIView *)noneDataView
{
    if (_noneDataView == nil)
    {
        UIView *noneDataView = [[UIView alloc] initWithFrame:self.view.frame];
        noneDataView.backgroundColor = [UIColor whiteColor];
        _noneDataView = noneDataView;
        [self.view addSubview:_noneDataView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        NSString *imgPath = [NSString stringWithFormat:@"%@/Resource/wsj.png",[CMSUIUtils UIBundleResourcePath]];
        imageView.image = [UIImage imageWithContentsOfFile:imgPath];
        [noneDataView addSubview:imageView];
        
        UILabel *lalbel = [[UILabel alloc] init];
        lalbel.text = @"没有数据";
        lalbel.textAlignment = NSTextAlignmentCenter;
        lalbel.textColor = [MOBFColor colorWithRGB:0x999999];
        [noneDataView addSubview:lalbel];

        UIButton *reloadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [reloadBtn addTarget:self action:@selector(_reload) forControlEvents:UIControlEventTouchUpInside];
        [reloadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        reloadBtn.layer.cornerRadius = 5;
        reloadBtn.layer.borderWidth = 1;
        reloadBtn.layer.borderColor = [MOBFColor colorWithRGB:0xE66159].CGColor;
        [reloadBtn setTitleColor:[MOBFColor colorWithRGB:0xE66159] forState:UIControlStateNormal];
        [noneDataView addSubview:reloadBtn];

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(noneDataView.mas_centerX);
            make.centerY.equalTo(noneDataView.mas_centerY).with.offset(-200);
            make.height.mas_equalTo(100);
            make.width.mas_equalTo(100);
            
        }];
        
        [lalbel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(noneDataView.mas_centerX);
            make.top.equalTo(imageView.mas_bottom).with.offset(20);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(40);
        }];

        [reloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(noneDataView.mas_centerX);
            make.top.equalTo(lalbel.mas_bottom).with.offset(60);
            make.width.mas_equalTo(120);
            make.height.mas_equalTo(30);
            
        }];
        
        noneDataView.hidden = YES;
    }
    
    return _noneDataView;
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

#pragma mark - UIViewController Method
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

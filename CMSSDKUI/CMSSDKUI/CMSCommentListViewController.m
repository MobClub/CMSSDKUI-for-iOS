//
//  CMSCommentListViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/13.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSCommentListViewController.h"
#import "CMSUIUtils.h"
#import "CMSCommentCell.h"
#import "CMSSDKComment+Cell.h"
#import "View+MASAdditions.h"

#import "CMSLoadingMoreView.h"
#import "CMSRefreshView.h"

#import <MOBFoundation/MOBFColor.h>

@interface CMSCommentListViewController () <UITextFieldDelegate,
                                            UITableViewDelegate,
                                            UITableViewDataSource,
                                            CMSRefreshViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *commentView;
@property (nonatomic) NSInteger currentPageNo;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isEnd;

@property (nonatomic, weak) UIView *line;
@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) CMSLoadingMoreView *loadMoreView;
@property (nonatomic, strong) CMSRefreshView *refreshView;

@end

@implementation CMSCommentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.currentPageNo = 0;
    self.isLoading = NO;
    [self _setTableViewUI];
    //首次加载传入NO,不需要动画效果
    [self _cleanAndReloadDataWithRefresh:NO];
    [self _setNavigaitonUI];
    [self _setLineView];
    
    [self _setCommentViewUI];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.line removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count <= 0)
    {
        return 1;
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.dataArray.count <= 0)
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"NonDataCELL"];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenW - 150)/2, 25, 150, 40)];
        textLabel.text = @"无任何评论";
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [MOBFColor colorWithRGB:0x999999];
        [cell.contentView addSubview:textLabel];
        return cell;
    }

    CMSSDKComment *comment = (CMSSDKComment *)self.dataArray[indexPath.row];
    NSString *cellID = @"CMSCommentCell";
    CMSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    [cell setComment:comment];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count <= 0)
    {
        return 90;
    }
    
    CMSSDKComment *comment = (CMSSDKComment *)self.dataArray[indexPath.row];
    return [comment theCellHeight];
}

#pragma marl - UIScrollViewDelegate

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
        if (- scrollView.contentOffset.y / self.tableView.frame.size.height > 0.2)
        {
            //下拉刷新方法
            [self.refreshView scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
        }
    }

}

#pragma mark - RWTRefreshViewDelegate
- (void)refreshViewDidRefresh:(CMSRefreshView *)refreshView
{
    [self _cleanAndReloadDataWithRefresh:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.article.comment)
    {
        __weak typeof(self) theController = self;
        //弹出评论编辑框
        [CMSUIUtils presentToCommentEditFromController:self result:^(BOOL isSend, NSString *comment) {
            
            if (isSend)
            {
                [CMSSDK addComment:comment
                         toArticle:theController.article
                            result:^(CMSSDKComment *newComment, MOBFUser *user,NSError *error) {
                  
                                if (error == nil)
                                {
                                    [theController.dataArray insertObject:newComment atIndex:0];
                                    [theController.tableView reloadData];
                                    [CMSUIUtils showCommentSuccessAlertInView:theController.view];
                                }
                                else
                                {
                                    //评论失败
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

#pragma mark - Lazy Load

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)loadingView
{
    if (_loadingView == nil)
    {
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 30)];
        loadingView.backgroundColor = [UIColor clearColor];
        
        UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        actView.frame = CGRectMake(0, 0, 30, 30);
        actView.center = loadingView.center;
        [actView startAnimating];
        
        [loadingView addSubview:actView];
        
        _loadingView = loadingView;
    }
    
    return _loadingView;
}

#pragma mark - Private

- (void)_setTableViewUI
{
    CGFloat tabbarH = 55;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH - tabbarH) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CMSCommentCell class] forCellReuseIdentifier:@"CMSCommentCell"];
    
    self.loadMoreView = [[CMSLoadingMoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, 35)];
    self.tableView.tableFooterView = self.loadMoreView;
    
    self.refreshView = [[CMSRefreshView alloc] initWithFrame:CGRectMake(0, -60, ScreenW, 70)
                                                  scrollView:(UIScrollView *)self.tableView];
    
    self.refreshView.translatesAutoresizingMaskIntoConstraints = NO;
    self.refreshView.delegate = self;
    [self.tableView insertSubview: self.refreshView atIndex:0];
    
    [self.view addSubview:self.tableView];
}

- (void)_setCommentViewUI
{
    self.commentView = [[UIView alloc] init];
    self.commentView.backgroundColor = [MOBFColor colorWithRGB:0xFFFFFF];
    self.commentView.layer.borderWidth = 0.5;
    self.commentView.layer.borderColor = [MOBFColor colorWithRGB:0xC8C8C8].CGColor;
    [self.view addSubview:self.commentView];
    [self.view bringSubviewToFront:self.commentView];
    
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
    [commentBtn addTarget:self action:@selector(textFieldShouldBeginEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:8];
    if (self.article.commentTimes == 0)
    {
        label.hidden = YES;
    }
    label.text = [self _getCommmentTimes:self.article.commentTimes];
    
    label.layer.cornerRadius = 6;
    label.layer.backgroundColor = [MOBFColor colorWithRGB:0xFF2B2B].CGColor;
    CGFloat labelWidth = [self _getWidthWithTitle:label.text font:[UIFont systemFontOfSize:8]];
    
    NSString *writeImgPath = [NSString stringWithFormat:@"%@/Resource/xiepl.png",sourceBundle.resourcePath];
    UIImageView *writeIcon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:writeImgPath]];
    
    [self.commentView addSubview:textField];
    [self.commentView addSubview:commentBtn];
    [self.commentView addSubview:label];
    [self.commentView addSubview:writeIcon];
    
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(theController.commentView.mas_left).with.offset(10);
        make.right.equalTo(commentBtn.mas_left).with.offset(-30);
        make.centerY.equalTo(theController.commentView.mas_centerY);
        make.height.mas_equalTo(@35);
        
    }];
    
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(theController.commentView.mas_centerY);
        make.right.equalTo(theController.commentView.mas_right).with.offset(-15);
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
 *  加载更多
 */
- (void)_loadData
{
    self.isLoading = YES;
    [self.loadMoreView startAnimation];
    
    __weak typeof(self) theController = self;
    [CMSSDK getCommentsList:self.article
                     pageNo:self.currentPageNo
                   pageSize:20
                     result:^(NSArray<CMSSDKComment *> *commentsList, NSError *error) {
                         
                         theController.isLoading = NO;
                         [theController.loadMoreView stopAnimation];
                         
                         if (error == nil)
                         {
                             if (commentsList.count > 0)
                             {
                                 int start = (int)theController.currentPageNo;
                                 theController.currentPageNo += commentsList.count;
                                 [theController.dataArray addObjectsFromArray:commentsList];
                                 
                                 NSMutableArray *indexArr = [NSMutableArray array];
                                 for (int i = start ; i < commentsList.count; i ++)
                                 {
                                     [indexArr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                 }
                                 [theController.tableView reloadData];
                             }
                             
                             if (commentsList.count < 20)
                             {
                                 [theController.loadMoreView noMoreData];
                                 theController.isEnd = YES;
                             }
                             
                         }

                     }];
}

/**
 *  重新加载
 *
 *  @param isRefresh 是否需要refresh动画效果
 */
- (void)_cleanAndReloadDataWithRefresh:(BOOL)isRefresh
{
    self.currentPageNo = 0;
    self.isLoading = YES;
    self.isEnd = NO;
    [self.loadMoreView restartLoadData];
    
    __weak typeof(self) theController = self;
    [CMSSDK getCommentsList:self.article
                     pageNo:self.currentPageNo
                   pageSize:20
                     result:^(NSArray<CMSSDKComment *> *commentsList, NSError *error) {
                         
                         theController.isLoading = NO;
                         
                         int time = isRefresh ? 1 : 0;
                         
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             
                             if (isRefresh) [theController.refreshView endRefreshing];
                             
                             if (error == nil)
                             {
                                 if (commentsList.count > 0)
                                 {
                                     theController.currentPageNo += commentsList.count;
                                     [theController.dataArray removeAllObjects];
                                     [theController.dataArray addObjectsFromArray:commentsList];
                                     [theController.tableView reloadData];
                                 }
                             }

                         });
                         
                         
                     }];
}

- (void)_setLineView
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height, ScreenW, 1)];;
    lineView.backgroundColor = [MOBFColor colorWithRGB:0xE9E9E9];
    self.line = lineView;
    [self.navigationController.navigationBar addSubview:lineView];
}

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

- (NSString *)_getCommmentTimes:(NSInteger)commentTimes
{
    NSString *labelText = [NSString stringWithFormat:@"%ld",(long)commentTimes];
    
    if (commentTimes > 1000)
    {
        labelText = [NSString stringWithFormat:@"%.1f万",commentTimes/10000.0];
    }
    
    
    return labelText;
}

- (void)_popController
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end


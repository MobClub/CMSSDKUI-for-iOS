//
//  CMSImageContentViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 2017/4/20.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSImageContentViewController.h"
#import "DRPLoadingSpinner.h"
#import "View+MASAdditions.h"
#import "CMSUIUtils.h"

#import <MOBFoundation/MOBFImageGetter.h>

@interface CMSImageContentViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIScrollView *zoomView;

@property (nonatomic, strong) DRPLoadingSpinner *spinner;

@property (nonatomic) BOOL isHiddenAll;

@end

@implementation CMSImageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setSpinnerUI];
    [self _setImageUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CMSImageTypeCurrenIndex" object:@(self.current)];
    
    if (!self.spinner.isHidden)
    {
        [self.spinner startAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.zoomView)
    {
        [self.zoomView setZoomScale:1.0];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIImageView *imgView = self.imageView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;

    imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - Private Mehtod
- (void)_setSpinnerUI
{
    DRPLoadingSpinner *spinner = [[DRPLoadingSpinner alloc] initWithFrame:CGRectMake((ScreenW - 50 ) / 2,
                                                                                     (ScreenH - 50 ) / 2 - 100,
                                                                                     50,
                                                                                     50)];
    
    spinner.rotationCycleDuration = 1.5;
    spinner.drawCycleDuration = 0.75;
    spinner.drawTimingFunction = [DRPLoadingSpinnerTimingFunction sharpEaseInOut];
    spinner.colorSequence = @[[UIColor whiteColor]];
    self.spinner = spinner;
    [self.view insertSubview:spinner atIndex:0];
}

- (void)_setImageUI
{
    
    UIScrollView *zoomView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    zoomView.delegate = self;
    zoomView.maximumZoomScale = 2.0;
    zoomView.showsHorizontalScrollIndicator = NO;
    zoomView.showsVerticalScrollIndicator = NO;
    
    self.zoomView = zoomView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                           (ScreenH - ScreenW/1.5) / 2,
                                                                           ScreenW,
                                                                           ScreenW / 1.5)];
    self.imageView = imageView;
    
    [self.view addSubview:zoomView];
    [zoomView addSubview:imageView];
    
    [self.spinner startAnimating];
    __weak typeof(self) theController = self;
    [[MOBFImageGetter sharedInstance] getImageWithURL:self.imageURL result:^(UIImage *image, NSError *error) {
    
        if (image)
        {
            CGFloat size = image.size.width / image.size.height;
            CGFloat hight = ScreenW / size;
            imageView.frame = CGRectMake(0,
                                         (ScreenH - hight) / 2,
                                         ScreenW,
                                         hight);
            
            imageView.image = image;
        }
        else
        {
            NSString *defaultPath = [NSString stringWithFormat:@"%@/Resource/mrtp.png",[CMSUIUtils UIBundleResourcePath]];
            imageView.image = [UIImage imageWithContentsOfFile:defaultPath];

        }
        [theController.spinner stopAnimating];
        theController.spinner.hidden = YES;
    }];
    
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

@end

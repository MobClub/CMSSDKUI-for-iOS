//
//  CMSEditCommentViewController.m
//  CMSSDKUI
//
//  Created by 陈剑东 on 17/3/13.
//  Copyright © 2017年 Mob. All rights reserved.
//

#import "CMSEditCommentViewController.h"
#import <MOBFoundation/MOBFColor.h>
#import "View+MASAdditions.h"


@interface CMSEditCommentViewController () <UITextViewDelegate,
                                            UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *midView;

@property (nonatomic, weak) UITextView *textView;

@property (nonatomic, weak) UILabel *midLabel;

@property (nonatomic, weak) UIButton *sendBtn;

@property (nonatomic, weak) UIButton *cancelBtn;

@end

@implementation CMSEditCommentViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    //监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [self _setUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //将textView设为第一响应,触发键盘
    [self.textView becomeFirstResponder];
}

#pragma mark - Private Method
/**
 *  设定界面
 */
- (void)_setUI
{
    UITapGestureRecognizer *cancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_cancel)];
    cancelTap.delegate = self;
    [self.view addGestureRecognizer:cancelTap];
    
    UIView *midView = [[UIView alloc] init];
    midView.backgroundColor = [MOBFColor colorWithRGB:0xF4F5F6];

    [self.view addSubview:midView];
    
    UITextView *textView = [[UITextView alloc] init];
    textView.backgroundColor = [UIColor whiteColor];
    textView.delegate = self;
    textView.layer.borderColor = [MOBFColor colorWithRGB:0xe3e3e3].CGColor;
    textView.layer.borderWidth = 1;
    [midView addSubview:textView];
    
    UILabel *midLabel = [[UILabel alloc] init];
    midLabel.text = @"写评论";
    midLabel.textColor = [MOBFColor colorWithRGB:0x222222];
    [midView addSubview:midLabel];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[MOBFColor colorWithRGB:0x222222] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(_cancel) forControlEvents:UIControlEventTouchUpInside];
    [midView addSubview:cancelBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[MOBFColor colorWithRGB:0x999999] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(_send) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.enabled = NO;
    [midView addSubview:sendBtn];
    
    self.textView = textView;
    self.midView = midView;
    self.cancelBtn = cancelBtn;
    self.sendBtn = sendBtn;
    self.midLabel = midLabel;

    self.midView.frame = CGRectMake(0, ScreenH, ScreenW, 200);

    __weak typeof(self) theController = self;
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.midView.mas_top).with.offset(10);
        make.left.equalTo(theController.midView.mas_left).with.offset(20);
        
    }];
    
    
    [self.midLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(theController.midView.mas_centerX);
        make.centerY.equalTo(theController.cancelBtn.mas_centerY);
        
        make.width.mas_equalTo(@60);
        make.height.mas_equalTo(@30);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.midView.mas_top).with.offset(10);
        make.right.equalTo(theController.midView.mas_right).with.offset(-20);
        
        make.width.mas_equalTo(@40);
        make.height.mas_equalTo(@30);
    }];
    
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(theController.cancelBtn.mas_bottom).with.offset(10);
        make.left.equalTo(theController.midView.mas_left).with.offset(20);
        make.right.equalTo(theController.midView.mas_right).with.offset(-20);
        make.bottom.equalTo(theController.midView.mas_bottom).with.offset(-20);
    }];

    
    self.midView.hidden = YES;
    
}

/**
 *  取消评论
 */
- (void)_cancel
{
    [self.textView resignFirstResponder];
    
    __weak typeof(self) theController = self;
    [self dismissViewControllerAnimated:NO completion:^{
       
        if (theController.editResult)
        {
            theController.editResult(NO, nil);
        }
        
    }];
    
}

/**
 *  发送评论
 */
- (void)_send
{
    [self.textView resignFirstResponder];
    
    __weak typeof(self) theController = self;
    [self dismissViewControllerAnimated:NO completion:^{
        
        if (theController.editResult)
        {
            theController.editResult(YES, theController.textView.text);
        }
        
    }];

}

- (void)_keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    __weak typeof(self) theController = self;
    [UIView animateWithDuration:0.1 animations:^{
        theController.midView.hidden = NO;
        theController.midView.frame = CGRectMake(0, theController.view.frame.size.height - height - 200, ScreenW, 200);
    }];
}

#pragma mark - UITextViewDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.midView]) {
        return NO;
    }
    
    return YES;
}
#pragma mark - UIGestureRecognizerDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [self.sendBtn setTitleColor:[MOBFColor colorWithRGB:0x999999] forState:UIControlStateNormal];
        self.sendBtn.enabled = NO;
    }
    else
    {
        [self.sendBtn setTitleColor:[MOBFColor colorWithRGB:0xE66159] forState:UIControlStateNormal];
        self.sendBtn.enabled = YES;
    }
}

@end

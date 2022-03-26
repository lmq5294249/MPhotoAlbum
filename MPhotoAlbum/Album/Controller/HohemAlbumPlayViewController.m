//
//  HohemAlbumPlayViewController.m
//  Hohem Pro
//
//  Created by jolly on 2020/4/15.
//  Copyright © 2020 jolly. All rights reserved.
//

#import "HohemAlbumPlayViewController.h"
#import "AppDelegate.h"
#import <AVKit/AVKit.h>

@interface HohemAlbumPlayViewController ()

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) HohemBaseButton *backBtn;
@property (nonatomic, strong) HohemBaseLabel *titleLab;
@property (nonatomic, strong) HohemBaseButton *shareBtn;
@property (nonatomic, strong) AVPlayerViewController *playerVc;

@end

@implementation HohemAlbumPlayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = 1;
    
    [self initAttribute];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    NSError *error;
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategorySoloAmbient error:&error];
//    [session setActive:YES error:&error];
    [self.playerVc.player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.allowRotate = 0;
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {

        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

- (void)dealloc {
    
    NSLog(@"%s",__FUNCTION__);
}

- (void)initAttribute {
    
    self.playerVc = [[AVPlayerViewController alloc] init];
    self.playerVc.player = [[AVPlayer alloc] init];
//    [self.playerVc.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:self.videoUrl]];
    [self.playerVc.player replaceCurrentItemWithPlayerItem:self.playerItem];
}

- (void)setUpUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.playerVc.view];
    
//    [self.view addSubview:self.navView];
    
    [self.backBtn addTarget:self action:@selector(didBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    [self.shareBtn addTarget:self action:@selector(didShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shareBtn];
    self.shareBtn.hidden = YES;
    
//    [self.navView addSubview:self.titleLab];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.view addGestureRecognizer:tap];
    [self.navView addGestureRecognizer:tap];
}

- (void)didBackBtn:(HohemBaseButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didShareBtn:(HohemBaseButton *)btn {
    
    [Tation_kSharedToolsManager shareVideoWithAsset:self.asset completeHandler:nil];
}

- (void)didTap:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"111");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat w = 56;
    CGFloat h = w;
    self.backBtn.frame = CGRectMake(0, CGRectGetMinY(Tation_safeArea), w, h);
    
    self.shareBtn.frame = CGRectMake(self.view.bounds.size.width - w, CGRectGetMinY(Tation_safeArea), w, h);
    
    h = CGRectGetMaxY(Tation_safeArea) - CGRectGetMaxY(self.backBtn.frame);
    self.playerVc.view.frame = CGRectMake(0, CGRectGetMaxY(self.backBtn.frame), w, h);
    self.playerVc.view.frame = self.view.bounds;
}

#pragma mark - 懒加载
- (UIView *)navView {
    
    if (_navView == nil) {
        
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    }
    
    return _navView;
}

- (HohemBaseButton *)backBtn {
    
    if (_backBtn == nil) {
        
        _backBtn = [[HohemBaseButton alloc] init];
        [_backBtn setImage:Tation_Resource_Image(@"Hohem.Tutorial.Back") forState:UIControlStateNormal];
    }
    
    return _backBtn;
}

- (HohemBaseLabel *)titleLab {
    
    if (_titleLab == nil) {
        
        _titleLab = [[HohemBaseLabel alloc] init];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont systemFontOfSize:16];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = Tation_Resource_Str(@"Hohem.Local.LocalTitle");
    }
    
    return _titleLab;
}

- (HohemBaseButton *)shareBtn {
    
    if (_shareBtn == nil) {
        
        _shareBtn = [[HohemBaseButton alloc] init];
        [_shareBtn setTitle:Tation_Resource_Str(@"分享") forState:UIControlStateNormal];
        [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    return _shareBtn;
}

@end

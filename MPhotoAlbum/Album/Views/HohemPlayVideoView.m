//
//  HohemPlayVideoView.m
//  Hohem Pro
//
//  Created by jolly on 2019/11/28.
//  Copyright © 2019 jolly. All rights reserved.
//

#import "HohemPlayVideoView.h"
#import "TationVideoPlayerView.h"

@interface HohemPlayVideoView()

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) HohemBaseButton *backBtn;
@property (nonatomic, strong) HohemBaseLabel *titleLabel;
@property (nonatomic, strong) UIView *navLineView;
@property (nonatomic, strong) TationVideoPlayerView *playerView;

@end

@implementation HohemPlayVideoView

- (instancetype)init {
    
    self = [super init];
    
    [self initAttribute];
    [self setUpUI];
    
    return self;
}

- (void)initAttribute {
    
    
}

- (void)setUpUI {
    
    self.backgroundColor = [UIColor blackColor];
    
    self.playerView = [[TationVideoPlayerView alloc]init];
    [self addSubview:self.playerView];
    
    [self addSubview:self.navView];
       
    [self.backBtn addTarget:self action:@selector(didClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.backBtn];
       
    [self.navView addSubview:self.titleLabel];
    
    [self.navView addSubview:self.navLineView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat margin = 0.5;
    CGFloat w = self.bounds.size.width;
    CGFloat h = 44 + CGRectGetMinY(Tation_safeArea);
       
    self.navView.frame = CGRectMake(0, 0, w, h);
    w = 44;
    h = 43.5;
    self.backBtn.frame = CGRectMake(0, self.navView.bounds.size.height - h - margin, w, h);
    w = 120;
    margin = (self.navView.bounds.size.width - w) / 2;
    self.titleLabel.frame = CGRectMake(margin, self.navView.bounds.size.height - h - 0.5, w, h);
      
    w = self.navView.frame.size.width;
    h = 0.5;
    self.navLineView.frame = CGRectMake(0,self.navView.bounds.size.height - h, w, h);
    
    h = self.bounds.size.height;
    self.playerView.frame = CGRectMake(0, 0, w, h);
}

- (void)didClickBackBtn:(HohemBaseButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(HohemPlayVideoViewDelegate:function:value:)]) {
        
        [self.delegate HohemPlayVideoViewDelegate:self function:@"back" value:@""];
    }
}

- (void)updateVideoUrl:(NSURL *)videoUrl {
    
    [self.playerView updateVideoUrl:videoUrl];
    [self.playerView startPlay];
}

#pragma mark - 懒加载
- (UIView *)navView {
    
    if (_navView == nil) {
        
        _navView = [[UIView alloc]init];
        _navView.backgroundColor = [UIColor whiteColor];
    }
    
    return _navView;
}

- (HohemBaseButton *)backBtn {
    
    if (_backBtn == nil) {
        
        _backBtn = [[HohemBaseButton alloc]init];
        [_backBtn setImage:Tation_Resource_Image(@"Hohem.Local.Back") forState:UIControlStateNormal];
    }
    
    return _backBtn;
}

- (HohemBaseLabel *)titleLabel {
    
    if (_titleLabel == nil) {
        
        _titleLabel = [[HohemBaseLabel alloc]init];
        _titleLabel.tintColor = [UIColor blackColor];
        _titleLabel.font = Hohem_Font_Noraml;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
//        _titleLabel.text = Tation_Resource_Str(@"Hohem.Local.LocalTitle");
        _titleLabel.textColor = [UIColor blackColor];
    }
    
    return _titleLabel;
}

- (UIView *)navLineView {
    
    if (_navLineView == nil) {
        
        _navLineView = [[UIView alloc]init];
        _navLineView.backgroundColor = [UIColor grayColor];
    }
    
    return _navLineView;
}

@end

//
//  HohemImageCollectionViewCell.m
//  Hohem Pro
//
//  Created by jolly on 2019/11/28.
//  Copyright © 2019 jolly. All rights reserved.
//

#import "HohemImageCollectionViewCell.h"

@interface HohemImageCollectionViewCell()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
//@property (nonatomic, strong) HohemBaseButton *playBtn;
@property (nonatomic, strong) MediaPlayerView *playerView;
@end

@implementation HohemImageCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    [self initAttribute];
    [self setUpUI];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    [self initAttribute];
    [self setUpUI];
    
    return self;
}

- (void)initAttribute {
    
    
}

- (void)setUpUI {
    
    self.contentView.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.zoomScale = 1.0;
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = NO;
    [self.contentView addGestureRecognizer: self.scrollView.panGestureRecognizer];
    [self.contentView addGestureRecognizer: self.scrollView.pinchGestureRecognizer];
    [self.contentView addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc]init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.clipsToBounds = YES;
    self.imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.imageView];
    
//    self.playBtn = [[HohemBaseButton alloc]init];
//    [self.playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
//    [self.playBtn setImage:Tation_Resource_Image(@"Hohem_Album_play") forState:UIControlStateNormal];
//    [self.imageView addSubview:self.playBtn];
    
    //添加播放器
    self.playerView = [[MediaPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playerView.hidden = YES;
}

- (void)showPlayBtn:(BOOL)isShow {
    
    //self.playBtn.hidden = !isShow;
    if (isShow) {
        self.scrollView.userInteractionEnabled = NO;
        [self.contentView insertSubview:self.playerView atIndex:0];
        self.playerView.hidden = NO;
        self.playerView.assetModel = _assetModel;
        self.playerView.delegate = self.controller;
    }
    else
    {
        self.playerView = nil;
        self.scrollView.userInteractionEnabled = NO;
        self.scrollView.delegate = self;
    }
}

- (void)setHiddenSlideView:(BOOL)hiddenSlideView
{
    [self.playerView hiddenSlideView:hiddenSlideView];
}

- (void)playVideo {
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(HohemImageCollectionViewCellDelegate:functionStr:value:)]) {
//
//        [self.delegate HohemImageCollectionViewCellDelegate:self functionStr:@"playVideo" value:@""];
//    }
    [self.playerView videoPlayerPlay];
}

- (void)videoStopPlay
{
    [self.playerView videoPlayerPause];
}

- (void)updateImageWithImage:(UIImage *)image {
    
    self.imageView.image = image;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat w = 120;
    CGFloat h = w;
    self.scrollView.frame = self.contentView.bounds;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.imageView.frame = self.contentView.bounds;
    
    //self.playBtn.frame = CGRectMake((self.imageView.bounds.size.width - w) / 2, (self.imageView.bounds.size.height - h) / 2, w, h);
}

#pragma mark -UIScrollViewDelegate
- (void)setScrollViewZoomScale
{
    self.scrollView.zoomScale = 1.0;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"scrollview.zoom = %f",scrollView.zoomScale);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


@end

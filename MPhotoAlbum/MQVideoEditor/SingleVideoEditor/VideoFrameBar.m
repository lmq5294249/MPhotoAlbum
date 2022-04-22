//
//  VideoFrameBar.m
//  ancda
//
//  Created by WDeng on 16/12/22.
//  Copyright © 2016年 WDeng. All rights reserved.
//

#import "VideoFrameBar.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+Frame.h"


@interface VideoFrameBar ()
{
    NSTimeInterval _totalTime;
    BOOL _isDrag;
    BOOL shotPerSecond; //每秒截图
}


@property (nonatomic,strong) NSURL *url;
@property(nonatomic, weak) UIImageView *handleView;
@property(nonatomic, weak) UIView *handleBgView;

@end

@implementation VideoFrameBar

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url startTime:(NSTimeInterval)startValue duration:(NSTimeInterval)duraValue{
    if (self = [super initWithFrame:frame]) {
        self.url = url;
        self.startPlayTime = startValue;
        self.playDrutation = duraValue;
        [self setUpBackgroundView];
        //[self configureView];
        
        [self addLongPressGesture];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url screenCapturePerSecond:(BOOL)flag{
    if (self = [super initWithFrame:frame]) {
        self.url = url;
        shotPerSecond = flag;
        [self setUpthumbnailImageView];
        [self configureView];
    }
    return self;
}

- (void)setUpthumbnailImageView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgView];
    AVAsset *asset = [AVAsset assetWithURL:self.url];
    _totalTime = CMTimeGetSeconds(asset.duration);
    NSInteger totalCount;
    if (shotPerSecond) {
        totalCount = ceilf(_totalTime);
    }
    else
    {
        totalCount = ceilf(_totalTime)/2.0;
    }
        NSTimeInterval time = _totalTime / totalCount;
        CGFloat width = self.width / totalCount;
        for (int i = 0; i < totalCount; i++) {
            [self thumbnailImageAtTime:time * (i + 1) image:^(UIImage *image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, self.height)];
                 imageView.image = image;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.masksToBounds = YES;
                [bgView addSubview:imageView];
                
            }];
        }
}

- (void)setBackgroundView {
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgView];
    AVAsset *asset = [AVAsset assetWithURL:self.url];
    _totalTime = CMTimeGetSeconds(asset.duration);
    NSInteger totalCount = ceilf(_totalTime) / 2;
        NSTimeInterval time = _totalTime / totalCount;
        CGFloat width = self.width / totalCount;
        for (int i = 0; i < totalCount; i++) {
            [self thumbnailImageAtTime:time * (i + 1) image:^(UIImage *image) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, self.height)];
                 imageView.image = image;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.masksToBounds = YES;
                [bgView addSubview:imageView];
                
            }];
        }
}

- (void)setUpBackgroundView
{
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgView];
    AVAsset *asset = [AVAsset assetWithURL:self.url];
    _totalTime = CMTimeGetSeconds(asset.duration);
    NSInteger totalCount = ceilf(self.playDrutation) / 2;
    NSTimeInterval time = self.startPlayTime;
    CGFloat width = self.width / totalCount;
    for (int i = 0; i < totalCount; i++) {
        [self thumbnailImageAtTime:(time + i*2) image:^(UIImage *image) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * width, 0, width, self.height)];
             imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            [bgView addSubview:imageView];
            
        }];
    }
    
}

- (void) thumbnailImageAtTime:(NSTimeInterval)time image:(void(^)(UIImage *image))imageBlock {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.url options:nil] ;
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    //补充修改
    assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    //CMTime pointTime = CMTimeMakeWithSeconds(time, 30);
    CMTime pointTime = CMTimeMake(time * 1000 , 1000);
    
    NSError *thumbnailImageGenerationError = nil;
    CGImageRef  thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:pointTime actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (thumbnailImageGenerationError) {
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    }
    
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:thumbnailImageRef];
    CGImageRelease(thumbnailImageRef);
    NSData *data = UIImageJPEGRepresentation(thumbnailImage, 0.1);
    UIImage *image =  [UIImage imageWithData:data scale:20];
     
        
        dispatch_sync(dispatch_get_main_queue(), ^{
        if (imageBlock) {
            imageBlock(image);
        }
            
        });
    });
 
}

//MARK:手动控制移动单独的view里面的帧
- (void)configureView {
    
    
    UIView *handleBgView = [[UIView alloc] initWithFrame:CGRectMake(4, 0, self.width - 8, self.height)];
    [self addSubview:handleBgView];
    self.handleBgView = handleBgView;
    
    UIImageView *handleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, self.height)];
    handleView.centerX = 0;
    handleView.image = [UIImage imageNamed:@"video_edite_handle"];
    handleView.contentMode = UIViewContentModeScaleAspectFit;
    [handleBgView addSubview:handleView];
    handleView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
    [handleView addGestureRecognizer:pan];
    
    self.handleView = handleView;
}

- (void)dragHandle:(UIPanGestureRecognizer *)pan {
    
    UIView *handleView = pan.view;
    UIView *handleBgView = handleView.superview;
    
    CGPoint point = [pan translationInView:self];
    NSLog(@"NSStringFromCGPoint------------%@", NSStringFromCGPoint(point));
    handleView.centerX += point.x;
    if (handleView.centerX <= 0) {
        handleView.centerX = 0;
    }
    if (handleView.centerX >= handleBgView.width) {
        handleView.centerX = handleBgView.width;
    }
    if ([self.delegate respondsToSelector:@selector(dragHandleViewWithPercent:)]) {
        [self.delegate dragHandleViewWithPercent:handleView.centerX*1.0/handleBgView.width];
    }
    
    [pan setTranslation:CGPointZero inView:self];
    
   _isDrag = pan.state != UIGestureRecognizerStateEnded;
}

- (void)setPercent:(CGFloat)percent {
    if (!_isDrag) {
        self.handleView.centerX =  percent * self.handleBgView.width;
    }
    _percent = percent;
}

- (void)setHiddenHandle:(BOOL)hiddenHandle {
    self.handleView.hidden = hiddenHandle;
    _hiddenHandle = hiddenHandle;
}

#pragma mark - 添加长按手势
- (void)addLongPressGesture
{
    UILongPressGestureRecognizer *gesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestures:)];
    gesture.minimumPressDuration=1.0f;
    gesture.numberOfTouchesRequired = 1;
    self.userInteractionEnabled=YES;
    [self addGestureRecognizer:gesture];
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)paramSender{

    if (paramSender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"long pressTap state :begin");
        //长按进入视频编辑界面
        self.longPressHandleBlock(_index);

    }
    else if (paramSender.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"long pressTap state :end");
        
    }
}

@end








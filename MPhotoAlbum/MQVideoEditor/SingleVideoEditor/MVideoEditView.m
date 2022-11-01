//
//  MVideoEditView.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/17.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MVideoEditView.h"
#import <AVFoundation/AVFoundation.h>
#import "TationDeviceManager.h"
#import "MVideoFrameDisplayer.h"
#import "MVideoToolControlView.h"
#import "MVideoPlayerView.h"

#define MinDuration 2500  //ms最小的视频长度为2.5s包含了前后转场在内

@interface MVideoEditView ()
{
    UIButton *confirmBtn;
    UIButton *cancelBtn;
    UIButton *playBtn;
    
    CGFloat iphoneYOffset;
}

@property (nonatomic, strong) VideoAssetModel *videoModel;

@property (nonatomic, strong) NSURL *videoUrl;

@property (nonatomic) CMTimeRange originalTimeRange; //保存原始

@property (nonatomic) CMTimeRange originalPlayTimeRange; //保存原始

@property (nonatomic, strong) UILabel *titleLabel;

//播放器
@property (nonatomic, strong) MVideoPlayerView *videoPlayerView;

@property (nonatomic, strong) MVideoToolControlView *videoToolControlView;

@property (nonatomic, strong) NSMutableArray *videoUrlArray;

@property (nonatomic, strong) NSMutableArray *videoSegmentLengthArray;

@property (nonatomic, assign) BOOL isPhotoMedia;

@property (nonatomic, strong) UIButton *replaceBtn;

@property (nonatomic, strong) MVideoFrameDisplayer *videoFrameDisplayer;

@property (nonatomic, strong) UILabel *cutVideoLabel;

@property (nonatomic, strong) UILabel *dragReminderLabel;




@end


@implementation MVideoEditView

- (instancetype)initWithFrame:(CGRect)frame withMediaAssetArray:(NSMutableArray*)array mediaIndex:(NSInteger)mediaIndex
{
    if (self = [super initWithFrame:frame]) {
        
        iphoneYOffset = Tation_BottomSafetyDistance;
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
        
        self.mediaAssetArray = array;
        self.index = mediaIndex;

    }
    
    return self;
}

- (void)updateInterfaceAndData
{
    [self setUpUI];
    
    [self setUpButton];
}

- (void)setUpUI
{
    __weak typeof(self) weakSelf = self;
    NSLog(@"==========单视频编辑模式=============");
    LocalAssetModel *model = self.mediaAssetArray[_index];
//    VideoAssetModel *videoModel;
//    PhotoAssetModel *photoModel;
    //获取数据初始化时间戳列表
//    if (model.propertyType == PHAssetMediaTypeVideo) {
//        videoModel = (VideoAssetModel *)self.mediaAssetArray[_index];
//        _videoUrl = videoModel.originalVideoUrl;
//    }
//    else{
//        photoModel = (PhotoAssetModel *)self.mediaAssetArray[_index];
//        _videoUrl = photoModel.imageVideoUrl;
//        _isPhotoMedia = YES;
//    }
    
    _videoUrl = model.propertyAssetURL.URL;

    _videoUrlArray = [NSMutableArray array];
    [_videoUrlArray addObject:_videoUrl];
    [self calculateVideoArraySegmentLength];
    //初始化预览播放器
    if (!_videoPlayerView) {
        self.videoPlayerView = [[MVideoPlayerView alloc] initWithFrame:CGRectMake(0, 150, 390, 219)];
        [self addSubview:self.videoPlayerView];
        self.videoPlayerView.curPlayVideoUrl = _videoUrl;
        self.videoPlayerView.keepLooping = YES;
    
        self.videoToolControlView = [[MVideoToolControlView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.videoPlayerView.frame) + 16, CGRectGetWidth(self.frame) - 32, 18)];
        [self addSubview:self.videoToolControlView];
        self.videoToolControlView.isDragEnable = NO;
        self.videoToolControlView.sliderChangeValueBlock = ^(NSTimeInterval pointInTime, BOOL finish) {
            [weakSelf.videoPlayerView setTheCurrentPlayerTime:pointInTime * 1000];
        };
        self.videoPlayerView.delegate = self.videoToolControlView;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:_videoUrl];
    double totalTime = CMTimeGetSeconds(asset.duration);
    BOOL flag = YES;
    if (totalTime > 12) {
        flag = NO;
    }
    //更新数据
    CMTimeRange curTimeRange;
    CMTime beginTime;
    CMTime durationTime;
    CGFloat startPlayTimeValue;
    CGFloat durationPlayTimeValue;
    
    curTimeRange = [self.clipTimeRanges[_index] CMTimeRangeValue];
    self.originalTimeRange = CMTimeRangeMake(curTimeRange.start, curTimeRange.duration);
    CMTimeRange playTimeRange = [self.clipTimeRanges[_index] CMTimeRangeValue];
    self.originalPlayTimeRange = CMTimeRangeMake(playTimeRange.start, playTimeRange.duration);
    beginTime = curTimeRange.start;
    durationTime = curTimeRange.duration;
    //刷新AVPlayer显示预览
    startPlayTimeValue = beginTime.value * 1000 / beginTime.timescale;
    durationPlayTimeValue = durationTime.value * 1000 / durationTime.timescale;
    //设置视频预览起始点
    self.videoPlayerView.playStartTimeValue = startPlayTimeValue;
    self.videoPlayerView.playEndTimeValue = startPlayTimeValue + durationPlayTimeValue;;
    
    playBtn.selected = NO;
    
    //设置拖动的视频最小时长限制
    CGFloat minDurationPercent = MinDuration / (totalTime * 1000);
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    self.videoFrameDisplayer = [[MVideoFrameDisplayer alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 68 - 50 - bottomDistValue, CGRectGetWidth(self.frame), 50) url:_videoUrl videoFragmentDur:CMTimeGetSeconds(durationTime)];
    [self addSubview:self.videoFrameDisplayer];
    [self.videoFrameDisplayer setStartPointTime:CMTimeGetSeconds(beginTime)]; //设置初始时间位置
    self.videoFrameDisplayer.videoRePlayBlock = ^(NSTimeInterval start, NSTimeInterval duration, BOOL finish) {
        weakSelf.videoPlayerView.playStartTimeValue = start * 1000;
        weakSelf.videoPlayerView.playEndTimeValue = (start + duration) * 1000;
        [weakSelf.videoPlayerView setTheCurrentPlayerTime: (start * 1000)];
        if (finish) {
            //播放
            //更新数据
            CMTime beginTime = CMTimeMake(start * 1000, 1000);
            CMTime durationTiem = CMTimeMake(duration * 1000, 1000);
            CMTimeRange curTimeRange = CMTimeRangeMake(beginTime, durationTiem);
            
            weakSelf.originalTimeRange = curTimeRange;
        }
    };
    
    self.dragReminderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 30 - 22 - bottomDistValue, CGRectGetWidth(self.frame), 22)];
    self.dragReminderLabel.text = @"拖动选择视频裁剪区域";
    self.dragReminderLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    self.dragReminderLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.dragReminderLabel];
    
    self.cutVideoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.videoFrameDisplayer.frame) - 15 - 22, CGRectGetWidth(self.frame), 22)];
    self.cutVideoLabel.text = [NSString stringWithFormat:@"裁剪%.2fs视频",CMTimeGetSeconds(durationTime)];
    self.cutVideoLabel.textColor = [UIColor whiteColor];
    self.cutVideoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.cutVideoLabel];
    
    self.replaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.replaceBtn.frame = CGRectMake((CGRectGetWidth(self.frame) - 60)/2, CGRectGetMaxY(self.videoToolControlView.frame) + 32, 60, 22);
    [self.replaceBtn setTitle:@"替换" forState:UIControlStateNormal];
    [self.replaceBtn addTarget:self action:@selector(didClickReplaceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.replaceBtn];
}

- (void)setUpButton
{
    CGRect saftArea = Tation_safeArea;
    CGFloat xIphoneMargin = saftArea.origin.y;
    
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(CGRectGetWidth(self.frame) - 64 - 16, xIphoneMargin + 1, 64, 38)];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setBackgroundColor:[UIColor orangeColor]];
    //[confirmBtn setImage:[UIImage imageNamed:@"MQVideoEdit.Selected"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(saveMediaChangesAndReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
    confirmBtn.layer.masksToBounds = YES;
    confirmBtn.layer.cornerRadius = 19;
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(32, xIphoneMargin, 40, 40)];
    [cancelBtn setImage:[UIImage imageNamed:@"Hohem.Tutorial.Back"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(discardChangesAndReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
//    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [playBtn setFrame:CGRectMake((CGRectGetWidth(self.frame) - 40)/2, CGRectGetMinY(self.frameBar.frame) - 60, 40, 40)];
//    [playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Play"] forState:UIControlStateNormal];
//    [playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Pause"] forState:UIControlStateSelected];
//    [playBtn addTarget:self action:@selector(replayVideo:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:playBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.frame) - 100)/2, xIphoneMargin, 100, 40);
    self.titleLabel.text = @"裁剪视频";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    [self addSubview:self.titleLabel];
}


//MARK:计算视频数组的片段时间时长
- (void)calculateVideoArraySegmentLength
{
    _videoSegmentLengthArray = [[NSMutableArray alloc] init];
    double nextTotalTime = 0.0;
    for (int i = 0; i < _videoUrlArray.count; i++) {
        
        NSURL *videoUrl = _videoUrlArray[i];
        AVAsset *asset = [AVAsset assetWithURL:videoUrl];
        double videoTimeTmp = CMTimeGetSeconds(asset.duration) * 1000; //单位改为ms
        nextTotalTime = nextTotalTime + videoTimeTmp;
        [_videoSegmentLengthArray addObject:[NSNumber numberWithFloat:nextTotalTime]];
    }
}

- (void)discardChangesAndReturn:(UIButton *)btn
{
    //[_playerView setPlayerPause];
    //不保存修改
    [self removeFromSuperview];
}

- (void)saveMediaChangesAndReturn:(UIButton *)btn
{
    //[_playerView setPlayerPause];
    
    //修改当前的视频播放时间范围
    self.clipTimeRanges[_index] = [NSValue valueWithCMTimeRange:self.originalTimeRange];
    self.updateBlock();
    
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)didClickReplaceButton:(UIButton *)btn
{
    
}

//- (void)replayVideo:(UIButton *)btn
//{
//    btn.selected = !btn.selected;
//    if (btn.selected) {
//        [_playerView rePlayAllTheTime];
//    }
//    else{
//        [_playerView setPlayerPause];
//    }
//}

#pragma mark - MAVPlayerDelegate && VideoFrameBarDelegate
- (void)mAVPlayerIsPlaying
{
    playBtn.selected = YES;
}

- (void)mAVPlayerIsPause
{
    playBtn.selected = NO;
}

- (void)getCurrentPlayTime:(CGFloat)timeValue
{
    AVAsset *asset = [AVAsset assetWithURL:_videoUrl];
    double totalTime = CMTimeGetSeconds(asset.duration) * 1000; //ms
    CGFloat timePercent = timeValue/totalTime;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.frameBar setPercent:timePercent];
//    });
}

- (void)dragHandleViewWithPercent:(CGFloat)percent
{
    
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end

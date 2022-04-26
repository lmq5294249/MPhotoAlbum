//
//  MVideoEditView.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/17.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MVideoEditView.h"
#import <AVFoundation/AVFoundation.h>
#import "VideoFrameBar.h"
#import "MAVPlayerView.h"
#import "GifTimeView.h"
//#import "MVideoProcessManager.h"
#import "TationDeviceManager.h"

#define MinDuration 2500  //ms最小的视频长度为2.5s包含了前后转场在内

@interface MVideoEditView ()<MAVPlayerDelegate,VideoFrameBarDelegate>
{
    UIButton *confirmBtn;
    UIButton *cancelBtn;
    UIButton *playBtn;
    
    CMTimeRange originalTimeRange; //保存原始
    CMTimeRange originalPlayTimeRange; //保存原始
    CGFloat iphoneYOffset;
}

@property (nonatomic, strong) VideoAssetModel *videoModel;

@property (nonatomic, strong) NSURL *videoUrl;

//播放器
@property (nonatomic, strong) MAVPlayerView *playerView;

@property (nonatomic, strong) VideoFrameBar *frameBar;

@property (nonatomic, strong) NSMutableArray *videoUrlArray;

@property (nonatomic, strong) NSMutableArray *videoSegmentLengthArray;

//添加选择栏
@property (nonatomic, strong) GifTimeView *timeView;

@property (nonatomic, assign) CGFloat leftPercent;

@property (nonatomic, assign) CGFloat rightPercent;

@property (nonatomic, assign) BOOL isPhotoMedia;

@end


@implementation MVideoEditView

- (instancetype)initWithFrame:(CGRect)frame withMediaAssetArray:(NSMutableArray*)array mediaIndex:(NSInteger)mediaIndex
{
    if (self = [super initWithFrame:frame]) {
        
        iphoneYOffset = Tation_BottomSafetyDistance;
        self.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
        
        self.mediaAssetArray = array;
        self.index = mediaIndex;
        
        [self setUpUI];
        
        [self setUpButton];

    }
    
    return self;
}

- (void)setUpUI
{
    
    NSLog(@"==========单视频编辑模式=============");
    LocalAssetModel *model = self.mediaAssetArray[_index];
    VideoAssetModel *videoModel;
    PhotoAssetModel *photoModel;
    //获取数据初始化时间戳列表
    if (model.propertyType == PHAssetMediaTypeVideo) {
        videoModel = (VideoAssetModel *)self.mediaAssetArray[_index];
        _videoUrl = videoModel.originalVideoUrl;
    }
    else{
        photoModel = (PhotoAssetModel *)self.mediaAssetArray[_index];
        _videoUrl = photoModel.imageVideoUrl;
        _isPhotoMedia = YES;
    }

    _videoUrlArray = [NSMutableArray array];
    [_videoUrlArray addObject:_videoUrl];
    [self calculateVideoArraySegmentLength];
    //初始化预览播放器
    if (!_playerView) {
        _playerView = [[MAVPlayerView alloc] initWithFrame:CGRectMake(0, 100 + iphoneYOffset * 2.0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame)/1.78)];
        _playerView.delegate = self;
        [self addSubview:_playerView];
    }
    _playerView.videoUrlArray = _videoUrlArray;
    _playerView.curPlayIndex = 0;
    _playerView.videoSegmentLengthArray = _videoSegmentLengthArray;
    _playerView.singleVideo = YES;
    _playerView.keepLooping = YES;
    
    AVAsset *asset = [AVAsset assetWithURL:_videoUrl];
    double totalTime = CMTimeGetSeconds(asset.duration);
    BOOL flag = YES;
    if (totalTime > 12) {
        flag = NO;
    }
    //CGFloat videoFrameWidth = totalTime * 20.0;
    CGFloat videoFrameWidth = CGRectGetWidth(self.frame) - 20;
    self.frameBar = [[VideoFrameBar alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_playerView.frame) + 100, videoFrameWidth, 50) url:_videoUrl screenCapturePerSecond:flag];
    self.frameBar.delegate = self;
    self.frameBar.layer.cornerRadius = 5;
    self.frameBar.layer.masksToBounds = YES;
    [self addSubview:_frameBar];
    
    //更新数据
    CMTimeRange curTimeRange;
    CMTime beginTime;
    CMTime durationTime;
    CGFloat startPlayTimeValue;
    CGFloat durationPlayTimeValue;
    if (videoModel) {
        curTimeRange = videoModel.clipTimeRanges;
        originalTimeRange = CMTimeRangeMake(curTimeRange.start, curTimeRange.duration);
        CMTimeRange playTimeRange = videoModel.playTimeRanges;
        originalPlayTimeRange = CMTimeRangeMake(playTimeRange.start, playTimeRange.duration);
        beginTime = curTimeRange.start;
        durationTime = curTimeRange.duration;
        //刷新AVPlayer显示预览
        startPlayTimeValue = beginTime.value * 1000 / beginTime.timescale;
        durationPlayTimeValue = durationTime.value * 1000 / durationTime.timescale;
        [self.playerView setCurTotalTimeOffset:startPlayTimeValue];
        self.playerView.playStartTimeValue = startPlayTimeValue;
        self.playerView.playEndTimeValue = startPlayTimeValue + durationPlayTimeValue;
    }
    else{
        beginTime = kCMTimeZero;
        durationTime = CMTimeMake(photoModel.imageDuration * 1000, 1000);
        //刷新AVPlayer显示预览
        startPlayTimeValue = 0;
        durationPlayTimeValue = photoModel.imageDuration * 1000;
        [self.playerView setCurTotalTimeOffset:startPlayTimeValue];
        self.playerView.playStartTimeValue = startPlayTimeValue;
        self.playerView.playEndTimeValue = startPlayTimeValue + durationPlayTimeValue;
    }
    
    playBtn.selected = NO;
    
    _leftPercent = startPlayTimeValue / (totalTime * 1000);
    CGFloat x_offset = _leftPercent * CGRectGetWidth(self.frameBar.frame);
    _rightPercent = durationPlayTimeValue / (totalTime * 1000);
    CGFloat timeViewWidth = _rightPercent * CGRectGetWidth(self.frameBar.frame);
    
    //添加时间戳选择栏
    GifTimeView *timeView = [[GifTimeView alloc] initWithFrame:CGRectMake(x_offset, 0, timeViewWidth, CGRectGetHeight(self.frameBar.frame))];
    timeView.frameBarWidth = CGRectGetWidth(self.frameBar.frame);
    __weak typeof(self) weakSelf = self;
    timeView.blockValue = ^(CGFloat left, CGFloat right,BOOL finish) {
        
        TimeRange range = {left, right};
        weakSelf.leftPercent = left;
        weakSelf.rightPercent = right;
        NSLog(@"打印时间戳的左边: %f  右边: %f",left,right);
        if (finish) {
            //触摸完成更新数据和UI
            [weakSelf updateDataAndUI];
        }
    };
    timeView.hidden = NO;
    timeView.layer.cornerRadius = 5.0;
    timeView.layer.masksToBounds = YES;
    [self.frameBar addSubview:timeView];
    self.timeView = timeView;
    
    //设置拖动的视频最小时长限制
    CGFloat minDurationPercent = MinDuration / (totalTime * 1000);
    self.timeView.limitingPercent = minDurationPercent;
    [self.timeView currentLeft:_leftPercent rightPercent:_rightPercent];
}

- (void)setUpButton
{
    confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(CGRectGetWidth(self.frame) - 60, CGRectGetHeight(self.frame) - 80, 40, 40)];
    [confirmBtn setImage:[UIImage imageNamed:@"MQVideoEdit.Selected"] forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(saveMediaChangesAndReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:confirmBtn];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(20, CGRectGetHeight(self.frame) - 80, 40, 40)];
    [cancelBtn setImage:[UIImage imageNamed:@"MQVideoEdit.Discard"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(discardChangesAndReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelBtn];
    
    playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setFrame:CGRectMake((CGRectGetWidth(self.frame) - 40)/2, CGRectGetMinY(self.frameBar.frame) - 60, 40, 40)];
    [playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Play"] forState:UIControlStateNormal];
    [playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Pause"] forState:UIControlStateSelected];
    [playBtn addTarget:self action:@selector(replayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:playBtn];
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
    [_playerView setPlayerPause];
    //不保存修改
    MediaAssetModel *model = self.mediaAssetArray[_index];
    if (model.mediaType == MQMediaTypeVideo) {
        VideoAssetModel *videoModel = (VideoAssetModel *)model;
        videoModel.clipTimeRanges = originalTimeRange;
        videoModel.playTimeRanges = originalPlayTimeRange;
    }
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)saveMediaChangesAndReturn:(UIButton *)btn
{
    [_playerView setPlayerPause];
    
    [UIView animateWithDuration:0.7 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)replayVideo:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [_playerView rePlayAllTheTime];
    }
    else{
        [_playerView setPlayerPause];
    }
}

- (void)updateDataAndUI
{
    //更新数据
    AVAsset *asset = [AVAsset assetWithURL:_videoUrl];
    double totalTime = CMTimeGetSeconds(asset.duration) * 1000; //ms
    CMTime beginTime = CMTimeMake(totalTime * self.leftPercent, 1000);
    CMTime durationTiem = CMTimeMake(totalTime * self.rightPercent, 1000);
    CMTimeRange curTimeRange = CMTimeRangeMake(beginTime, durationTiem);
    if (!_isPhotoMedia) {
        VideoAssetModel *videoModel = (VideoAssetModel *)self.mediaAssetArray[_index];
        videoModel.clipTimeRanges = curTimeRange;
    }
    
    //刷新AVPlayer显示预览
    int startPlayTimeValue = totalTime*self.leftPercent;
    [self.playerView setCurTotalTimeOffset:startPlayTimeValue];
    self.playerView.playStartTimeValue = startPlayTimeValue;
    self.playerView.playEndTimeValue = startPlayTimeValue + totalTime * self.rightPercent;
    playBtn.selected = NO;
}

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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.frameBar setPercent:timePercent];
    });
}

- (void)dragHandleViewWithPercent:(CGFloat)percent
{
    
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}
@end

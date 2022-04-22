//
//  MAVPlayerView.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/6.
//  Copyright © 2021 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MAVPlayerDelegate <NSObject>

- (void)mAVPlayerIsPlaying;
- (void)mAVPlayerIsPause;
@optional
- (void)showPlayTimeOnScreen:(int)timeValue andTotalTime:(int)totalTime;
- (void)getCurrentPlayTime:(CGFloat)timeValue;
@end


@interface MAVPlayerView : UIView

@property (nonatomic, weak) id<MAVPlayerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *videoUrlArray;

@property (nonatomic, strong) NSURL *curPlayVideoUrl;

@property (nonatomic, assign) NSInteger curPlayIndex;

@property (nonatomic, assign) NSInteger nextPlayIndex;

@property (nonatomic, assign) double curPlayTime;

@property (nonatomic, assign) double curTotalTimeOffset; //当前视频的时间线偏移量

@property (nonatomic, strong) NSMutableArray *videoSegmentLengthArray; //各个视频片段不断总长度,有叠加前面视频的。也是各个片段的时间戳

//单视频播放标志位
@property (nonatomic, assign) BOOL singleVideo;
//单视频循环播放
@property (nonatomic, assign) BOOL keepLooping;
//单视频回放结束
@property (nonatomic, assign) BOOL playbackEnd;
//单视频区间播放结束时间
@property (nonatomic, assign) CGFloat playStartTimeValue;
@property (nonatomic, assign) CGFloat playEndTimeValue;
 
- (void)playVideoClick:(UIButton *)btn;

- (void)setCurTotalTimeOffset:(int)curTotalTimeOffset;
//移动时间轴停止播放
- (void)setPlayerPause;
//获取当前播放器是否在播放视频中
- (BOOL)getVideoPlayerIsPlaying;

- (void)rePlayAllTheTime;

@end


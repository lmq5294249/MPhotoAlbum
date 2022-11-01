//
//  MVideoPreviewView.h
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "EditTemplateModel.h"

@protocol MVideoPreviewDelegate <NSObject>

- (void)mAVPlayerIsPlaying;
- (void)mAVPlayerIsPause;
@optional
- (void)showPlayTimeOnScreen:(NSTimeInterval)timeValue andTotalTime:(NSTimeInterval)totalTime;
- (void)getCurrentPlayTime:(CGFloat)timeValue;
@end


@interface MVideoPreviewView : UIView

@property (nonatomic, weak) id<MVideoPreviewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *videoUrlArray;

@property (nonatomic, strong) NSMutableArray *videoSegmentLengthArray; //各个视频片段不断总长度,有叠加前面视频的。也是各个片段的时间戳\

@property (nonatomic, strong) NSMutableArray *clips;

@property (nonatomic, strong) NSMutableArray *clipTimeRanges;

@property (nonatomic, strong) NSMutableArray *transTimeArray;

@property (nonatomic, strong) EditTemplateModel *templateModel;

//自动播放
@property (nonatomic, assign) BOOL autoPlay;

//循环播放某一段时间，用于设置滤镜效果或者转场的展示
@property (nonatomic, assign) BOOL repeatPlayback;    //是否支持回放
@property (nonatomic)         CMTime beginReplayTime; //开始回放时间
@property (nonatomic)         CMTime endReplayTime;   //结束回放时间

- (void)initAVPlayerAndLoadVideoData;

- (void)synchronizeWithEditor;

- (void)synchronizePlayerWithEditor;

- (void)togglePlayPause:(id)sender;

- (void)setCurTotalTimeOffset:(int)curTotalTimeOffset;

- (void)startToPlay;

- (void)setPlayerPause;

- (void)supportPlaybackInSection:(BOOL)isSupport beginTime:(CMTime)beginTime endTime:(CMTime)endTime;

- (void)stopPlayAndDeletePlayTtem;

@end


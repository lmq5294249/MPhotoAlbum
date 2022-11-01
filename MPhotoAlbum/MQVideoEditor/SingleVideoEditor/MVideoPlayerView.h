//
//  MVideoPlayerView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/15.
//

#import <UIKit/UIKit.h>

@protocol MVideoPlayerDelegate <NSObject>

- (void)mAVPlayerIsPlaying;
- (void)mAVPlayerIsPause;
@optional
- (void)showPlayTimeOnScreen:(NSTimeInterval)timeValue andTotalTime:(NSTimeInterval)totalTime;
- (void)getCurrentPlayTime:(CGFloat)timeValue;
@end

typedef NS_ENUM(NSUInteger, MPlayerStatus) {
    MPlayerStatusPlaying,
    MPlayerStatusPause,
};

@interface MVideoPlayerView : UIView

@property (nonatomic, weak) id<MVideoPlayerDelegate> delegate;
@property (nonatomic, assign) MPlayerStatus videoPlayStatus;
@property (nonatomic, strong) NSURL *curPlayVideoUrl;
//单视频循环播放
@property (nonatomic, assign) BOOL keepLooping;
//单视频回放结束
@property (nonatomic, assign) BOOL playbackEnd;
//自动播放
@property (nonatomic, assign) BOOL autoPlay;
//单视频区间播放结束时间
@property (nonatomic, assign) CGFloat playStartTimeValue;
@property (nonatomic, assign) CGFloat playEndTimeValue;

- (void)setTheCurrentPlayerTime:(NSTimeInterval)value;

- (void)play;

@end


//
//  MVideoPlayerView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/15.
//

#import "MVideoPlayerView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MVideoPlayerView ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL playEnd;
@property (nonatomic, strong) id playbackObserver;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, assign) NSTimeInterval videoDuration;

@end


@implementation MVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.keepLooping = NO;
        self.autoPlay = NO;
        self.playbackEnd = NO;
        [self setUpUIForAVPlayer];
        
    }
    return self;
}

- (void)setUpUIForAVPlayer
{
    self.backgroundColor = [UIColor blackColor];
    [self.layer addSublayer:self.playerLayer];
    self.videoPlayStatus = MPlayerStatusPause;
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.playButton addTarget:self action:@selector(playVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause40x40"] forState:UIControlStateNormal];
    [self addSubview:self.playButton];
}

- (void)setTheCurrentPlayerTime:(NSTimeInterval)value
{
    //value是时间长度的比例
    CMTimeValue timeValueTemp = value;
    CMTime newTime = CMTimeMake(timeValueTemp, 1000);
    //精确度比较高的拖动
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (finished) {
                [self.player pause];
            }
        }];
    });
}

- (void)playVideoClick:(UIButton *)btn
{

    if (self.videoPlayStatus == MPlayerStatusPause) {
        if (!self.keepLooping && self.playEnd) {
            [self.player seekToTime:kCMTimeZero];
        }
        [self.player play];
        [self.delegate mAVPlayerIsPlaying];
        self.videoPlayStatus = MPlayerStatusPlaying;
    }
    else if (self.videoPlayStatus == MPlayerStatusPlaying)
    {
        [self.player pause];
        [self.delegate mAVPlayerIsPause];
        self.videoPlayStatus = MPlayerStatusPause;
    }
}

- (void)play
{
    [self.player play];
    self.videoPlayStatus = MPlayerStatusPlaying;
}

#pragma mark - AVPlayer
//设置当前播放视频
- (void)setCurPlayVideoUrl:(NSURL *)curPlayVideoUrl
{
    _curPlayVideoUrl = curPlayVideoUrl;
    AVURLAsset *asset = [AVURLAsset assetWithURL:curPlayVideoUrl];
    CMTime time = [asset duration];
    self.videoDuration = CMTimeGetSeconds(time);
    //赋值视频数组时初始化AVplayer
    if (_curPlayVideoUrl && self.player) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_curPlayVideoUrl];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player replaceCurrentItemWithPlayerItem:item];
            [self playerItemAddNotification];
            if (self.playStartTimeValue > 0) {
                [self.player seekToTime:CMTimeMake(self.playStartTimeValue, 1000)];
            }
            else{
                [self.player seekToTime:kCMTimeZero];
            }
            
            if (self.autoPlay) {
                [self.player play];
            }
        });
    }
    
}

- (AVPlayer *)player{
    
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        __weak typeof(self) weakSelf = self;
        //每秒回调一次
        self.playbackObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(25, 1000) queue:NULL usingBlock:^(CMTime time){
            
            //返回当前的时间戳

            NSTimeInterval currentTime = CMTimeGetSeconds(time);//当前时间进度

            if (weakSelf.delegate) {
                //NSLog(@"播放时间: %@",showTimestamp);
                [weakSelf.delegate showPlayTimeOnScreen:currentTime andTotalTime:weakSelf.videoDuration];
            }
            
            //单视频
            CGFloat timeTemp = (time.value * 1000)/ time.timescale;//当前时间进
            //NSLog(@"打印播放时间: %fms",timeTemp);
            if (timeTemp > weakSelf.playEndTimeValue && weakSelf.keepLooping) {
                [weakSelf.player pause];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.player seekToTime:CMTimeMake(weakSelf.playStartTimeValue, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                        if (finished) {
                            [weakSelf.player play];
                        }
                    }];
                });
            }
                
                
//                {
//                    [weakSelf.delegate getCurrentPlayTime:timeTemp];
//                }

            
        }];
    }
    
    return _player;
}

- (AVPlayerLayer *)playerLayer
{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    return _playerLayer;
}


- (void)playerItemAddNotification {
    // 播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

- (void)playerItemRemoveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)playbackFinished:(NSNotification *)noti{
    if (self.keepLooping && self.player) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
        self.videoPlayStatus = MPlayerStatusPlaying;
    }
    else{
        self.playEnd = YES;
    }
}

- (BOOL)getVideoPlayerIsPlaying
{
    if (@available(iOS 10.0, *)) {
        AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
        if (playerState == AVPlayerTimeControlStatusPlaying) {
            return YES;
        }
    } else {
        // Fallback on earlier versions
        return NO;
    }
    
    return NO;
}

//秒数转时间轴的时间显示
-(NSString *)durationString:(double)duration
{
    NSString *str;
    if (duration >= 0 && duration < 60) {
        int sec = (int)duration % 60;
        str = [NSString stringWithFormat:@"00:%02d", sec];
    }else if (duration >= 60 && duration <= 3600) {
        int min = duration/60;
        int sec = (int)duration%60;
        str = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }else {
        int hour = (int)duration/3600;
        int min = ((int)duration%3600)/60;
        int sec = ((int)duration%3600)%60;
        str = [NSString stringWithFormat:@"%d:%02d:%02d", hour, min, sec];
    }
    return str;
}

- (void)dealloc
{
    if (self.player) {
        [self.player pause];
    }
    [self.player removeTimeObserver:_playbackObserver];
    NSLog(@"%s",__func__);
}

@end

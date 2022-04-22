//
//  MAVPlayerView.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/6.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MAVPlayerView.h"
#import <AVKit/AVKit.h>


@interface MAVPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL playEnd;

@property (nonatomic, strong) id playbackObserver;

@property (nonatomic,strong) UIButton *playButton;

@end


@implementation MAVPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUIForAVPlayer];
        
    }
    return self;
}

- (void)setUpUIForAVPlayer
{
    self.backgroundColor = [UIColor blackColor];
    [self.layer addSublayer:self.playerLayer];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.playButton addTarget:self action:@selector(playVideoClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"pause40x40"] forState:UIControlStateNormal];
    [self addSubview:self.playButton];
    
}

- (void)playVideoClick:(UIButton *)btn
{
    //btn.selected = !btn.selected;
    AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
    if (playerState == AVPlayerTimeControlStatusPaused) {
        [self.player play];
        [self.delegate mAVPlayerIsPlaying];
    }
    else if (playerState == AVPlayerTimeControlStatusPlaying)
    {
        [self.player pause];
        [self.delegate mAVPlayerIsPause];
    }
}

- (void)setPlayerPause
{
    AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
    if (playerState == AVPlayerTimeControlStatusPlaying) {
        [self.player pause];
        [self.delegate mAVPlayerIsPause];
    }
}

- (void)rePlayAllTheTime
{
    AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
    if (playerState == AVPlayerTimeControlStatusPaused) {
        [self.player play];
        [self.delegate mAVPlayerIsPlaying];
    }
    else if (playerState == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate)
    {
        [self.player play];
    }
}

#pragma mark - 各种属性设置
- (void)setCurTotalTimeOffset:(int)curTotalTimeOffset
{
    _curTotalTimeOffset = curTotalTimeOffset;
    if (_curTotalTimeOffset >= 0 && _videoUrlArray.count > 0) {
        NSInteger last = _videoUrlArray.count - 1;
        if (_curTotalTimeOffset >= [_videoSegmentLengthArray[last] intValue]) {
            _curTotalTimeOffset = [_videoSegmentLengthArray[last] intValue];
        }
        //当前播放在那个视频片段中
        for (int i = 0; i < _videoUrlArray.count; i++) {
            int videoSegmentValue = [_videoSegmentLengthArray[i] intValue];
            
            if (_curTotalTimeOffset <= videoSegmentValue) {
                //如果当前是时间线小于视频片段的长度那么就说明在这段时间片段内
                //比较是否切换的播放的片段视频
                if (_curPlayIndex != i) {
                    _curPlayIndex = i;
                    [self playerItemRemoveNotification]; //移除监听
                    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoUrlArray[_curPlayIndex]];
                    [self.player replaceCurrentItemWithPlayerItem:item];
                    [self playerItemAddNotification]; //添加监听
                }
                //NSLog(@"打印当前的时间片段是 : %ld",(long)_curPlayIndex);
                //获取在当前视频片段内的时间戳：总时间偏移 - 前面几个时间片段的时间总和
                if (_curPlayIndex == 0) {
                    _curPlayTime = _curTotalTimeOffset;
                }
                else{
                    _curPlayTime = _curTotalTimeOffset - [_videoSegmentLengthArray[i-1] intValue];
                }
                [self setTheCurrentPlayerTime:_curPlayTime];
                break;//跳出循环
            }
            else{
                if (i == _videoUrlArray.count - 1) {
                    //如果最后一个视频都没有那就报错
                    NSLog(@"AVplayer ERROR!!!!!!!!!!!!!!!!!!!!");
                }
            }
            
        }
        
    }
}

- (void)setTheCurrentPlayerTime:(double)value
{
    //value是时间长度的比例
    //跳转时间先暂停播放，然后切换时间
    if (_curPlayIndex >= 0) {
        //[self.player pause];
        //算出当前偏移量所占的比例
        //double curSegmentLength = [_videoSegmentLengthArray[_curPlayIndex] doubleValue] - [_videoSegmentLengthArray[_curPlayIndex-1] doubleValue];
        //double timeRatio = value / curSegmentLength;
       // CMTimeValue timeValueTemp = timeRatio * self.player.currentItem.duration.value;
        CMTimeValue timeValueTemp = value;
        CMTime newTime = CMTimeMake(timeValueTemp, 1000);
        
        //精确度比较低的拖动
//        [self.player seekToTime:newTime completionHandler:^(BOOL finished) {
//            if (finished) {
//                NSLog(@"****************时间切换成功*****************");
//            }
//        }];
        //精确度比较高的拖动
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                            if (finished) {
                                [self.player pause];
                            }
                        }];
                    });
                    
                });
    }
}


#pragma mark - AVPlayer
//设置当前播放视频
- (void)setVideoUrlArray:(NSMutableArray *)videoUrlArray
{
    _videoUrlArray = videoUrlArray;
    if (_videoUrlArray.count == 0) {
        [self.player replaceCurrentItemWithPlayerItem:nil];
        return;
    }
    //赋值视频数组时初始化AVplayer
    if (_videoUrlArray) {
        [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:videoUrlArray[0]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player replaceCurrentItemWithPlayerItem:item];
            [self playerItemAddNotification];
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
            //NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);//总时长
            NSInteger count = weakSelf.videoUrlArray.count - 1;
            int totalTime = [weakSelf.videoSegmentLengthArray[count] intValue];
            int currentTime = (time.value * 1000) / time.timescale;//当前时间进度
            if (weakSelf.curPlayIndex > 0) {
                currentTime = currentTime + [weakSelf.videoSegmentLengthArray[weakSelf.curPlayIndex-1] intValue];
            }

            NSLog(@"时间轴的位置：%d",currentTime);
            //NSString *showTimestamp = [NSString stringWithFormat:@"%@ / %@",[weakSelf durationString:timeValue],[weakSelf durationString:totalTime]];
            
            if (weakSelf.delegate && !weakSelf.singleVideo) {
                //NSLog(@"播放时间: %@",showTimestamp);
                [weakSelf.delegate showPlayTimeOnScreen:currentTime andTotalTime:totalTime];
            }
            else{
                //单视频
                CGFloat timeTemp = (time.value * 1000)/ time.timescale;//当前时间进
                NSLog(@"打印播放时间: %fms",timeTemp);
                if (timeTemp >weakSelf.playEndTimeValue) {
                    [weakSelf.player pause];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.player seekToTime:CMTimeMake(weakSelf.playStartTimeValue, 1000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
                            if (finished) {
                                [weakSelf.player play];
                            }
                        }];
                    });
                }
                else{
                    [weakSelf.delegate getCurrentPlayTime:timeTemp];
                }
            }
            
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
    //[self.player pause];
    if (_curPlayIndex < _videoUrlArray.count-1) {
        [self playerItemRemoveNotification];
        //当前播放的片段在总视频中不是最后一个那么继续播放
        _curPlayIndex++;
        NSLog(@"切换播放视频为 : %ld",(long)_curPlayIndex);
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoUrlArray[_curPlayIndex]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.player replaceCurrentItemWithPlayerItem:item];
            [self playerItemAddNotification];
            [self.player play];
        });
    }
    else{
        NSLog(@"视频播放结束");
        if (_singleVideo && _keepLooping) {
            [self.player seekToTime:kCMTimeZero];
            [self.player play];
        }
    }
}

- (BOOL)getVideoPlayerIsPlaying
{
    AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
    if (playerState == AVPlayerTimeControlStatusPlaying) {
        return YES;
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
    [self.player removeTimeObserver:_playbackObserver];
    NSLog(@"%s",__func__);
}

@end

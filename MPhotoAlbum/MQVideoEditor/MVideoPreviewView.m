//
//  MVideoPreviewView.m
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//

#import "MVideoPreviewView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MQVideoEditor.h"


@interface PlayerView : UIView

@property (nonatomic, retain) AVPlayer *player;

@end

@implementation PlayerView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player
{
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

static NSString* const AVCDVPlayerViewControllerStatusObservationContext    = @"AVCDVPlayerViewControllerStatusObservationContext";
static NSString* const AVCDVPlayerViewControllerRateObservationContext = @"AVCDVPlayerViewControllerRateObservationContext";
static void testContext(){};

@interface MVideoPreviewView ()
{
    BOOL            _seekToZeroBeforePlaying;
    float            _lastScrubSliderValue;
    float            _playRateToRestore;
    id                _timeObserver;
    
    float            _transitionDuration;
    BOOL            _transitionsEnabled;
}

@property (nonatomic, strong) MQVideoEditor   *editor;

@property (nonatomic, strong) NSMutableArray *arrVaild;

@property (nonatomic, strong) AVPlayer       *player;
@property (nonatomic, strong) AVPlayerItem   *playerItem;
@property (nonatomic, strong) PlayerView     *playerView;
@property (nonatomic, strong) UIButton       *playBtn;
@property (nonatomic, strong)  UISlider      *scrubber;
@property (nonatomic, strong)  UILabel       *currentTimeLabel;

@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL scrubInFlight;

@property (nonatomic, assign) NSTimeInterval duration;

@end


@implementation MVideoPreviewView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpVideoPlayerUI];

        [self loadData];
    }
    
    return self;
}

- (void)setUpVideoPlayerUI
{
    //初始化View 16 ：9
    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self addSubview:self.playerView];
    [self.playerView setBackgroundColor:[UIColor orangeColor]];
    
    
    _scrubber = [[UISlider alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 10, CGRectGetWidth(self.frame), 20)];
    //[self addSubview:_scrubber];
    [_scrubber addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    [_scrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
    [_scrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
    [_scrubber addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
    [_scrubber addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
    
    _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [self addSubview:_currentTimeLabel];
    
//    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [_playBtn setFrame:CGRectMake((CGRectGetWidth(self.frame) - 40)/2, CGRectGetHeight(self.frame) - 40, 40, 40)];
//    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Play"] forState:UIControlStateNormal];
//    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Pause"] forState:UIControlStateSelected];
//    [_playBtn addTarget:self action:@selector(togglePlayPause:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_playBtn];
}

- (void)loadData
{
    self.autoPlay = NO;
    [self updateScrubber];
    [self updateTimeLabel];
    
    self.editor = [[MQVideoEditor alloc] init];
}


- (void)initAVPlayerAndLoadVideoData
{
    [self synchronizeWithEditor];
    
    if (!self.player) {
        _seekToZeroBeforePlaying = NO;
        self.player = [[AVPlayer alloc] init];
        [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:(__bridge void *)(AVCDVPlayerViewControllerRateObservationContext)];
        [self.playerView setPlayer:self.player];
    }
    
    [self addTimeObserverToPlayer];
    
    
    //前面素材已经添加了
    [self.editor buildCompositionObjectsForPlayback];
    [self synchronizePlayerWithEditor];
}

//同步数据到视频编辑工具
- (void)synchronizeWithEditor
{
    _transitionDuration = 3.0; // 默认变换时间
    _transitionsEnabled = YES;
    
    // Transitions
    if (_transitionsEnabled) {
        self.editor.transitionDuration = CMTimeMakeWithSeconds(_transitionDuration, 600);
    } else {
        self.editor.transitionDuration = kCMTimeInvalid;
    }
    
    self.editor.clips = self.clips;
    self.editor.clipTimeRanges = self.clipTimeRanges;
    self.editor.transTimeArray = self.transTimeArray;
    self.editor.templateModel = self.templateModel;
}


/**
 *  开始播放
 */
- (void)synchronizePlayerWithEditor
{
    if ( self.player == nil )
        return;
    
    AVPlayerItem *playerItem = [self.editor playerItem];
    
    if (self.playerItem != playerItem) {
        if ( self.playerItem ) {
            [self.playerItem removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem]; // 移除监听
        }
        
        self.playerItem = playerItem;
        
        if ( self.playerItem ) {
            // 监听status属性，是否已经就绪
            [self.playerItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial) context:(__bridge void *)(AVCDVPlayerViewControllerStatusObservationContext)];
            
            // 播放完成的监听
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
        }
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        
        if (self.autoPlay) {
            [self.player play];
        }
    }
}


#pragma mark - Public Update
- (void)addTimeObserverToPlayer
{
    if (_timeObserver)
        return;
    
    if (self.player == nil)
        return;
    
    if (self.player.currentItem.status != AVPlayerItemStatusReadyToPlay)
        return;
    
    double duration = CMTimeGetSeconds([self playerItemDuration]);
    
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.scrubber bounds]);
        double interval = 0.5 * duration / width;
        
        /* The time label needs to update at least once per second. */
        if (interval > 1.0)
            interval = 1.0;
        __weak MVideoPreviewView *weakSelf = self;
        _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            //返回当前的时间戳
            [weakSelf updateScrubber];
            [weakSelf updateTimeLabel];
            
            int currentTime = (int)((time.value * 1000) / time.timescale);//当前时间进度
            int totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration) * 1000;// = [weakSelf.videoSegmentLengthArray[count] intValue];
            
            if (weakSelf.repeatPlayback && currentTime > ((weakSelf.endReplayTime.value * 1000) / weakSelf.endReplayTime.timescale)) {
                [weakSelf.player pause];
                [weakSelf.player seekToTime:weakSelf.beginReplayTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
                [weakSelf.player play];
                weakSelf.repeatPlayback = YES;
            }
            
            if (weakSelf.delegate) {
                [weakSelf.delegate showPlayTimeOnScreen:CMTimeGetSeconds(time) andTotalTime:CMTimeGetSeconds(weakSelf.player.currentItem.duration)];
            }
            
        }];
    }
}

- (void)removeTimeObserverFromPlayer
{
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (CMTime)playerItemDuration
{
    AVPlayerItem *playerItem = [self.player currentItem];
    CMTime itemDuration = kCMTimeInvalid;
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        itemDuration = [playerItem duration];
    }
    
    /* Will be kCMTimeInvalid if the item is not ready to play. */
    return itemDuration;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == (__bridge void *)(AVCDVPlayerViewControllerRateObservationContext) ) {
        float newRate = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        NSNumber *oldRateNum = [change objectForKey:NSKeyValueChangeOldKey];
        if ( [oldRateNum isKindOfClass:[NSNumber class]] && newRate != [oldRateNum floatValue] ) {
            _playing = ((newRate != 0.f) || (_playRateToRestore != 0.f));
            [self updatePlayPauseButton];
            [self updateScrubber];
            [self updateTimeLabel];
        }
    }
    else if ( context == (__bridge void *)(AVCDVPlayerViewControllerStatusObservationContext) ) {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            // 加载完成可以读取duration属性
            
            [self addTimeObserverToPlayer];
        }
        else if (playerItem.status == AVPlayerItemStatusFailed) {
            [self reportError:playerItem.error];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if (context != testContext) {
        //        NSLog(@"this also yes");
    }
}

- (void)updatePlayPauseButton
{
    //更细Play播放按钮状态
    
}

- (void)updateTimeLabel
{
    double seconds = CMTimeGetSeconds([self.player currentTime]);
    if (!isfinite(seconds)) {
        seconds = 0;
    }
    
    int secondsInt = round(seconds);
    int minutes = secondsInt/60;
    secondsInt -= minutes*60;
    
    self.currentTimeLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *timeStr = [NSString stringWithFormat:@"%.2i:%.2i", minutes, secondsInt];
    //NSLog(@"时间戳:%@",timeStr);
    self.currentTimeLabel.text = timeStr;
}

- (void)updateScrubber
{
    double duration = CMTimeGetSeconds([self playerItemDuration]);
    
    if (isfinite(duration)) {
        double time = CMTimeGetSeconds([self.player currentTime]);
        [self.scrubber setValue:time / duration];
    }
    else {
        [self.scrubber setValue:0.0];
    }
}

- (void)reportError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                                message:[error localizedRecoverySuggestion]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            
            [alertView show];
        }
    });
}

#pragma mark - IBActions
- (void)togglePlayPause:(id)sender
{
    _playing = !_playing;
    if ( _playing ) {
        if ( _seekToZeroBeforePlaying ) {
            [self.player seekToTime:kCMTimeZero];
            _seekToZeroBeforePlaying = NO;
        }
        [self.player play];
        [self.delegate mAVPlayerIsPlaying];
    }
    else {
        [self.player pause];
        [self.delegate mAVPlayerIsPause];
    }
}

- (IBAction)beginScrubbing:(id)sender
{
    _seekToZeroBeforePlaying = NO;
    _playRateToRestore = [self.player rate];
    [self.player setRate:0.0];
    
    [self removeTimeObserverFromPlayer];
}

- (IBAction)scrub:(id)sender
{
    _lastScrubSliderValue = [self.scrubber value];

    if ( ! _scrubInFlight )
        [self scrubToSliderValue:_lastScrubSliderValue];
}

- (void)scrubToSliderValue:(float)sliderValue
{
    double duration = CMTimeGetSeconds([self playerItemDuration]);
    
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.scrubber bounds]);
        
        double time = duration*sliderValue;
        double tolerance = 1.0f * duration / width;
        
        _scrubInFlight = YES;
        
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)
                toleranceBefore:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
                 toleranceAfter:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
              completionHandler:^(BOOL finished) {
                  weakSelf.scrubInFlight = NO;
                  [weakSelf updateTimeLabel];
              }];
//        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
//            weakSelf.scrubInFlight = NO;
//            [weakSelf updateTimeLabel];
//        }];
    }
}

- (IBAction)endScrubbing:(id)sender
{
    if ( _scrubInFlight )
        [self scrubToSliderValue:_lastScrubSliderValue];
    [self addTimeObserverToPlayer];
    
    [self.player setRate:_playRateToRestore];
    _playRateToRestore = 0.f;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    _seekToZeroBeforePlaying = YES;
}

- (void)setCurTotalTimeOffset:(int)curTotalTimeOffset
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CMTimeValue timeValueTemp = curTotalTimeOffset;
        CMTime newTime = CMTimeMake(timeValueTemp, 1000);
        [weakSelf.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf updateTimeLabel];
        }];
    });
    _scrubInFlight = NO;
}

- (void)startToPlay
{
    [self.player play];
    _playing = YES;
}

- (void)setPlayerPause
{
    if (@available(iOS 10.0, *)) {
        AVPlayerTimeControlStatus playerState = self.player.timeControlStatus;
        if (playerState == AVPlayerTimeControlStatusPlaying) {
            [self.player pause];
            [self.delegate mAVPlayerIsPause];
            _playing = NO;
        }
    } else {
        // Fallback on earlier versions
        if (_playing) {
            [self.player pause];
            [self.delegate mAVPlayerIsPause];
            _playing = NO;
        }
    }
    
}

#pragma mark - 时间段回放设置
- (void)supportPlaybackInSection:(BOOL)isSupport beginTime:(CMTime)beginTime endTime:(CMTime)endTime
{
    self.repeatPlayback = isSupport;
    self.beginReplayTime = beginTime;
    self.endReplayTime = endTime;
}


- (void)stopPlayAndDeletePlayTtem
{
    if (_playing) {
        [self.player pause];
        _playing = NO;
    }
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self removeTimeObserverFromPlayer];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem]; // 移除监听
    self.playerItem = nil;
//    [self.playerView removeFromSuperview];
//    self.playerView = nil;
    self.player = nil;
//    self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
//    [self addSubview:self.playerView];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}


@end

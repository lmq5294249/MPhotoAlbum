//
//  MVideoToolControlView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/15.
//

#import "MVideoToolControlView.h"

@interface MVideoToolControlView ()
{
    NSDate *startTime;
}

@end

@implementation MVideoToolControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        startTime = [NSDate date];
    }
    return self;
}

- (void)setupUI
{
    self.leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 18)];
    self.leftTimeLabel.text = @"00:00";
    self.leftTimeLabel.font = [UIFont systemFontOfSize:12.0];
    self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 36, 0, 36, 18)];
    self.rightTimeLabel.text = @"00:00";
    self.rightTimeLabel.font = [UIFont systemFontOfSize:12.0];
    self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.rightTimeLabel];
    
    self.timeSlider = [[UISlider alloc] initWithFrame:CGRectMake( 36 + 8, 1, CGRectGetWidth(self.frame) - 36*2 - 8*2, 16)];
    self.timeSlider.value = 0;
    self.timeSlider.minimumValue = 0;
    self.timeSlider.maximumValue = 1.0;
    [self addSubview:self.timeSlider];
    
    [self.timeSlider addTarget:self action:@selector(sliderValurChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.timeSlider addTarget:self action:@selector(slidDidEnd:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setIsDragEnable:(BOOL)isDragEnable
{
    _isDragEnable = isDragEnable;
    self.timeSlider.userInteractionEnabled = isDragEnable;
}

- (void)resetVideoTool
{
    self.timeSlider.value = 0;
    self.leftTimeLabel.text = @"00:00";
}

#pragma mark - MVideoPlayerDelegate
- (void)mAVPlayerIsPlaying
{
    
}
- (void)mAVPlayerIsPause
{
    
}
- (void)showPlayTimeOnScreen:(NSTimeInterval)timeValue andTotalTime:(NSTimeInterval)totalTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.duration = totalTime;
        self.leftTimeLabel.text = [self durationString:timeValue];
        self.rightTimeLabel.text = [self durationString:totalTime];
        double progressValue = timeValue / totalTime;
        self.timeSlider.value = progressValue;
        NSLog(@"打印播放进度: %.4f",progressValue);
    });
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

- (void)sliderValurChanged:(UISlider*)slider
{
    //设置间隔不能每次值改变读取视频预览帧比较卡
    double deltaTime = [[NSDate date] timeIntervalSinceDate:startTime] ;
    if (deltaTime * 1000 > 100 && self.sliderChangeValueBlock) {
        NSTimeInterval time = self.duration * slider.value;
        self.sliderChangeValueBlock(time,NO);
        startTime = [NSDate date];
    }
    
}

- (void)slidDidEnd:(UISlider*)slider
{
    NSTimeInterval time = self.duration * slider.value;
    self.sliderChangeValueBlock(time,YES);
}

@end

//
//  MediaPlayerView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/22.
//

#import "MediaPlayerView.h"
#import "TationDeviceManager.h"

@interface MediaPlayerView ()

@property (nonatomic, strong) AVPlayer *videoPlayer;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) UISlider *pSlider;
@property (nonatomic, strong) UIView *controlView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *leftTimeLabel;
@property (nonatomic, strong) UILabel *rightTimeLabel;
@end

@implementation MediaPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat blankSpacesValue = 18.0;
    CGFloat bottomDistValue = Tation_BottomSafetyDistance + 76 + 16;
    
    self.controlView = [[UIView alloc] initWithFrame:CGRectMake(16, self.frame.size.height - bottomDistValue - 20, CGRectGetWidth(self.frame) - 32, 18)];
    [self addSubview:self.controlView];
    
    self.leftTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 38, 18)];
    self.leftTimeLabel.text = @"00:00";
    self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.leftTimeLabel.font = [UIFont boldSystemFontOfSize:12];
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    [self.controlView addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.controlView.frame) - 38, 0, 38, 18)];
    self.rightTimeLabel.text = @"00:00";
    self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.rightTimeLabel.font = [UIFont boldSystemFontOfSize:12];
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    [self.controlView addSubview:self.rightTimeLabel];
    
    //画一个小圆球
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:view.frame cornerRadius:view.frame.size.width/2.0];
    CAShapeLayer *shadpeLayer = [CAShapeLayer layer];
    shadpeLayer.frame = view.frame;
    shadpeLayer.path = path.CGPath;
    shadpeLayer.masksToBounds = YES;
    shadpeLayer.fillColor = [UIColor whiteColor].CGColor;
    [view.layer addSublayer:shadpeLayer];
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.pSlider = [[UISlider alloc] initWithFrame:CGRectMake(46, 0, CGRectGetWidth(self.controlView.frame) - 92, 18)];
    self.pSlider.value = 0;
    [self.pSlider setThumbImage:roundImg forState:UIControlStateNormal];
    self.pSlider.minimumTrackTintColor = [UIColor whiteColor];
    self.pSlider.maximumTrackTintColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    [self.pSlider addTarget:self action:@selector(pSliderTouchUpInsider:) forControlEvents:UIControlEventTouchUpInside];
    [self.pSlider addTarget:self action:@selector(pSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.controlView addSubview:self.pSlider];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.frame = CGRectMake((CGRectGetWidth(self.frame) - 48)/2, (CGRectGetHeight(self.frame) - 48)/2, 48, 48);
    [self.playButton addTarget:self action:@selector(clickPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.playButton setImage:Tation_Resource_Image(@"Hohem_Album_play") forState:UIControlStateNormal];
    [self.playButton setImage:Tation_Resource_Image(@"Hohem_Album_pause") forState:UIControlStateSelected];
    [self addSubview:self.playButton];
    
}

- (void)resetViewLayout:(LocalAssetModel *)assetModel
{
    PHAsset *asset = assetModel.asset;
    CGFloat w = asset.pixelWidth;
    CGFloat h = asset.pixelHeight;
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    CGFloat bottomMarginValue = bottomDistValue + 76 + 16;
    if (h > w) {
        //竖方向视频
        self.controlView.frame = CGRectMake(16, self.frame.size.height - bottomMarginValue - 20, self.frame.size.width - 32, 18);
        self.leftTimeLabel.frame = CGRectMake(0, 0, 38, 18);
        self.rightTimeLabel.frame = CGRectMake(CGRectGetWidth(self.controlView.frame) - 38, 0, 38, 18);
        self.pSlider.frame = CGRectMake(46, 0, CGRectGetWidth(self.controlView.frame) - 92, 18);
        
    }
    else{
        //横方向视频
        //计算
        CGFloat screenWidth = CGRectGetWidth(self.frame);
        CGFloat screenHeight = CGRectGetHeight(self.frame);
        CGFloat ratio = w/h;
        CGFloat newVideoHeight = screenWidth/ratio;
        CGFloat marginTop = (screenHeight - newVideoHeight)/2;
        CGFloat margin = marginTop + newVideoHeight + 10;
        
        self.controlView.frame = CGRectMake(16, margin + 4, self.frame.size.width - 32, 18);
        self.leftTimeLabel.frame = CGRectMake(0, 0, 38, 18);
        self.rightTimeLabel.frame = CGRectMake(CGRectGetWidth(self.controlView.frame) - 38, 0, 38, 18);
        self.pSlider.frame = CGRectMake(46, 0, CGRectGetWidth(self.controlView.frame) - 92, 18);
    }
    [self.pSlider setValue:0.0];
    self.leftTimeLabel.text = @"00:00";
    double totalSeconds = asset.duration;
    self.rightTimeLabel.text = [NSString stringWithFormat:@"%@",[self durationString:totalSeconds]];
    self.playButton.hidden = NO;
}

- (void)setAssetModel:(LocalAssetModel *)assetModel
{
    __weak typeof(self) weakSelf = self;
    self.videoPlayer = nil;
    if (self.playerLayer) {
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    //设置asset
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;

    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestPlayerItemForVideo:assetModel.asset options:options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        
        self.videoPlayer = [AVPlayer playerWithPlayerItem:playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        self.playerLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        [self.videoPlayer seekToTime:kCMTimeZero];
        [weakSelf resetViewLayout:assetModel];
        
        [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            CMTime currentTime = weakSelf.videoPlayer.currentItem.currentTime;
            CMTime totalTime = weakSelf.videoPlayer.currentItem.duration;

            double currentSeconds = CMTimeGetSeconds(currentTime);
            double totalSeconds = CMTimeGetSeconds(totalTime);;

            weakSelf.leftTimeLabel.text = [NSString stringWithFormat:@"%@",[weakSelf durationString:currentSeconds]];
            weakSelf.rightTimeLabel.text = [NSString stringWithFormat:@"%@",[weakSelf durationString:totalSeconds]];
            CGFloat p = currentSeconds/totalSeconds;
            weakSelf.pSlider.value = p;
            if (p >= 1) {
                //进度条返回原状
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf videoPlayerPause];
                    weakSelf.controlView.hidden = NO;
                    weakSelf.playButton.selected = NO;
                    weakSelf.playButton.hidden = NO;
                    if (weakSelf.delegate) {
                        [weakSelf.delegate hiddenControlView:NO];
                    }
                });
            }
            
        }];
        
        
    }];

    
}

- (void)clickPlayBtn:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self videoPlayerPlay];
        //隐藏UI
        self.controlView.hidden = YES;
        self.playButton.hidden = YES;
        if (self.delegate) {
            [self.delegate hiddenControlView:YES];
        }
    }
    else{
        [self videoPlayerPause];
        self.controlView.hidden = NO;
        self.playButton.hidden = NO;
    }
}


- (void)videoPlayerPlay{
    self.isPlaying = YES;
    if (self.pSlider.value >= 1.0) {
        self.pSlider.value = 0.0;
        [self.videoPlayer seekToTime:kCMTimeZero];
    }
    [self.videoPlayer play];
    self.videoPlayer.rate = 1.0;
    
}

- (void)videoPlayerPause
{
    self.isPlaying = NO;
    self.playButton.selected = NO;
    self.playButton.hidden = NO;
    [self.videoPlayer pause];
}

- (void)videoPlayerStop
{
    self.isPlaying = NO;
    self.playButton.selected = NO;
    self.playButton.hidden = NO;
    [self.videoPlayer seekToTime:kCMTimeZero];
    [self.videoPlayer pause];
}

- (void)pSliderTouchUpInsider:(id)sender
{
    if (self.isPlaying) {
        [self.videoPlayer play];
        self.playButton.enabled = YES;
    }
}

- (void)pSliderValueChange:(id)sender
{
    if (self.isPlaying) {
        [self.videoPlayer pause];
        self.playButton.enabled = NO;
    }
    int64_t videoDuration = CMTimeGetSeconds(self.videoPlayer.currentItem.duration) * 1000;
    int64_t value = self.pSlider.value * videoDuration;
    CMTime newTime = CMTimeMake(value, 1000);
    [self.videoPlayer seekToTime:newTime];
}




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
        //int hour = (int)duration/3600;
        int min = ((int)duration%3600)/60;
        int sec = ((int)duration%3600)%60;
        str = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }
    return str;
}


#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    //self.controlView.hidden = !self.controlView.hidden;
    if (self.isPlaying) {
        self.playButton.hidden = !self.playButton.hidden;
    }
}

- (void)hiddenSlideView:(BOOL)isHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.controlView.hidden = isHidden;
    });
}

- (void)dealloc
{
    if (self.isPlaying) {
        [self videoPlayerStop];
        self.videoPlayer = nil;
        self.playerLayer = nil;
    }
    NSLog(@"%s",__func__);
}

@end

//
//  MExportVideoViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/16.
//

#import "MExportVideoViewController.h"
#import "MQVideoExportManager.h"
#import "MVideoPlayerView.h"
#import <AVKit/AVKit.h>

@interface MExportVideoViewController ()

@property (nonatomic, assign) CGFloat fitRatio;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *processImgView;
@property (nonatomic, strong) UILabel *exportLabel;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, strong) MQVideoExportManager *videoExportManager;
@property (nonatomic, strong) CABasicAnimation *animation;

@property (nonatomic, strong) MVideoPlayerView *player;
@property (nonatomic, strong) AVPlayerViewController *avPlayer;

@end

@implementation MExportVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fitRatio = [self getFitLengthRatio];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    [self initAttribute];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect saftArea = Tation_safeArea;
    CGFloat xIphoneMargin = saftArea.origin.y;
    self.backBtn.frame = CGRectMake(32, xIphoneMargin, 40, 40);
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 100)/2, xIphoneMargin, 100, 40);
    
    self.processImgView.frame = CGRectMake(143 * self.fitRatio, CGRectGetHeight(self.view.frame) - 218, 32, 32);
    self.exportLabel.frame = CGRectMake(CGRectGetMaxX(self.processImgView.frame) + 8, CGRectGetMinY(self.processImgView.frame), 80, 32);
    self.remindLabel.frame = CGRectMake(0, CGRectGetMaxY(self.processImgView.frame) + 16, CGRectGetWidth(self.view.frame), 22);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self initVideoExportManagerParam];
    [self didClickExportVideoButton];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setFrame:CGRectMake(10, 20, 40, 40)];
    //[self.backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageNamed:@"Hohem.Tutorial.Back"] forState:UIControlStateNormal];
    self.backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    [self.backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 100)/2, 20, 100, 40);
    self.titleLabel.text = @"导出视频";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    
    self.processImgView = [[UIImageView alloc] init];
    [self.processImgView setImage:[UIImage imageNamed:@"HH.Me.watiing"]];
    [self.view addSubview:self.processImgView];
    
    self.exportLabel = [[UILabel alloc] init];
    self.exportLabel.text = @"导出中...";
    self.exportLabel.textColor = [UIColor whiteColor];
    self.exportLabel.font = [UIFont systemFontOfSize:16.0];
    self.exportLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:self.exportLabel];
    
    self.remindLabel = [[UILabel alloc] init];
    self.remindLabel.text = @"请勿关闭Hohem Joy APP或者关闭手机屏幕";
    self.remindLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    self.remindLabel.font = [UIFont systemFontOfSize:16.0];
    self.remindLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.remindLabel];
    
    self.backBtn.hidden = YES;
}

- (void)initAttribute
{
    self.videoExportManager = [[MQVideoExportManager alloc] init];
    
    self.player = [[MVideoPlayerView alloc] initWithFrame:CGRectMake(0, 150, 390, 219)];
    [self.view addSubview:self.player];
    self.player.playStartTimeValue = 0;
    self.player.keepLooping = NO;
    self.player.autoPlay = YES;
}

- (void)didClickBackButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)initVideoExportManagerParam
{
    //加载数据
    self.videoExportManager.clips = self.clips;
    self.videoExportManager.clipTimeRanges = self.clipTimeRanges;
    self.videoExportManager.transTimeArray = self.transTimeArray;
    self.videoExportManager.templateModel = self.templateModel;
}

- (void)didClickExportVideoButton
{
    //开始动画
    [self.processImgView.layer addAnimation:self.animation forKey:nil];
    
    [self.videoExportManager exporeResultVideo:@"TemplateVideoOne" completionHandler:^(NSURL * _Nonnull fileUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processImgView.layer removeAllAnimations];
            [self.processImgView setImage:[UIImage imageNamed:@"HH.Me.succeed"]];
            self.exportLabel.text = @"导出成功";
            self.remindLabel.text = @"已保存至系统相册";
            self.backBtn.hidden = NO;
            self.player.curPlayVideoUrl = fileUrl;
        });
        if (fileUrl) {
            NSLog(@"导出成功!!!!!!!!!!!!");
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                /*
                 In iOS 9 and later, it's possible to move the file into the photo library without duplicating
                 the file data. This avoids using double the disk space during save, which can make a difference
                 on devices with limited free disk space.
                */
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                options.shouldMoveFile = YES;

                PHAssetCreationRequest *creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                [creationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:fileUrl options:options];
            } completionHandler:^( BOOL success, NSError *error ) {
                if ( ! success ) {
                    NSLog( @"Could not save movie to photo library due to error: %@", error );
                }
                else{
                    NSLog(@"----保存渲染后的视频到相册成功----");
                }
            }];
        }
        
    }];
}

#pragma mark - 懒加载
- (CABasicAnimation *)animation
{
    if (!_animation) {
        _animation = [CABasicAnimation animation];
        _animation.keyPath = @"transform.rotation";
        _animation.duration = 1.0;
        _animation.fromValue = [NSNumber numberWithDouble:M_PI*0];
        _animation.toValue = [NSNumber numberWithDouble:M_PI*2];
        _animation.repeatCount = MAXFLOAT;
        _animation.removedOnCompletion = NO;
        _animation.fillMode = kCAFillModeForwards;
    }
    return _animation;
}

- (CGFloat)getFitLengthRatio{

    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return min / 390.0;
}

@end

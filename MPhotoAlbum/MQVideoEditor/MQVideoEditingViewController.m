//
//  MQVideoEditingViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/12.
//

#import "MQVideoEditingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MQVideoEditor.h"
#import "MVideoPreviewView.h"
#import "MVideoEditingManager.h"
#import "MediaAssetModel.h"
#import "MVideoEditEngine.h"
#import "VideoTemplateReader.h"
#import "LocalAssetModel.h"
#import "OptionalEditView.h"
#import "MQVariableCollectionView.h"
#import "MVideoEditView.h"
#import "MVideoToolControlView.h"
#import "MExportVideoViewController.h"

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MQVideoEditingViewController ()<VideoEditedDelegate,MPMediaPickerControllerDelegate>

//模板读取
@property (nonatomic, strong) EditTemplateModel *templateModel;
//数组模型存储数据
@property (nonatomic, strong) NSMutableArray *clips;
@property (nonatomic, strong) NSMutableArray *clipTimeRanges;
@property (nonatomic, strong) NSMutableArray *transTimeArray;
//视频预览界面
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *exportBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) MVideoPreviewView *videoPreviewView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UILabel *dragReminderLabel;
@property (nonatomic, strong) MVideoToolControlView *videoToolControlView;
@property (nonatomic, strong) UIButton *musicBtn;
//下面是视频编辑模块的测试
//@property (nonatomic, strong) OptionalEditView *optionalView;
@property (nonatomic, strong) MQVariableCollectionView *optionalView;
@property (nonatomic, strong) NSMutableArray <LocalAssetModel*>*mediaAssetArray; //用于后面的重排序

//并行队列多线程同时处理视频片段问题
@property (nonatomic, strong) dispatch_queue_t videosLoadQueue;
@property (nonatomic, strong) dispatch_group_t videosloadGroup;

@end

@implementation MQVideoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"mediaDic = %@",self.mediaDic);
    
    [self setupUI];
    
    [self initAttribute];
    
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect saftArea = Tation_safeArea;
    CGFloat xIphoneMargin = saftArea.origin.y;
    self.backBtn.frame = CGRectMake(32, xIphoneMargin, 40, 40);
    self.exportBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 64 - 16, xIphoneMargin + 1, 64, 38);
    self.titleLabel.frame = CGRectMake( (SCREEN_WIDTH - 100)/2, xIphoneMargin, 200, 40);
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    if (self.videoPreviewView) {
        self.videoPreviewView.frame = CGRectMake(0, 150, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9.0/16.0);
        self.videoToolControlView.frame = CGRectMake(16, CGRectGetMaxY(self.videoPreviewView.frame) + 16, CGRectGetWidth(self.view.frame) - 32, 18);
        self.playBtn.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 40)/2, CGRectGetMaxY(self.videoToolControlView.frame) + 16, 40, 40);
        self.videoToolControlView.hidden = NO;
        self.playBtn.hidden = NO;
    }
    else{
        self.videoToolControlView.hidden = YES;
        self.playBtn.hidden = YES;
    }
    self.optionalView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 69 - 64 - bottomDistValue, CGRectGetWidth(self.view.frame), 64);
    self.dragReminderLabel.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 30 - 22 - bottomDistValue, CGRectGetWidth(self.view.frame), 22);
    
    self.musicBtn.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 40)/2, CGRectGetMaxY(self.playBtn.frame) + 10, 40, 40);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self loadMediaDataToVideoPreviewView];
    if (!self.videoPreviewView) {
        //如果进入别的额界面后返回可以判断重新加载
        self.videoPreviewView = [[MVideoPreviewView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9.0/16.0)];
        self.videoPreviewView.delegate = self.videoToolControlView;
        self.videoPreviewView.autoPlay = YES; //默认打开就播放，可以加载视频
        [self.view addSubview:self.videoPreviewView];
        [self loadMediaDataToVideoPreviewView];
    }
    
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
    [self.backBtn addTarget:self action:@selector(btnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    
    self.exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.exportBtn setFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 64 - 16, 20 + 1, 64, 38)];
    [self.exportBtn setTitle:@"导出" forState:UIControlStateNormal];
    [self.exportBtn setBackgroundColor:[UIColor orangeColor]];
    //[confirmBtn setImage:[UIImage imageNamed:@"MQVideoEdit.Selected"] forState:UIControlStateNormal];
    [self.exportBtn addTarget:self action:@selector(didClickExportButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.exportBtn];
    self.exportBtn.layer.masksToBounds = YES;
    self.exportBtn.layer.cornerRadius = 19;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.frame = CGRectMake( (SCREEN_WIDTH - 100)/2, 20, 200, 40);
    self.titleLabel.text = @"视频剪辑模板";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    [self.view addSubview:self.titleLabel];
    
    self.videoPreviewView = [[MVideoPreviewView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9.0/16.0)];
    [self.view addSubview:self.videoPreviewView];
    self.videoToolControlView = [[MVideoToolControlView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.videoPreviewView.frame) + 16, CGRectGetWidth(self.view.frame) - 32, 18)];
    [self.view addSubview:self.videoToolControlView];
    self.videoPreviewView.delegate = self.videoToolControlView;
    __weak typeof(self) weakSelf = self;
    self.videoToolControlView.sliderChangeValueBlock = ^(NSTimeInterval pointInTime, BOOL finish) {
        [weakSelf.videoPreviewView setPlayerPause];
        [weakSelf.videoPreviewView setCurTotalTimeOffset: (pointInTime * 1000)];
        if (finish) {
            [weakSelf.videoPreviewView startToPlay];
        }
    };
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 40)/2, self.videoPreviewView.center.y - 20, 40, 40)];
    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Pause"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    _playBtn.selected = YES; //
    //
    //__weak typeof(self) weakSelf = self;
    self.optionalView = [[MQVariableCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, CGRectGetWidth(self.view.frame), 64)];
    self.optionalView.mediaDic = [NSMutableDictionary dictionaryWithDictionary:self.mediaDic];
    self.optionalView.delegate = self;
    [self.view addSubview:self.optionalView];
    
    self.dragReminderLabel = [[UILabel alloc] init];
    self.dragReminderLabel.text = @"长按拖动可调整素材顺序";
    self.dragReminderLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    self.dragReminderLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.dragReminderLabel];
    
    
    self.musicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.musicBtn setTitle:@"音乐" forState:UIControlStateNormal];
    [self.musicBtn addTarget:self action:@selector(didClickItuneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.musicBtn];
}

- (void)initAttribute
{
    //初始化并行队列
    self.videosLoadQueue = dispatch_queue_create("VideoEditsPQueue", 0);
    self.videosloadGroup = dispatch_group_create(); //控制队列执行完成度，确认所有队列都执行完才进行下一个阶段
    
    //MARK:获取模板数据
    VideoTemplateReader *videoTemplateReader = [[VideoTemplateReader alloc] init];
    self.templateModel = [videoTemplateReader getVideoTemplateParameter:CustomVideoTemplateType_StoryA];
    NSLog(@"打印模板的数据%@",_templateModel);
    
    
    //MARK:加载媒体数据（应该确认顺序???）
    for (int i = 0; i < self.templateModel.amount; i ++) {
        //获取key
        dispatch_group_enter(self.videosloadGroup);
        dispatch_group_async(self.videosloadGroup, self.videosLoadQueue, ^{
            
            NSString *key = [NSString stringWithFormat:@"%d",i];
            LocalAssetModel *model = [self.mediaDic objectForKey:key];
            if (model.propertyType == PHAssetMediaTypeVideo) {
                [self getVideoFromPHAsset:model.asset toMediaModel:model Complete:^{
                    NSLog(@"加载数据--%@",key);
                    //获取key
                    //[self.clips addObject:asset];
                    dispatch_group_leave(self.videosloadGroup);
                }];
            }
            else{
                //设置图片信息
                AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BlankVideo" ofType:@"mp4"]]];
                model.propertyAssetURL = asset;
                EditUnitModel *editUnitModel = self.templateModel.scripts[i];
                editUnitModel.mediaType = MQMediaTypePhoto;
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.synchronous = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeNone;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                CGFloat pixelWidth = model.asset.pixelWidth;
                CGFloat pixelHeight = model.asset.pixelHeight;
                CGSize targetSize = CGSizeMake(pixelWidth, pixelHeight);
                [[PHCachingImageManager defaultManager] requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    
                    editUnitModel.image = result;
                    dispatch_group_leave(self.videosloadGroup);
                }];
            }
            
        });
        
    }
    
    dispatch_group_notify(self.videosloadGroup, self.videosLoadQueue, ^{
        NSMutableArray *validClipTimeRanges = [NSMutableArray array];
        NSArray *videoParamArray = self.templateModel.scripts;
        for (int i = 0; i < self.templateModel.amount; i++) {
            
            EditUnitModel *model = (EditUnitModel *)videoParamArray[i];
            CMTime start = CMTimeMake( model.startTime * 1000, 1000);
            CMTime duration = CMTimeMake( model.mediaDuration * 1000, 1000);
            [validClipTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(start, duration)]];
            
            //转场时间
            [self.transTimeArray addObject:[NSNumber numberWithFloat:model.transDuration]];
        }
        self.clipTimeRanges = validClipTimeRanges;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self loadMediaDataToVideoPreviewView];
            
            [self loadDataToOptionalView];
        });
        
    });
}

- (void)loadDataToOptionalView
{
    //底部拖动选择栏
    __weak typeof(self) weakSelf = self;
    self.optionalView.mediaAssetArray = self.mediaAssetArray;
    self.optionalView.clipTimeRanges = self.clipTimeRanges;
    self.optionalView.templateModelArray = self.templateModel.scripts;
    [self.optionalView reloadData];
    self.optionalView.updateBlock = ^{
        [weakSelf.videoPreviewView stopPlayAndDeletePlayTtem];
        [weakSelf reloadVideoClipsArray];
        weakSelf.videoPreviewView.autoPlay = NO;
        //加载视频数据
        weakSelf.videoPreviewView.clips = weakSelf.clips;
        weakSelf.videoPreviewView.clipTimeRanges = weakSelf.clipTimeRanges;
        weakSelf.videoPreviewView.transTimeArray = weakSelf.transTimeArray;
        weakSelf.videoPreviewView.templateModel = weakSelf.templateModel;
        [weakSelf.videoPreviewView initAVPlayerAndLoadVideoData];
        [weakSelf.videoToolControlView resetVideoTool];
    };
}

- (void)loadMediaDataToVideoPreviewView
{
    //获取媒体数组
    [self.clips removeAllObjects];
    for (int i = 0; i < self.templateModel.amount; i ++) {
        
        //获取key
        NSString *key = [NSString stringWithFormat:@"%d",i];
        LocalAssetModel *model = [self.mediaDic objectForKey:key];
        if (model.propertyAssetURL) {
            [self.clips addObject:model.propertyAssetURL];
        }
        else{
            NSLog(@"获取视频原地址为NULL");
        }
        
        [self.mediaAssetArray addObject:model];
    }
    
    //加载视频数据
    self.videoPreviewView.autoPlay = YES; //默认打开就播放，可以加载视频
    self.videoPreviewView.clips = self.clips;
    self.videoPreviewView.clipTimeRanges = self.clipTimeRanges;
    self.videoPreviewView.transTimeArray = self.transTimeArray;
    self.videoPreviewView.templateModel = self.templateModel;
    [self.videoPreviewView initAVPlayerAndLoadVideoData];
}

- (void)reloadVideoClipsArray
{
    [self.clips removeAllObjects];
    //获取媒体数组
    for (int i = 0; i < self.mediaAssetArray.count; i ++) {

        LocalAssetModel *model = self.mediaAssetArray[i];
        [self.clips addObject:model.propertyAssetURL];
    }
    
    NSMutableArray *validClipTimeRanges = [NSMutableArray array];
    NSArray *videoParamArray = _templateModel.scripts;
    for (int i = 0; i < _templateModel.amount; i++) {
        
        EditUnitModel *model = (EditUnitModel *)videoParamArray[i];
        CMTime start = [self.clipTimeRanges[i] CMTimeRangeValue].start;
        CMTime duration = CMTimeMake( model.mediaDuration * 1000, 1000);
        [validClipTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(start, duration)]];
        
        //转场时间
        [self.transTimeArray addObject:[NSNumber numberWithFloat:model.transDuration]];
    }
    self.clipTimeRanges = validClipTimeRanges;
}

//MARK:---------------特定功能测试---------------
- (void)testSpecialFunction
{
    //MARK:测试设置回放区间supportPlaybackInSection
    CMTime beginTime = CMTimeMake(3800, 1000);
    CMTime endTime = CMTimeMake(5100, 1000);
    [self.videoPreviewView supportPlaybackInSection:NO beginTime:beginTime endTime:endTime];
}

#pragma mark - 获取视频数据
- (void)getVideoFromPHAsset:(PHAsset *)asset toMediaModel:(LocalAssetModel *)model Complete:(dispatch_block_t)result {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
 
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        NSURL *fileUrl = [NSURL fileURLWithPath:PATH_MOVIE_FILE];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:fileUrl
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:[fileUrl path]]) {
                NSLog(@"获取视频路径成功!!!!!!");
                AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
                model.propertyAssetURL = asset;
                result();
            }
            //[[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE  error:nil];
            
        }];
    }
}



#pragma mark - 按钮事件
- (void)btnReturn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playVideo:(UIButton*)btn
{
    btn.selected = !btn.selected;
    
    [self.videoPreviewView togglePlayPause:nil];
}

- (void)didClickExportButton:(UIButton *)btn
{
    //停止播放
    [self.videoPreviewView stopPlayAndDeletePlayTtem];
    [self.videoPreviewView removeFromSuperview];
    self.videoPreviewView = nil;
    
    MExportVideoViewController *exportVideoViewController = [[MExportVideoViewController alloc] init];
    exportVideoViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    //加载视频数据
    exportVideoViewController.clips = self.clips;
    exportVideoViewController.clipTimeRanges = self.clipTimeRanges;
    exportVideoViewController.transTimeArray = self.transTimeArray;
    exportVideoViewController.templateModel = self.templateModel;
    [self.navigationController pushViewController:exportVideoViewController animated:YES];
}

#pragma mark - 系统音乐Itunes
- (void)didClickItuneButton:(UIButton *)btn
{
    MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mpc.delegate = self;
    mpc.allowsPickingMultipleItems = NO;
    [self presentViewController:mpc animated:YES completion:nil];
}
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    for (MPMediaItem *song in [mediaItemCollection items]) {
        [self parsingMediaItem:song];
    }
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
}

//取消选取
- (void)mediapickerdidcancel:(MPMediaPickerController *)mediapicker
{
    //解除媒体选择器器
    [mediapicker dismissViewControllerAnimated:YES completion:nil];
}

//解析歌曲
- (void)parsingMediaItem:(MPMediaItem *)song
{
    NSString *name = [song valueForProperty:MPMediaItemPropertyTitle];
    NSString *url = [song valueForProperty:MPMediaItemPropertyAssetURL];
    NSString *songer = [song valueForProperty:MPMediaItemPropertyArtist];
    NSTimeInterval playDuration = [[song valueForProperty:MPMediaItemPropertyPlaybackDuration] doubleValue];
    NSString *time;
    if ((int)playDuration % 60 < 10) {
        time = [NSString stringWithFormat:@"%d:0%d",(int)playDuration/60,(int)playDuration%60];
    }
    else{
        time = [NSString stringWithFormat:@"%d:%d",(int)playDuration/60,(int)playDuration%60];
    }
    
    MPMediaItemArtwork *artwork = [song valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:CGSizeMake(50, 50)];
    NSLog(@"========解析结束========");
}
#pragma mark - VideoEditedDelegate
- (void)startToEditSingleVideoWithIndex:(NSInteger)index
{
    [self.videoPreviewView setPlayerPause];
    NSLog(@"开始编辑视频，选取时间段");
    MVideoEditView *videoEditView = [[MVideoEditView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) withMediaAssetArray:self.mediaAssetArray mediaIndex:index];
    videoEditView.clipTimeRanges = self.clipTimeRanges;
    [videoEditView updateInterfaceAndData];
    videoEditView.updateBlock = ^{
        [self.videoPreviewView stopPlayAndDeletePlayTtem];
        //加载视频数据
        self.videoPreviewView.clips = self.clips;
        self.videoPreviewView.clipTimeRanges = self.clipTimeRanges;
        self.videoPreviewView.transTimeArray = self.transTimeArray;
        self.videoPreviewView.templateModel = self.templateModel;
        [self.videoPreviewView initAVPlayerAndLoadVideoData];
    };
    
    [self.view addSubview:videoEditView];
}

#pragma mark - 懒加载
- (NSMutableArray *)clips
{
    if (!_clips) {
        _clips = [[NSMutableArray alloc] init];
    }
    return _clips;
}

- (NSMutableArray *)clipTimeRanges
{
    if (!_clipTimeRanges) {
        _clipTimeRanges = [[NSMutableArray alloc] init];
    }
    return _clipTimeRanges;
}

- (NSMutableArray *)transTimeArray
{
    if (!_transTimeArray) {
        _transTimeArray = [[NSMutableArray alloc] init];
    }
    return _transTimeArray;
}

- (NSMutableArray <LocalAssetModel*>*)mediaAssetArray
{
    if (!_mediaAssetArray) {
        _mediaAssetArray = [NSMutableArray array];
    }
    return  _mediaAssetArray;
}

- (void)deleteMVideoPreivewView
{
    [self.videoPreviewView stopPlayAndDeletePlayTtem];
    self.videoPreviewView = nil;
}

- (void)dealloc
{
    [self deleteMVideoPreivewView];
    NSLog(@"%s",__func__);
}

@end

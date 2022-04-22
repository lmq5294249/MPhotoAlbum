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
#import "MQVideoEditor.h"
#import "MVideoPreviewView.h"
#import "MVideoEditingManager.h"
#import "MediaAssetModel.h"
#import "MVideoEditEngine.h"
#import "VideoTemplateReader.h"
#import "LocalAssetModel.h"
#import "OptionalEditView.h"
#import "MQVariableCollectionView.h"

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MQVideoEditingViewController ()

//模板读取
@property (nonatomic, strong) EditTemplateModel *templateModel;
//数组模型存储数据
@property (nonatomic, strong) NSMutableArray *clips;
@property (nonatomic, strong) NSMutableArray *clipTimeRanges;
@property (nonatomic, strong) NSMutableArray *transTimeArray;
//视频预览界面
@property (nonatomic, strong) MVideoPreviewView *videoPreviewView;
@property (nonatomic, strong) UIButton *playBtn;

//下面是视频编辑模块的测试
//@property (nonatomic, strong) OptionalEditView *optionalView;
@property (nonatomic, strong) MQVariableCollectionView *optionalView;
@property (nonatomic, strong) NSMutableArray <LocalAssetModel*>*mediaAssetArray; //用于后面的重排序

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

    self.videoPreviewView.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9.0/16.0);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadMediaDataToVideoPreviewView];
    
    //底部拖动选择栏
    self.optionalView.mediaAssetArray = self.mediaAssetArray;
    [self.optionalView reloadData];
    
    
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(10, 20, 60, 40)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    [backBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(btnReturn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.frame = CGRectMake( (SCREEN_WIDTH - 100)/2, 20, 200, 40);
    titleLabel.text = @"视频剪辑模板";
    titleLabel.textColor = [UIColor purpleColor];
    titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    [self.view addSubview:titleLabel];
    
    self.videoPreviewView = [[MVideoPreviewView alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 9.0/16.0)];
    [self.view addSubview:self.videoPreviewView];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 40)/2, CGRectGetMaxY(self.videoPreviewView.frame) + 40, 40, 40)];
    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Play"] forState:UIControlStateNormal];
    [_playBtn setImage:[UIImage imageNamed:@"MQVideoPlayer.Pause"] forState:UIControlStateSelected];
    [_playBtn addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBtn];
    
    //
    __weak typeof(self) weakSelf = self;
    self.optionalView = [[MQVariableCollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, CGRectGetWidth(self.view.frame), 80)];
    self.optionalView.mediaDic = [NSMutableDictionary dictionaryWithDictionary:self.mediaDic];
    [self.view addSubview:self.optionalView];
    [self.optionalView reloadData];
}

- (void)initAttribute
{
    //MARK:获取模板数据
    VideoTemplateReader *videoTemplateReader = [[VideoTemplateReader alloc] init];
    self.templateModel = [videoTemplateReader getVideoTemplateParameter:CustomVideoTemplateType_StoryA];
    NSLog(@"打印模板的数据%@",_templateModel);
    
    //MARK:加载媒体数据（应该确认顺序???）
    for (int i = 0; i < self.templateModel.amount; i ++) {
        //获取key
        NSString *key = [NSString stringWithFormat:@"%d",i];
        LocalAssetModel *model = [self.mediaDic objectForKey:key];
        if (model.propertyType == PHAssetMediaTypeVideo) {
            [self getVideoFromPHAsset:model.asset toMediaModel:model Complete:^{
                NSLog(@"加载数据--%@",key);
                //获取key
                //[self.clips addObject:asset];
                
            }];
        }
        else{
            //设置图片信息
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BlankVideo" ofType:@"mp4"]]];
            model.propertyAssetURL = asset;
            EditUnitModel *editUnitModel = self.templateModel.scripts[i];
            editUnitModel.mediaType = MQMediaTypePhoto;
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
            options.synchronous = YES;
            options.resizeMode = PHImageRequestOptionsResizeModeNone;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            CGFloat pixelWidth = model.asset.pixelWidth;
            CGFloat pixelHeight = model.asset.pixelHeight;
            CGSize targetSize = CGSizeMake(pixelWidth, pixelHeight);
            [[PHCachingImageManager defaultManager] requestImageForAsset:model.asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                editUnitModel.image = result;
            }];
        }
    }
    
    NSMutableArray *validClipTimeRanges = [NSMutableArray array];
    NSArray *videoParamArray = _templateModel.scripts;
    for (int i = 0; i < _templateModel.amount; i++) {
        
        EditUnitModel *model = (EditUnitModel *)videoParamArray[i];
        CMTime start = CMTimeMake( model.startTime * 1000, 1000);
        CMTime duration = CMTimeMake( model.mediaDuration * 1000, 1000);
        [validClipTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(start, duration)]];
        
        //转场时间
        [self.transTimeArray addObject:[NSNumber numberWithFloat:model.transDuration]];
    }
    self.clipTimeRanges = validClipTimeRanges;
}

- (void)loadMediaDataToVideoPreviewView
{
    //获取媒体数组
    for (int i = 0; i < self.templateModel.amount; i ++) {
        
        //获取key
        NSString *key = [NSString stringWithFormat:@"%d",i];
        LocalAssetModel *model = [self.mediaDic objectForKey:key];
        [self.clips addObject:model.propertyAssetURL];
        
        [self.mediaAssetArray addObject:model];
    }
    
    //加载视频数据
    self.videoPreviewView.clips = self.clips;
    self.videoPreviewView.clipTimeRanges = self.clipTimeRanges;
    self.videoPreviewView.transTimeArray = self.transTimeArray;
    self.videoPreviewView.templateModel = self.templateModel;
    [self.videoPreviewView initAVPlayerAndLoadVideoData];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playVideo:(UIButton*)btn
{
    btn.selected = !btn.selected;
    
    [self.videoPreviewView togglePlayPause:nil];
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

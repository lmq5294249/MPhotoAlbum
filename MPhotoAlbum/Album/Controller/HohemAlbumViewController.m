//
//  HohemAlbumViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/14.
//

#import "HohemAlbumViewController.h"
#import "HohemShowAlbumViewController.h"
#import "HohemAlbumPlayViewController.h"
#import "TationDeviceManager.h"
#import "MSlidePageView.h"
#import "PHPhotoLibraryManage.h"
#import "LocalAssetModel.h"
#import "HHMediaCell.h"
#import "OptionalEditView.h"
#import "MQVideoEditingViewController.h"
#define baseMargin 6.0

static NSString *const cellId = @"HHMediaCellID";

@interface HohemAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MSlidePageDelegate>

@property (nonatomic, assign) HohemAlbumViewController_ShowType showType;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*dataFetchResult;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*photoFetchResult;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*videoFetchResult;

@property (nonatomic, strong) NSMutableDictionary *videoDic;
@property (nonatomic, strong) NSMutableDictionary *photoDic;
@property (nonatomic, strong) NSMutableArray *photoKeyArr;
@property (nonatomic, strong) NSMutableArray *videoKeyArr;

@property (nonatomic, strong) NSMutableDictionary *mediaModelDataDic;
@property (nonatomic, strong) NSMutableArray *mediaModelDataArr;
@property (nonatomic, strong) NSMutableArray *mediaModelArr;
@property (nonatomic, strong) NSMutableArray *fileNameArray;

@property (nonatomic, strong) NSMutableArray *selectItemArr; //暂时未使用
@property (nonatomic, strong) NSMutableArray *deleteArray; //删除数组

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *labelImageVIew;
@property (nonatomic, strong) MSlidePageView *slidePageView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) HohemAlbum_Mode albumMode; //相册模式
@property (nonatomic, assign) BOOL isEnableEdit;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UIButton *deletedBtn;
@property (nonatomic, strong) UIButton *videoEditorBtn;
@property (nonatomic, strong) UIButton *editedBtn;
@property (nonatomic, strong) UIButton *nextStepBtn;

@property (nonatomic, strong) UILabel *selectedLabel;

@property (nonatomic, assign) CGFloat fitRatio;

@property (nonatomic, strong) UIView *bottomView;

//下面是视频编辑模块的测试
@property (nonatomic, strong) OptionalEditView *optionalView;

@end

@implementation HohemAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self requestAuthorization];
    
    //获取UI适应屏幕的参数
    self.fitRatio = [self getFitLengthRatio];
    
    [self initAttribute];
    
    [self setUpUI];
    
    //APP进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIApplicationWillEnterForegroundNotificationWithNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)requestAuthorization
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusDenied) {
            NSLog(@"status:%ld",(long)status);
        } else if (status == PHAuthorizationStatusNotDetermined) {
            NSLog(@"status:%ld",(long)status);
        } else if (status == PHAuthorizationStatusRestricted) {
            NSLog(@"status:%ld",(long)status);
        } else if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"status:%ld",(long)status);
            [self initAttribute];
        }
    }];
}

- (void)initAttribute {
    
    self.showType = HohemAlbumViewController_ShowType_Video;
    
    //__weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //读取数据
        [self getPHAssetDateFromePhotoLibrary];
        self.showType = HohemAlbumViewController_ShowType_Video;
        //判断是否是以日期为点进入相册
        if (self.showType == HohemAlbumViewController_ShowType_Photo) {
            
            [self getAllDocumentDate:@"Image"];

        }else{
            
            [self getAllDocumentDate:@"Video"];

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
    
}

- (void)setUpUI {
    
    //标题栏
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 55)];
    self.titleView.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    [self.view addSubview:self.titleView];
    //标题-hohem
    self.labelImageVIew = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - 180)/2, 27, 180, 16)];
    [self.labelImageVIew setImage:[UIImage imageNamed:@"Hohem.Joy.log"]];
    self.labelImageVIew.contentMode = UIViewContentModeScaleAspectFit;
//    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 44)];
//    titlelabel.text = @"Hohem";
//    titlelabel.textAlignment = NSTextAlignmentCenter;
//    [self.labelImageVIew addSubview:titlelabel];
    [self.titleView addSubview:self.labelImageVIew];
    //返回按钮
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"Hohem_Contact_back"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(didClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.backBtn];
    if (self.hiddenBackBtn) self.backBtn.hidden = YES;
    //视频编辑按钮
    self.editedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editedBtn setImage:[UIImage imageNamed:@"Hohem_Album_ editing"] forState:UIControlStateNormal];
    [self.editedBtn addTarget:self action:@selector(didClickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.editedBtn];
    //多选按钮
    self.selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectedBtn setImage:[UIImage imageNamed:@"Hohem_Album_ unselected"] forState:UIControlStateNormal];
    [self.selectedBtn setImage:[UIImage imageNamed:@"Hohem_Album_selected"] forState:UIControlStateSelected];
    [self.selectedBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.selectedBtn addTarget:self action:@selector(didClickSelectedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.selectedBtn];
    //选中数量显示
    self.selectedLabel = [[UILabel alloc] init];
    self.selectedLabel.text = @"(0)";
    self.selectedLabel.textAlignment = NSTextAlignmentRight;
    self.selectedLabel.textColor = [UIColor whiteColor];
    //[self.titleView addSubview:self.selectedLabel];
    self.selectedLabel.hidden = YES;
    
    CGFloat btnWidthValue = (CGRectGetWidth(self.view.frame) - 20*self.fitRatio)/5;
    //视频图片模块滑动界面
    self.slidePageView = [[MSlidePageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleView.frame), CGRectGetWidth(self.view.frame), 52)];
    ViewConfig *config = [[ViewConfig alloc] init];
    config.buttonLayoutType = ButtonLayoutTypeCustom;
    config.numberOfBtns = 2;
    config.stringArray = [NSMutableArray arrayWithArray:@[@"视频",@"照片"]];
    config.btnSize = CGSizeMake(btnWidthValue, 52);
    config.realBtnHeight = 38; //实际看到的高度
    config.waveWidth = 124 * self.fitRatio;
    config.marginOfBtnValue = 16 *_fitRatio;
    config.cornerRadius = 8;
    config.sliderFillColor = [UIColor whiteColor];
    config.selectIndex = 0;
    config.shadowBounds = YES;
    config.textFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    self.slidePageView.viewConfig = config;
    self.slidePageView.delegate = self;
    [self.view addSubview:self.slidePageView];

    //collectionView
    [self.collectionView registerClass:[HHMediaCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
    
    //删除按钮
    self.deletedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deletedBtn setImage:[UIImage imageNamed:@"Hohem_Album_delete_H"] forState:UIControlStateNormal];
    [self.deletedBtn setTitle:@"S" forState:UIControlStateNormal];
    [self.deletedBtn addTarget:self action:@selector(didClickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.slidePageView addSubview:self.deletedBtn]; //添加在滑动栏???
    
    //MARK:选中底部删除栏
    self.bottomView = [[UIView alloc] init];
    self.bottomView.hidden = YES;
    self.deletedBtn.hidden = YES;
    if (self.hiddenBackBtn) {
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.bottomView];
    }else{
        
        [self.view addSubview:self.bottomView];
    }
    
    //[self.bottomView addSubview:self.selectedLabel];
    [self.view addSubview:self.deletedBtn];
    
    __weak typeof(self) weakSelf = self;
    self.optionalView = [[OptionalEditView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, CGRectGetWidth(self.view.frame), 80)];
    self.optionalView.maxcount = 4;
    self.optionalView.deleteOptionalModelBlock = ^{
        weakSelf.nextStepBtn.hidden = YES;
    };
    [self.view addSubview:self.optionalView];
    
    //视频剪辑下一步按钮
    self.nextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextStepBtn setTitle:@"下一步" forState:UIControlStateNormal];
    self.nextStepBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [self.nextStepBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [self.nextStepBtn addTarget:self action:@selector(didClickNextStepBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.slidePageView addSubview:self.nextStepBtn];
    self.nextStepBtn.hidden = YES;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    //设置View布局
    CGRect saftArea = Tation_safeArea;
    CGFloat xIphoneMargin = saftArea.origin.y;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = 56;
    
    self.titleView.frame = CGRectMake(0, 0, w, h + xIphoneMargin);
    
    self.labelImageVIew.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 180)/2, 18 + xIphoneMargin, 180, 16);
    
    self.selectedBtn.frame = CGRectMake(w - (32 + 44)* self.fitRatio, 4 + xIphoneMargin, 44* self.fitRatio, 44* self.fitRatio);
    self.backBtn.frame = CGRectMake( 32* self.fitRatio, 4 + xIphoneMargin, 44* self.fitRatio, 44* self.fitRatio);
    //以标题图为中心点对准下面布局左右两边的控件高度
    CGPoint logoViewCenter = self.labelImageVIew.center;
    self.selectedBtn.center = CGPointMake(self.selectedBtn.center.x, logoViewCenter.y);
    self.backBtn.center = CGPointMake(self.backBtn.center.x, logoViewCenter.y);
    //编辑位置在左边返回处
    self.editedBtn.frame = CGRectMake( 32* self.fitRatio * 2 + 44* self.fitRatio, 4 + xIphoneMargin, 44* self.fitRatio, 44* self.fitRatio);
    self.editedBtn.center = CGPointMake(self.editedBtn.center.x, logoViewCenter.y);
    
    self.slidePageView.frame = CGRectMake(0, CGRectGetMaxY(self.titleView.frame) - 10, CGRectGetWidth(self.view.frame), 52);
    
    CGFloat blankSpacesValue = 18.0;
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.slidePageView.frame) + blankSpacesValue, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.slidePageView.frame) - 10);
    
    h = CGRectGetHeight(self.view.frame);
    self.bottomView.frame = CGRectMake(0, h - 92 - bottomDistValue, w, 92 + bottomDistValue);
    self.deletedBtn.frame = CGRectMake((w - 66 * self.fitRatio)/2, CGRectGetMinY(self.bottomView.frame) + (92 + bottomDistValue - 66 * self.fitRatio)/2 - 4, 66 * self.fitRatio, 66 * self.fitRatio);
    self.selectedLabel.frame = CGRectMake(CGRectGetMinX(self.deletedBtn.frame) - 60 - 4, (48  - 24)/2 + bottomDistValue/4, 60, 24);
    
    self.nextStepBtn.frame = CGRectMake(CGRectGetWidth(self.slidePageView.frame)- 100, 0, 100, CGRectGetHeight(self.slidePageView.frame));
    
    //bottomView底部层添加渐变层
    self.bottomView.alpha = 1.0;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bottomView.frame), CGRectGetHeight(self.bottomView.frame));
    gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0].CGColor,(__bridge id)[UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:0.72].CGColor,(__bridge id)[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:0.00].CGColor];
    gradientLayer.locations = @[@(0),@(0.4f),@(1.0f)];
    [self.bottomView.layer addSublayer:gradientLayer];
    
}

- (void)UIApplicationWillEnterForegroundNotificationWithNotification:(NSNotification *)notification {
    
    if (![self isEqual:[Tation_kSharedToolsManager getCurViewController]]) return;
    //读取数据
    [self getPHAssetDateFromePhotoLibrary];
    //判断是否是以日期为点进入相册
    if (self.showType == HohemAlbumViewController_ShowType_Photo) {
        
        [self getAllDocumentDate:@"Image"];

    }else{
        
        [self getAllDocumentDate:@"Video"];

    }
    [self.collectionView reloadData];
}

//刷新相册源数据
- (void)refreshPhotoDataSource {
    
    self.photoFetchResult = [self getPHAssetFromSystem:HohemAlbumViewController_ShowType_Photo];
    self.videoFetchResult = [self getPHAssetFromSystem:HohemAlbumViewController_ShowType_Video];
    if (self.showType == HohemAlbumViewController_ShowType_Video) {

        self.dataFetchResult = self.videoFetchResult;
    }else{

        self.dataFetchResult = self.photoFetchResult;
    }
}

- (PHFetchResult <PHAsset *>*)getPHAssetFromSystem:(HohemAlbumViewController_ShowType)showType {
    
    PHFetchOptions *options = [[PHFetchOptions alloc]init];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    options.sortDescriptors = @[descriptor];
    switch (showType) {
        case HohemAlbumViewController_ShowType_Photo:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
            break;
        case HohemAlbumViewController_ShowType_Video:
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
            break;
        default:
            break;
    }
   
    return [PHAsset fetchAssetsWithOptions:options];
}

-(void)getPHAssetDateFromePhotoLibrary{
    PHPhotoLibraryManage *assets = [[PHPhotoLibraryManage alloc] init];
    
    [assets ergodicPhotoAlbumWithPhotoName:@"Hohem"];
    //字典的key是日期,value是文件的数组
    _videoDic = [NSMutableDictionary dictionaryWithDictionary:assets.dic[@"video"]];
    _photoDic = [NSMutableDictionary dictionaryWithDictionary:assets.dic[@"photo"]];
    //获取所有的key值进行排序
    NSMutableArray * photoKeyArr = [NSMutableArray arrayWithArray:[[_photoDic allKeys]sortedArrayUsingSelector:@selector(compare:)]];
    NSEnumerator *enumerator_photo = [photoKeyArr reverseObjectEnumerator];
    _photoKeyArr =[NSMutableArray arrayWithArray: [enumerator_photo allObjects]];
    
    NSMutableArray * videoKeyArr = [NSMutableArray arrayWithArray:[[_videoDic allKeys]sortedArrayUsingSelector:@selector(compare:)]];
    NSEnumerator *enumerator_video = [videoKeyArr reverseObjectEnumerator];
    _videoKeyArr =[NSMutableArray arrayWithArray: [enumerator_video allObjects]];
}

//获取文件列表的时间列表转为数据便于命名
-(void)getAllDocumentDate:(NSString *)mediaDateType{
    //将类型对应的时间列表赋给fileNameArray
    if (_mediaModelDataArr == nil) {
        _mediaModelDataArr = [NSMutableArray array];
    }else{
        //每次加载不同类型的数据，需要清除原本的数据
        [_mediaModelDataArr removeAllObjects];
    }
    if ([mediaDateType isEqualToString:@"Image"]) {
        //图片列表
        self.fileNameArray = _photoKeyArr;
        _mediaModelDataDic = _photoDic;
        NSInteger dateArrCount = _photoKeyArr.count;
        for (int i = 0; i < dateArrCount; i++) {
            NSString *propertyDate = _photoKeyArr[i];
            [_mediaModelDataArr addObject:[_photoDic valueForKey:propertyDate]];
        }
        
    }else{
        //视频列表
        self.fileNameArray = _videoKeyArr;
        _mediaModelDataDic = _videoDic;
        NSInteger dateArrCount = _videoKeyArr.count;
        for (int i = 0; i < dateArrCount; i++) {
            NSString *propertyDate = _videoKeyArr[i];
            [_mediaModelDataArr addObject:[_videoDic valueForKey:propertyDate]];
        }
    }
    [self AddAllTheFileIntoOneMediaArray];
}

-(void)AddAllTheFileIntoOneMediaArray{
    if (self.mediaModelArr == nil) {
        self.mediaModelArr = [NSMutableArray array];
    }else{
        //每次加载不同类型的数据，需要清除原本的数据
        [self.mediaModelArr removeAllObjects];
    }
    for (int i = 0; i < self.mediaModelDataDic.count; i++) {
        NSMutableArray *mediaTempArr = [self.mediaModelDataDic valueForKey:self.fileNameArray[i]];
        for (LocalAssetModel *modelTemp in mediaTempArr) {
            [self.mediaModelArr addObject:modelTemp];
        }
    }
}

-(void)getAllFileFromDate:(NSString *)dateString{
    //将类型对应的时间列表赋给fileNameArray
    if (self.mediaModelDataArr == nil) {
        self.mediaModelDataArr = [NSMutableArray array];
    }else{
        //每次加载不同类型的数据，需要清除原本的数据
        [self.mediaModelDataArr removeAllObjects];
    }
    if (self.showType == HohemAlbumViewController_ShowType_Photo) {
        //图片列表
        if ([_photoKeyArr containsObject:dateString]) {
            [self.mediaModelDataArr addObject:[_photoDic valueForKey:dateString]];
        }
        else{
            self.mediaModelDataArr = nil;
        }
    }else{
        //视频列表
        if ([_videoKeyArr containsObject:dateString]) {
            [self.mediaModelDataArr addObject:[_videoDic valueForKey:dateString]];
        }
        else{
            self.mediaModelDataArr = nil;
        }
    }
    if (self.mediaModelDataArr == nil) {
        self.mediaModelArr = nil;
    }else{
        self.mediaModelArr = self.mediaModelDataArr[0];
    }

}

#pragma mark - User Action
- (void)didClickBackBtn:(UIButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickEditBtn:(UIButton *)btn {
    
    self.albumMode = HohemAlbum_Mode_VideoEditor;
}

- (void)didClickSelectedBtn:(UIButton *)btn {
    
    btn.selected = !btn.selected;
//    self.bottomView.hidden = !btn.selected;

    if (btn.selected) {
        self.albumMode = HohemAlbum_Mode_DeleteItems;
        //self.selectedLabel.hidden = NO;
        self.bottomView.hidden = NO;
        self.deletedBtn.hidden = NO;
    }
    else{
        self.albumMode = HohemAlbum_Mode_Viewer;
        for (LocalAssetModel *model in self.mediaModelArr) {
            model.isSelect = NO;
        }
        //self.selectedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"(%d)", nil),0];
        //self.selectedLabel.hidden = YES;
        self.bottomView.hidden = YES;
        self.deletedBtn.hidden = YES;
    }
    
    [self.selectItemArr removeAllObjects];
    [self.collectionView reloadData];
}

- (void)didClickChooseBtn:(UIButton *)btn {
    
    //if (btn.selected == YES) return;
    
    //[self.selectedMtArr removeAllObjects];
//    if ([btn isEqual:self.photoBtn]) {
//
//        self.showType = HohemAlbumViewController_ShowType_Photo;
//
//        self.dataFetchResult = self.photoFetchResult;
//    }else if ([btn isEqual:self.videoBtn]) {
//
//        self.showType = HohemAlbumViewController_ShowType_Video;
//
//        self.dataFetchResult = self.videoFetchResult;
//    }
    
    [self.collectionView reloadData];
}

- (void)didClickDeleteBtn:(UIButton *)btn {
    
    //将所选数组里面的数据添加到删除数组里面
    [self.deleteArray removeAllObjects];
    
    for(LocalAssetModel *model in self.mediaModelArr)
    {
        if(model.isSelect == YES)
        {
            [self.deleteArray addObject:model.asset];
        }
    }
    //调用系统删除接口
    if (self.deleteArray.count <= 0) {
        return;
    }
    //删除当前图片
    //__weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:self.deleteArray];
    }completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Error: %@", error);
        if (success) {
            //重新加载数据
            [self getPHAssetDateFromePhotoLibrary];
            if (self.showType == HohemAlbumViewController_ShowType_Photo) {
                [self getAllDocumentDate:@"Image"];
            }else{
                [self getAllDocumentDate:@"Video"];
            }
            //重加载视图同步主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
                if (self.albumMode == HohemAlbum_Mode_DeleteItems) {

                    self.albumMode = HohemAlbum_Mode_Viewer;
                }
                self.selectedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"(%d)", nil),0];
                self.selectedLabel.hidden = YES;
                self.selectedBtn.selected = NO;
            });
        }
    }];
}

- (void)deleteItemFromPhotoLibraryWithIndex:(NSInteger)index
{
    LocalAssetModel *model = self.mediaModelArr[index];
    [self.deleteArray addObject:model.asset];
    //删除当前图片
    //__weak typeof(self) weakSelf = self;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest deleteAssets:self.deleteArray];
    }completionHandler:^(BOOL success, NSError *error) {
        NSLog(@"Error: %@", error);
        if (success) {
            //重新加载数据
            [self getPHAssetDateFromePhotoLibrary];
            if (self.showType == HohemAlbumViewController_ShowType_Photo) {
                [self getAllDocumentDate:@"Image"];
            }else{
                [self getAllDocumentDate:@"Video"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteItemSuccess" object:nil];
        }
    }];
}

-(void)didClickSelectAllFile:(id)sender{
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    NSLog(@"打印当前的section = %ld",(long)btn.tag);
    NSArray *dateArray = self.mediaModelDataArr[btn.tag];
    for (int i = 0; i < dateArray.count; i++) {
        LocalAssetModel *model = dateArray[i];
        model.isSelect = btn.selected;
        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:i inSection:btn.tag];
        [self.collectionView reloadItemsAtIndexPaths:@[curIndexPath]];
    }
}

- (CGFloat)getFitLengthRatio{

    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return min / 390.0;
}

- (void)didClickNextStepBtn:(UIButton *)btn {
    //进入编辑模式
    MQVideoEditingViewController *videoEditingViewController = [[MQVideoEditingViewController alloc] init];
    videoEditingViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    videoEditingViewController.mediaDic = [NSDictionary dictionaryWithDictionary:self.optionalView.optionalDict];
    [self presentViewController:videoEditingViewController animated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //以时间点划分
    return self.fileNameArray.count;
}

//默认设为一组，每组包含数据源数组个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.mediaModelDataArr == nil) {
        return 0;
    }
    NSArray *mediaArray = self.mediaModelDataArr[section];
    return mediaArray.count;
}
//每个cell将要出现的时候回调的方法
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //复用cell
    HHMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    //cell.backgroundColor = [UIColor orangeColor];

    if (self.mediaModelDataArr) {
        NSArray *mediaArry = self.mediaModelDataArr[indexPath.section];
        LocalAssetModel *model = mediaArry[indexPath.row];
        cell.indexSection = indexPath.section;
        cell.indexRow = indexPath.row;
        //cell自定义的方法,存入model根据model内容显示
        [cell displayModelDataWithModel:model];
    }
    
    //根据当前状态，是否显示选中的图片
    if(_albumMode == HohemAlbum_Mode_DeleteItems)
    {
        cell.selectStateImageView.hidden = NO;
    }else
    {
        cell.selectStateImageView.hidden = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    cell.gestureBlock = ^(BOOL enable, NSInteger section, NSInteger row) {
        if (enable) {
            dispatch_async(dispatch_get_main_queue(), ^{
               //编辑模式
                weakSelf.albumMode = HohemAlbum_Mode_DeleteItems;
                weakSelf.selectedBtn.selected = YES;
                weakSelf.selectedLabel.hidden = NO;
                weakSelf.bottomView.hidden = NO;
                weakSelf.deletedBtn.hidden = NO;
                NSArray *dateArray = weakSelf.mediaModelDataArr[section];
                LocalAssetModel *model = dateArray[row];
                model.isSelect = YES;
                NSLog(@"长按选中cell = %d, %d",section,row);
                [weakSelf.collectionView reloadData];
            });
        }
    };
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
//UICollectionView每个cell被点击时回调的代理
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_albumMode == HohemAlbum_Mode_Viewer) {
        //非选择状态
        LocalAssetModel *assetModel = self.mediaModelArr[[self IndexForImageShow:indexPath]];
        PHAsset *phAsset = assetModel.asset;
        HohemShowAlbumViewController *showVc;
        __weak typeof(self) weakSelf = self;
        NSInteger imageIndex = [self IndexForImageShow:indexPath];
        if (self.showType == HohemAlbumViewController_ShowType_Video) {
            
            showVc = [[HohemShowAlbumViewController alloc] initWithDataFetchResult:self.mediaModelArr selectedIndex:imageIndex showType:self.showType];
        }
        else{
            
            showVc = [[HohemShowAlbumViewController alloc] initWithDataFetchResult:self.mediaModelArr selectedIndex:imageIndex showType:self.showType];
        }
        showVc.scrollToCurrenIndexPathBlock = ^(NSInteger curIndex) {
            if (curIndex >= 0) {
                NSIndexPath *currentIndexPath = [weakSelf getIndexPathFromCurSelectIndex:curIndex];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.collectionView scrollToItemAtIndexPath:currentIndexPath atScrollPosition:UICollectionViewScrollPositionTop  animated:YES];
                });
            }
        };
        showVc.deleteItemBlock = ^(NSInteger curIndex) {
            [weakSelf deleteItemFromPhotoLibraryWithIndex:curIndex];
            [weakSelf.collectionView reloadData];
        };
        showVc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:showVc animated:NO completion:nil];
        
    }else if (_albumMode == HohemAlbum_Mode_DeleteItems)
    {
        //选择编辑状态
        NSArray *dateArray = self.mediaModelDataArr[indexPath.section];
        LocalAssetModel *model = dateArray[indexPath.row];
        //修改数据源的选选中状态,反选
        model.isSelect = !model.isSelect;
        //刷新点中的那个cell
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
//        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];//重新刷新那个cell所在的部分视图
        int selectedCount = 0;
        for (NSArray *dateArray in self.mediaModelDataArr) {

            for(LocalAssetModel *model in dateArray)
            {
                if(model.isSelect == YES)
                {
                    selectedCount ++;
                }
            }

        }
    }
    else{
        NSArray *dateArray = self.mediaModelDataArr[indexPath.section];
        LocalAssetModel *model = dateArray[indexPath.row];
        NSString *string = [NSString stringWithFormat:@"%d",(int)self.optionalView.curIndex];
        LocalAssetModel *newModel = [self.optionalView.optionalDict objectForKey:string];
        newModel.asset = model.asset;
        newModel.propertyName = model.propertyName;
        newModel.propertyType = model.propertyType;
        newModel.propertyThumbImage = model.propertyThumbImage;
        [self.optionalView reloadData];
        if (self.optionalView.curIndex == 10000) {
            self.nextStepBtn.hidden = NO;
        }
        else{
            self.nextStepBtn.hidden = YES;
        }
    }
}

-(NSInteger)IndexForImageShow:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSInteger index = 0;
    for (int i = 0; i < section; i++) {
        NSMutableArray *tempArr = self.mediaModelDataArr[i];
        index += tempArr.count;
    }
    index += row;
    
    return index;
}

- (NSIndexPath *)getIndexPathFromCurSelectIndex:(NSInteger)index
{
    NSInteger row = 0;
    NSInteger section = 0;
    NSInteger tempCount = 0;
    for (int i = 0; i < self.mediaModelDataArr.count; i++) {
        NSMutableArray *tempArr = self.mediaModelDataArr[i];
        tempCount += tempArr.count;
        if (tempCount > index) {
            if (i == 0) {
                section = 0;
                row = index;
            }
            else{
                section = i;
                tempArr = self.mediaModelDataArr[i];
                row = index - (tempCount - tempArr.count);
            }
            
            break;
        }
    }
    
    NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return curIndexPath;
}


#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //degine：390 X 844 = > 108 * 108
    float ratio = 390.0 / CGRectGetWidth(self.view.frame);
    int cellWidth = roundf(108.0 / ratio);
    return (CGSize){cellWidth,cellWidth};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    CGFloat ratio = 390.0 / screenWidth;
    int cellWidth = roundf(108.0 / ratio);
    CGFloat edfeInsetValue = (screenWidth - cellWidth * 3)/4.0 - 0.5;
    
    return UIEdgeInsetsMake(4, edfeInsetValue, 32, edfeInsetValue);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat screenWidth = CGRectGetWidth(self.view.frame);
    CGFloat ratio = 390.0 / screenWidth;
    int cellWidth = roundf(108.0 / ratio);
    CGFloat edfeInsetValue = (screenWidth - cellWidth * 3)/4.0 - 0.5;
    return edfeInsetValue;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.0f;
}

#pragma mark - collectionViewSection设置

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {

    return CGSizeMake(CGRectGetWidth(self.collectionView.frame),22);
    
}
//section以时间为基准命名
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header" forIndexPath:indexPath];
    [header.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    header.backgroundColor = [UIColor clearColor];

    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 22)];
    dateLabel.text = self.fileNameArray[indexPath.section];
    dateLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    dateLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:138.0/255.0 blue:128.0/255.0 alpha:1.0];
    [header addSubview:dateLabel];
//    dateLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"underline.png"]];
    UIButton *selectAllBtn = [[UIButton alloc] init];
    selectAllBtn.frame = CGRectMake(CGRectGetWidth(self.collectionView.frame) - 22 - 16, 0, 22, 22);
    [selectAllBtn setImage:[UIImage imageNamed:@"Hohem_Album_selectedAll"] forState:UIControlStateNormal];
    [selectAllBtn setImage:[UIImage imageNamed:@"Hohem_Album_selectedAll"] forState:UIControlStateSelected];
    [selectAllBtn addTarget:self action:@selector(didClickSelectAllFile:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:selectAllBtn];
    selectAllBtn.tag = indexPath.section;
    if (self.albumMode == HohemAlbum_Mode_DeleteItems) {
        selectAllBtn.hidden = NO;
    }
    else{
        selectAllBtn.hidden = YES;
    }
    
    return header;
}

#pragma mark - 顶部类型滑动模块回调
- (void)slidePageViewDidSelecetedIndex:(NSInteger)index
{
    if (index == 0) {
        self.showType = HohemAlbumViewController_ShowType_Video;
        [self getAllDocumentDate:@"Video"];
    }
    else if (index == 1){
        self.showType = HohemAlbumViewController_ShowType_Photo;
        [self getAllDocumentDate:@"Image"];
    }
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - 懒加载
- (NSMutableDictionary *)photoDic
{
    if (!_photoDic) {
        _photoDic = [[NSMutableDictionary alloc] init];
    }
    return _photoDic;
}

- (NSMutableDictionary *)videoDic
{
    if (!_videoDic) {
        _videoDic = [[NSMutableDictionary alloc] init];
    }
    return _videoDic;
}

- (NSMutableArray *)photoKeyArr
{
    if (!_photoKeyArr) {
        _photoKeyArr = [[NSMutableArray alloc] init];
    }
    return _photoKeyArr;
}

- (NSMutableArray *)videoKeyArr
{
    if (!_videoKeyArr) {
        _videoKeyArr = [[NSMutableArray alloc] init];
    }
    return _videoKeyArr;
}

- (NSMutableDictionary *)mediaModelDataDic
{
    if (!_mediaModelDataDic) {
        _mediaModelDataDic = [[NSMutableDictionary alloc] init];
    }
    return _mediaModelDataDic;
}

- (NSMutableArray *)mediaModelDataArr
{
    if (!_mediaModelDataArr) {
        _mediaModelDataArr = [[NSMutableArray alloc] init];
    }
    return _mediaModelDataArr;
}

- (NSMutableArray *)mediaModelArr
{
    if (!_mediaModelArr) {
        _mediaModelArr = [[NSMutableArray alloc] init];
    }
    return _mediaModelArr;
}

- (NSMutableArray *)selectItemArr
{
    if (!_selectItemArr) {
        _selectItemArr = [[NSMutableArray alloc] init];
    }
    return _selectItemArr;
}

- (NSMutableArray *)deleteArray
{
    if (!_deleteArray) {
        _deleteArray = [[NSMutableArray alloc] init];
    }
    return _deleteArray;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = NO;//设置分页
        _collectionView.showsHorizontalScrollIndicator = NO;//禁用水平水平滚动条
        _collectionView.bounces = NO;//禁用弹簧效果
        _collectionView.backgroundColor = [UIColor whiteColor];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//让它水平滚动
        _flowLayout.minimumLineSpacing = baseMargin;//设置最小行间距为0
        _flowLayout.minimumInteritemSpacing = baseMargin;
        
        // 注册头视图
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    }
    return _collectionView;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end

//
//  HohemShowAlbumViewController.m
//  Hohem Pro
//
//  Created by jolly on 2019/11/25.
//  Copyright © 2019 jolly. All rights reserved.
//

#import "HohemShowAlbumViewController.h"
#import "HohemImageCollectionViewCell.h"
#import "HohemPlayVideoView.h"
#import "LocalAssetModel.h"

@interface HohemShowAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,HohemImageCollectionViewCellDelegate,HohemPlayVideoViewDelegate>

@property (nonatomic, assign) HohemAlbumViewController_ShowType showType;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*dataFetchResult;
@property (nonatomic, strong) NSMutableArray *mediaDataArray;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) HohemBaseButton *backBtn;
@property (nonatomic, strong) HohemBaseLabel *titleLabel;
@property (nonatomic, strong) HohemBaseButton *shareBtn;
@property (nonatomic, strong) HohemBaseButton *infoBtn;
@property (nonatomic, strong) HohemBaseButton *deleteBtn;
@property (nonatomic, strong) UIView *navLineView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isNavView;//是否显示导航栏

@property (nonatomic, strong) HohemPlayVideoView *playView;

@end

static NSString *HohemImageCollectionViewCell_Rid = @"HohemImageCollectionViewCell_Rid";

@implementation HohemShowAlbumViewController

- (instancetype)initWithDataFetchResult:(NSMutableArray *)array selectedIndex:(NSInteger)selectedIndex showType:(HohemAlbumViewController_ShowType)showType{
    
    self = [self init];
    
    self.showType = showType;
    self.mediaDataArray = array;
    self.selectedIndex = selectedIndex;
    
    [self initAttribute];
    [self setUpUI];
    
    return self;
}

- (void)initAttribute {
    
    self.isNavView = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletItemState) name:@"DeleteItemSuccess" object:nil];
}

- (void)setUpUI {
    
     self.view.backgroundColor = [UIColor whiteColor];

    //collectionView
    [self.collectionView registerClass:[HohemImageCollectionViewCell class] forCellWithReuseIdentifier:HohemImageCollectionViewCell_Rid];
    self.collectionView.frame = [UIScreen mainScreen].bounds;
    _flowLayout.itemSize = self.collectionView.bounds.size;
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.navView];
    [self.view addSubview:self.bottomView];
       
       //NavView
    [self.backBtn addTarget:self action:@selector(didClickBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.backBtn];
    
    [self.shareBtn addTarget:self action:@selector(didClickShareBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:self.shareBtn];
    //self.shareBtn.hidden = YES;
    
    [self.infoBtn addTarget:self action:@selector(didClickInfoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.infoBtn];
    self.infoBtn.hidden = YES;
    
    [self.deleteBtn addTarget:self action:@selector(didClickDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.deleteBtn];
       
    [self.navView addSubview:self.titleLabel];
    
    //[self.navView addSubview:self.navLineView];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenNavView:)];
//    [self.view addGestureRecognizer:tap];
}

- (void)hiddenNavView:(BOOL)hidden {
    
//    self.navView.hidden =
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat margin = 16;
    CGFloat w = Tation_safeArea.size.width;
    CGFloat h = 64 + CGRectGetMinY(Tation_safeArea);
    
    self.navView.frame = CGRectMake(0, 0, w, h);
    
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    self.bottomView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 76 - bottomDistValue, w, 76 + bottomDistValue);
    
    w = 44;
    h = 44;
    self.backBtn.frame = CGRectMake( 32, self.navView.bounds.size.height - h - margin, w, h);
    self.shareBtn.frame = CGRectMake( self.navView.bounds.size.width - w - 32, self.navView.bounds.size.height - h - margin, w, h);
    w = 120;
    h = 20;
    margin = 28;
    self.titleLabel.frame = CGRectMake((self.navView.bounds.size.width - w)/2, self.navView.bounds.size.height - h - margin, w, h);
    
    
    self.infoBtn.frame = CGRectMake(32, 16, 44, 44);
    self.deleteBtn.frame = CGRectMake(self.navView.bounds.size.width - 76, 16, 44, 44);
    
    w = self.view.bounds.size.width;
    h = self.view.bounds.size.height;
    self.flowLayout.itemSize = CGSizeMake(w, h);
    self.collectionView.frame = CGRectMake(0, 0, w, h);
    
    //navView顶部层添加渐变层
    self.navView.alpha = 1.0;
    CAGradientLayer *topGradientLayer = [CAGradientLayer layer];
    topGradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.navView.frame), CGRectGetHeight(self.navView.frame));
    topGradientLayer.startPoint = CGPointMake(0.5, 0.0);
    topGradientLayer.endPoint = CGPointMake(0.5, 1.0);
    topGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.09 alpha:1.0].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.15 alpha:1.0].CGColor];
    topGradientLayer.locations = @[@(0.0f),@(0.4f),@(1.0f)];
    [self.navView.layer insertSublayer:topGradientLayer atIndex:0];
    
    //bottomView底部层添加渐变层
    self.bottomView.alpha = 1.0;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bottomView.frame), CGRectGetHeight(self.bottomView.frame));
    gradientLayer.startPoint = CGPointMake(0.5, 1.0);
    gradientLayer.endPoint = CGPointMake(0.5, 0.0);
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.09 alpha:1.0].CGColor,
                             (__bridge id)[UIColor colorWithWhite:0.15 alpha:1.0].CGColor];
    gradientLayer.locations = @[@(0.0f),@(0.4f),@(1.0f)];
    [self.bottomView.layer insertSublayer:gradientLayer atIndex:0];
    
}

//点击返回按钮
- (void)didClickBackBtn:(HohemBaseButton *)btn {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeleteItemSuccess" object:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        self.scrollToCurrenIndexPathBlock(self.selectedIndex);
    }];
}

- (void)didClickShareBtn:(HohemBaseButton *)btn {
    
    LocalAssetModel *model = self.mediaDataArray[self.selectedIndex];
    PHAsset *asset = model.asset;
    if (self.showType == HohemAlbumViewController_ShowType_Video) {
        [Tation_kSharedToolsManager shareVideoWithAsset:asset completeHandler:nil];
    }
    else{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize targetSize = CGSizeMake(pixelWidth, pixelHeight);
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [Tation_kSharedToolsManager shareImageWithImage:result completeHandler:nil];
        }];
    }
}

- (void)didClickInfoBtn:(HohemBaseButton *)btn {
    
}

- (void)didClickDeleteBtn:(HohemBaseButton *)btn {
    
    NSInteger index = self.selectedIndex;
    self.deleteItemBlock(index);
}

- (void)deletItemState
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
    });
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.mediaDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LocalAssetModel *model = self.mediaDataArray[indexPath.row];
    
    HohemImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HohemImageCollectionViewCell_Rid forIndexPath:indexPath];
    cell.delegate = self;
    cell.assetModel = model;
    cell.controller = (id)self;
    [cell showPlayBtn:(self.showType == HohemAlbumViewController_ShowType_Video)];
    
    PHAsset *asset = model.asset;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    if (self.showType == HohemAlbumViewController_ShowType_Photo) {
        CGFloat aspectRatio = asset.pixelWidth / (CGFloat)asset.pixelHeight;
        CGFloat pixelWidth = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize targetSize = CGSizeMake(pixelWidth, pixelHeight);
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            [cell updateImageWithImage:result];
        }];
    }
    else{
        cell.hiddenSlideView = !self.isNavView;
    }
    
    self.titleLabel.text = model.propertyName;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HohemImageCollectionViewCell *cell = (HohemImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [cell setScrollViewZoomScale];
    self.isNavView = !self.isNavView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    HohemImageCollectionViewCell *cell = (HohemImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:curIndexPath];
    [cell videoStopPlay];
    
    //self.isNavView = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 获取当前显示的cell的下标
    NSIndexPath *firstIndexPath = [[self.collectionView indexPathsForVisibleItems] firstObject];
    //刷新前面的视频
    
    // 赋值给记录当前坐标的变量
    self.selectedIndex = firstIndexPath.item;
    // 更新底部的数据
    // ...
    
    
}

#pragma mark - HohemImageCollectionViewCellDelegate
- (void)HohemImageCollectionViewCellDelegate:(HohemImageCollectionViewCell *)cell functionStr:(NSString *)functionStr value:(NSString *)value {
    
    if ([functionStr isEqualToString:@"playVideo"]) {
        
        self.playView = [[HohemPlayVideoView alloc]init];
        [self.view addSubview:self.playView];
        self.playView.delegate = self;
        
        self.playView.frame = [UIScreen mainScreen].bounds;
        
            // 获取一个资源（PHAsset）
        LocalAssetModel *model = self.mediaDataArray[self.selectedIndex];
        PHAsset *phAsset = model.asset;
        if (phAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;

            PHImageManager *manager = [PHImageManager defaultManager];
            [manager requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                AVURLAsset *urlAsset = (AVURLAsset *)asset;

                NSURL *url = urlAsset.URL;

                [self.playView updateVideoUrl:url];
                    
                }];
        }
    }
}

#pragma mark - HohemPlayVideoViewDelegate
- (void)HohemPlayVideoViewDelegate:(HohemPlayVideoView *)playView function:(NSString *)function value:(NSString *)value {
    
    if ([function isEqualToString:@"back"]) {
        
        [self.playView removeFromSuperview];
        self.playView = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - MediaPlayerDelegate
- (void)hiddenControlView:(BOOL)isHidden
{
    self.isNavView = !isHidden;
}

#pragma mark - 懒加载
- (UIView *)navView {
    
    if (_navView == nil) {
        
        _navView = [[UIView alloc]init];
        _navView.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    }
    
    return _navView;
}

- (UIView *)bottomView
{
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    }
    return _bottomView;
}

- (HohemBaseButton *)backBtn {
    
    if (_backBtn == nil) {
        
        _backBtn = [[HohemBaseButton alloc]init];
        [_backBtn setImage:Tation_Resource_Image(@"Hohem_Album_back") forState:UIControlStateNormal];
    }
    
    return _backBtn;
}

- (HohemBaseButton *)shareBtn {
    
    if (_shareBtn == nil) {
        
        _shareBtn = [[HohemBaseButton alloc] init];
        [_shareBtn setImage:Tation_Resource_Image(@"Hohem_Album_share") forState:UIControlStateNormal];
        //_shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    
    return _shareBtn;
}

- (HohemBaseButton *)infoBtn
{
    if (_infoBtn == nil) {
        _infoBtn = [[HohemBaseButton alloc] init];
        [_infoBtn setImage:Tation_Resource_Image(@"Hohem_Album_info") forState:UIControlStateNormal];
    }
    return _infoBtn;
}

- (HohemBaseButton *)deleteBtn
{
    if (_deleteBtn == nil) {
        _deleteBtn = [[HohemBaseButton alloc] init];
        [_deleteBtn setImage:Tation_Resource_Image(@"Hohem_Album_delete") forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

- (HohemBaseLabel *)titleLabel {
    
    if (_titleLabel == nil) {
        
        _titleLabel = [[HohemBaseLabel alloc]init];
        _titleLabel.tintColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = Tation_Resource_Str(@"Hohem.Local.LocalTitle");
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}

- (UIView *)navLineView {
    
    if (_navLineView == nil) {
        
        _navLineView = [[UIView alloc]init];
        _navLineView.backgroundColor = [UIColor grayColor];
    }
    
    return _navLineView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.pagingEnabled = YES;//设置分页
        _collectionView.showsHorizontalScrollIndicator = YES;//禁用水平水平滚动条
        _collectionView.bounces = NO;//禁用弹簧效果
        _collectionView.backgroundColor = [UIColor clearColor];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//让它水平滚动
        _flowLayout.minimumLineSpacing = 0.0;//设置最小行间距为0
        _flowLayout.minimumInteritemSpacing = 0.0;
    }
    return _collectionView;
}

- (void)setIsNavView:(BOOL)isNavView {
    
    _isNavView = isNavView;
    NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    HohemImageCollectionViewCell *cell = (HohemImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:curIndexPath];
    if (isNavView) {
        
        self.navView.hidden = NO;
        self.bottomView.hidden = NO;
        [cell setHiddenSlideView:NO];
    }else{
        self.navView.hidden = YES;
        self.bottomView.hidden = YES;
        [cell setHiddenSlideView:YES];
    }
}

@end

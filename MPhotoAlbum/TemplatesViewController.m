//
//  TemplatesViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/10.
//

#import "TemplatesViewController.h"
#import "TationDeviceManager.h"
#import "HohemAlbumViewController.h"
#import "MediaSelectionViewController.h"

static NSString *const cellId = @"TemplateCellID";

@interface TemplatesViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, assign) CGFloat fitRatio;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) UIButton *downloadBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

//模板读取
@property (nonatomic, strong) EditTemplateModel *templateModel;

@end

@implementation TemplatesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    [self initAttribute];
    
    //获取UI适应屏幕的参数
    self.fitRatio = [self getFitLengthRatio];
    
    
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //设置View布局
    CGRect saftArea = Tation_safeArea;
    CGFloat xIphoneMargin = saftArea.origin.y;
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = 56;
    self.titleView.frame = CGRectMake(0, 0, w, h + xIphoneMargin);
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 180)/2, 18 + xIphoneMargin, 180, 16);
    self.backBtn.frame = CGRectMake( 32* self.fitRatio, 4 + xIphoneMargin, 44* self.fitRatio, 44* self.fitRatio);
    
    self.videoView.frame = CGRectMake(16 * self.fitRatio, (CGRectGetHeight(self.view.frame) - 200 * self.fitRatio)/2.0, w - 2 * 16 * self.fitRatio, 200 * self.fitRatio);
    self.downloadBtn.frame = CGRectMake(w - (96+16) * self.fitRatio, CGRectGetMaxY(self.videoView.frame) + 12 *self.fitRatio, 96 * self.fitRatio, 38 * self.fitRatio);
    
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    h = CGRectGetHeight(self.view.frame);
    self.collectionView.frame = CGRectMake(0, h - 70 - 108 - bottomDistValue, w, 128);
    
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.titleView];
    [self.titleView addSubview:self.backBtn];
    [self.titleView addSubview:self.titleLabel];
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.downloadBtn];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
}

- (void)initAttribute
{
    //MARK:获取模板数据
    VideoTemplateReader *videoTemplateReader = [[VideoTemplateReader alloc] init];
    self.templateModel = [videoTemplateReader getVideoTemplateParameter:CustomVideoTemplateType_StoryA];
    NSLog(@"打印模板的数据%@",_templateModel);
}

- (void)didClickBackButton:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didClickDownloadVideo:(UIButton *)btn
{
    
}

- (CGFloat)getFitLengthRatio{

    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return min / 390.0;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //以时间点划分
    return 1;
}

//默认设为一组，每组包含数据源数组个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return 5;
}
//每个cell将要出现的时候回调的方法
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //复用cell
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor orangeColor];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 8.0;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaSelectionViewController *albumController = [[MediaSelectionViewController alloc] init];
    albumController.modalPresentationStyle = UIModalPresentationFullScreen;
    albumController.templateModel = self.templateModel;
    albumController.albumMode = HohemAlbum_Mode_VideoEditor;
    //[self presentViewController:albumController animated:YES completion:nil];
    [self.navigationController pushViewController:albumController animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

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
    
    return UIEdgeInsetsMake(10, edfeInsetValue, 10, edfeInsetValue);
}


#pragma mark - 懒加载
- (UIView *)videoView
{
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
        _videoView.backgroundColor = [UIColor orangeColor];
        _videoView.layer.masksToBounds = YES;
        _videoView.layer.cornerRadius = 8.0;
    }
    return _videoView;
}

- (UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
    }
    return _titleView;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"Hohem.Tutorial.Back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"选择模板";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)downloadBtn
{
    if (!_downloadBtn) {
        _downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downloadBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_downloadBtn addTarget:self action:@selector(didClickDownloadVideo:) forControlEvents:UIControlEventTouchUpInside];
        _downloadBtn.backgroundColor = [UIColor orangeColor];
        _downloadBtn.layer.masksToBounds = YES;
        _downloadBtn.layer.cornerRadius = 19;
    }
    return _downloadBtn;
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
        _collectionView.backgroundColor = [UIColor blackColor];
        
        CGFloat baseMargin = 10;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//让它水平滚动
        _flowLayout.minimumLineSpacing = baseMargin;//设置最小行间距为0
        _flowLayout.minimumInteritemSpacing = baseMargin;

    }
    return _collectionView;
}




@end

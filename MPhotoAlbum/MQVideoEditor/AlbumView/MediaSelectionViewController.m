//
//  MediaSelectionViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/24.
//  Copyright © 2022 Man. All rights reserved.
//

#import "MediaSelectionViewController.h"
#import "OptionalEditView.h"
#import "MQVideoEditingViewController.h"


@interface MediaSelectionViewController ()

//下面是视频编辑模块的测试
@property (nonatomic, strong) UIView *editingToolView;
@property (nonatomic, strong) UILabel *editingTitleLabel;
@property (nonatomic, strong) UILabel *editingHintLabel;
@property (nonatomic, strong) UIButton *editingNextStepBtn;
@property (nonatomic, strong) OptionalEditView *optionalView;

@end

@implementation MediaSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupMediaSelectionView];
    //添加KVO监听
    [self.optionalView addObserver:self forKeyPath:@"currentCount" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setupMediaSelectionView
{
    //隐藏部分原相册功能按钮
    self.selectedBtn.hidden = YES;
    
    //底部视频选择栏
    self.editingToolView = [[UIView alloc] init];
    self.editingToolView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.editingToolView];
    //视频编辑的标题
    self.editingTitleLabel = [[UILabel alloc] init];
    self.editingTitleLabel.text = @"请选择素材";
    self.editingTitleLabel.font = [UIFont systemFontOfSize:16.0];
    self.editingTitleLabel.textColor = [UIColor whiteColor];
    self.editingTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.editingToolView addSubview:self.editingTitleLabel];
    //视频编辑提示语
    self.editingHintLabel = [[UILabel alloc] init];
    self.editingHintLabel.text = @"上滑删除选中视频素材";
    self.editingTitleLabel.font = [UIFont systemFontOfSize:16.0];
    self.editingHintLabel.textColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    self.editingTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.editingToolView addSubview:self.editingHintLabel];
    
    __weak typeof(self) weakSelf = self;
    self.optionalView = [[OptionalEditView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, CGRectGetWidth(self.view.frame), 64)];
    self.optionalView.maxcount = self.templateModel.amount;
    self.optionalView.templateModelArray = self.templateModel.scripts;
    self.optionalView.deleteOptionalModelBlock = ^{
        weakSelf.editingNextStepBtn.enabled = NO;
        weakSelf.editingNextStepBtn.backgroundColor = [UIColor whiteColor];
    };
    self.optionalView.backgroundColor = [UIColor blackColor];
    [self.editingToolView addSubview:self.optionalView];
    
    //视频剪辑下一步按钮
    self.editingNextStepBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editingNextStepBtn setTitle:[NSString stringWithFormat:@"选好了(0/4)"] forState:UIControlStateNormal];
    self.editingNextStepBtn.backgroundColor = [UIColor colorWithRed:61710/255.0 green:61710/255.0 blue:61710/255.0 alpha:1.0];
    self.editingNextStepBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.editingNextStepBtn setTitleColor:[UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.editingNextStepBtn addTarget:self action:@selector(didClickNextStepBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.editingToolView addSubview:self.editingNextStepBtn];
    self.editingNextStepBtn.layer.masksToBounds = YES;
    self.editingNextStepBtn.layer.cornerRadius = 19;
    self.editingNextStepBtn.enabled = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //视频编辑底部选择布局frame
    CGFloat h = 187;
    CGFloat bottomDistValue = Tation_BottomSafetyDistance;
    self.editingToolView.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - h - bottomDistValue, CGRectGetWidth(self.view.frame), h + bottomDistValue);
    self.editingTitleLabel.frame = CGRectMake(16, 16, 162, 22);
    self.optionalView.frame = CGRectMake(0, 44, CGRectGetWidth(self.view.frame), 64);
    self.editingHintLabel.frame = CGRectMake(16, 142, 180, 22);
    self.editingNextStepBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 118 - 16, self.editingHintLabel.center.y - 38/2, 118, 38);
}


#pragma mark - 按钮
- (void)didClickBackBtn:(UIButton *)btn {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didClickNextStepBtn:(UIButton *)btn {
    //进入编辑模式
    MQVideoEditingViewController *videoEditingViewController = [[MQVideoEditingViewController alloc] init];
    videoEditingViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    videoEditingViewController.mediaDic = [NSDictionary dictionaryWithDictionary:self.optionalView.optionalDict];
    [self.navigationController pushViewController:videoEditingViewController animated:YES];
}

#pragma mark - UICollectionViewDelegate
//UICollectionView每个cell被点击时回调的代理
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.albumMode == HohemAlbum_Mode_VideoEditor) {
        if (self.optionalView.curIndex >= self.templateModel.amount) {
            //位置已满
            return;
        }
        //视频编辑的多选模式
        NSArray *dateArray = self.mediaModelDataArr[indexPath.section];
        LocalAssetModel *model = dateArray[indexPath.row];
        NSString *string = [NSString stringWithFormat:@"%d",(int)self.optionalView.curIndex];
        LocalAssetModel *newModel = [self.optionalView.optionalDict objectForKey:string];
        EditUnitModel *editUnitModel = self.templateModel.scripts[self.optionalView.curIndex];
        if (model.propertyType == PHAssetMediaTypeVideo) {
            if (model.asset.duration < editUnitModel.mediaDuration) {
                NSLog(@"时间不符合要求");
                return;
            }
            
        }
        
        newModel.asset = model.asset;
        newModel.propertyName = model.propertyName;
        newModel.propertyType = model.propertyType;
        newModel.propertyThumbImage = model.propertyThumbImage;
        [self.optionalView reloadData];
        if (self.optionalView.curIndex == 10000) {
            self.editingNextStepBtn.enabled = YES;
            self.editingNextStepBtn.backgroundColor = [UIColor orangeColor];
        }
        else{
            self.editingNextStepBtn.enabled = NO;
            self.editingNextStepBtn.backgroundColor = [UIColor whiteColor];
        }
    }
    else if (self.albumMode == HohemAlbum_Mode_ReplaceMedia)
    {
        //视频编辑的单选替换素材模式
        
    }
}

#pragma mark - KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentCount"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int selectedCount = (int)self.optionalView.currentCount;
            [self.editingNextStepBtn setTitle:[NSString stringWithFormat:@"选好了(%d/4)",selectedCount] forState:UIControlStateNormal];
        });
    }
}

#pragma mark - 视频剪辑模板更新




- (void)dealloc
{
    //移除KVO监听
    [self.optionalView removeObserver:self forKeyPath:@"currentCount"];
    NSLog(@"%s",__func__);
}

@end

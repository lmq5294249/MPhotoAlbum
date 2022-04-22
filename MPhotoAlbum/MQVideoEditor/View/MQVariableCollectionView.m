//
//  MQVariableCollectionView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/22.
//

#import "MQVariableCollectionView.h"
#import "MQDragingCell.h"
#import "MVideoEditView.h"

@interface MQVariableCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIButton *confirmBtn;
    UIButton *cancelBtn;
    
    NSMutableArray <MediaAssetModel*>* mediaTempArray; //临时保存数组
    
    BOOL isChangeOrder;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) MQDragingCell *dragingItem;

@property (nonatomic, strong) NSIndexPath *dragingIndexPath;

@property (nonatomic, strong) NSIndexPath *targetIndexPath;

@end


@implementation MQVariableCollectionView

static NSString* cellId = @"MQDragingCell";

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        isChangeOrder = NO;
        
        [self setUpUI];
        
    }
    return self;
}

- (void)setUpUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(60, 60);
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 80) collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[MQDragingCell class] forCellWithReuseIdentifier:cellId];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    longPress.minimumPressDuration = 0.3f;
    [_collectionView addGestureRecognizer:longPress];
    
    //拖动的替身显示
    _dragingItem = [[MQDragingCell alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _dragingItem.hidden = YES;
    [self addSubview:_dragingItem];
    
}

#pragma mark - LongPressMethod
-(void)longPressMethod:(UILongPressGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:_collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
-(void)dragBegin:(CGPoint)point{
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {return;}
    [_collectionView bringSubviewToFront:_dragingItem];
    MQDragingCell *item = (MQDragingCell*)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    item.isMoving = true;
    item.thumbImageView.hidden = YES;
    //更新被拖拽的item
    _dragingItem.hidden = NO;
    _dragingItem.frame = item.frame;
    _dragingItem.title = item.title;
    _dragingItem.thumbImage = item.thumbImage;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.2, 1.2)];
}

//正在被拖拽、、、
-(void)dragChanged:(CGPoint)point{
    if (!_dragingIndexPath) {return;}
    _dragingItem.center = point;
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
}

//拖拽结束
-(void)dragEnd{
    if (!_dragingIndexPath || !_targetIndexPath)
    {
        self.dragingItem.hidden = YES;
        MQDragingCell *item = (MQDragingCell*)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
        item.isMoving = false;
        item.hidden = NO;
        return;
    }
    //更新数据源
    [self rearrangeMediaFileArray];
    
    CGRect endFrame = [_collectionView cellForItemAtIndexPath:_targetIndexPath].frame;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    //__weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        self.dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.dragingItem.hidden = YES;
            MQDragingCell *item = (MQDragingCell*)[self.collectionView cellForItemAtIndexPath:self.dragingIndexPath];
            item.isMoving = false;
            item.thumbImageView.hidden = NO;
            //刷新
            [self reloadData];
        });
    }];
    
    
}

//获取被拖动IndexPath的方法
-(NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point{
    NSIndexPath* dragIndexPath = nil;
    //最后剩一个怎不可以排序
    //if ([_collectionView numberOfItemsInSection:0] == 1) {return dragIndexPath;}
    
    
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //需要固定位置的前几个item不需要排序
        if (indexPath.row<self.fixedNum) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row >= 0) {
                dragIndexPath = indexPath;
            }
            break;
        }
    }
    return dragIndexPath;
}

//获取目标IndexPath的方法
-(NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //需要固定位置的前几个item不需要排序
        if (indexPath.row<self.fixedNum) {
            continue;
        }
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            if (indexPath.row >= 0) {
                targetIndexPath = indexPath;
            }
        }
    }
    return targetIndexPath;
}

#pragma mark - CollectionViewDelegate&DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mediaAssetArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MQDragingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    LocalAssetModel *model = self.mediaAssetArray[indexPath.row];
    EditUnitModel *editunitModel = self.templateModelArray[indexPath.row];
    cell.thumbImage = model.propertyThumbImage;
    cell.timeLabel.text = [NSString stringWithFormat:@"%.1fs",editunitModel.mediaDuration];
    cell.backgroundColor = [UIColor blackColor];
    cell.isFixed = NO;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了CollectionView的 %ld",(long)indexPath.row);
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    //MARK:点击cell进入编辑片段模式
//    MVideoEditView *videoEditView = [[MVideoEditView alloc] initWithFrame:screenFrame withMediaAssetArray:self.mediaAssetArray mediaIndex:indexPath.row];
//    videoEditView.updateBlock = _updateBlock;
//    videoEditView.waitingBlock = _waitingBlock;
//    videoEditView.hideAlertBlock = _hideAlertBlock;
//    videoEditView.transitionNodeArray = self.transitionNodeArray;
//    [self.mainView addSubview:videoEditView];
}

#pragma mark - 刷新方法 -
//拖拽排序后需要重新排序数据源
-(void)rearrangeMediaFileArray
{
    //交换可变数组里面的两个元素位置,其余保持不变
    NSLog(@"交换可变数组里面的两个元素位置,其余保持不变");
    NSInteger drageIndex  = _dragingIndexPath.row;
    NSInteger targetIndex = _targetIndexPath.row;
    if (drageIndex == targetIndex) {
        return;
    }
    [_mediaAssetArray exchangeObjectAtIndex:drageIndex withObjectAtIndex:targetIndex];
    isChangeOrder = YES;
 }

- (void)refreshMediaAssetArrayDataAndUI
{
    //self.waitingBlock();
    
    //MARK:交换元素的位置，主要需要更新转场渲染问题
//    MVideoProcessManager *videoProcessManager = [[MVideoProcessManager alloc] init];
//    videoProcessManager.mediaAssetArray = _mediaAssetArray;
//    videoProcessManager.transitionNodeArray = _transitionNodeArray;
//    __weak typeof(self) weakSelf = self;
//    [videoProcessManager reRenderNewTransitionHandleComplete:^{
//        //这里需要做一些操作，否则该程序前面执行的weakSelf会空导致程序报错
//        NSLog(@"更新完毕");
//        //[videoProcessManager saveMergeAllVideosToLibrary];
//        weakSelf.updateBlock();
//        weakSelf.hideAlertBlock();
//    }];
}

-(void)reloadData
{
    [_collectionView reloadData];
}

@end

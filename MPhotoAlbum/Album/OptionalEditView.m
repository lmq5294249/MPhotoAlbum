//
//  OptionalEditView.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/7.
//

#import "OptionalEditView.h"
#import "OptionalCell.h"

@interface OptionalEditView ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
{
    CGPoint touchPoint;
    NSInteger selectedIndex;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end

@implementation OptionalEditView

static NSString *const cellId = @"OptionalMediaCellID";

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
        [self initAttribute];

    }
    return self;
}

- (void)setUpUI
{
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
    
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[OptionalCell class] forCellWithReuseIdentifier:cellId];
    
}

- (void)initAttribute
{
    self.curIndex = 0;
    self.completed = NO;
}

#pragma mark - UICollectionDelegate && dataSource

//默认设为一组，每组包含数据源数组个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.optionalDict.count;
}
//每个cell将要出现的时候回调的方法
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    //复用cell
    OptionalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

    LocalAssetModel *model = [self.optionalDict objectForKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    
    [cell displayCellWithModel:model];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    panGesture.delegate = self;
    cell.thumbImageView.userInteractionEnabled = TRUE;
    [cell.thumbImageView addGestureRecognizer:panGesture];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //触摸后滚动到中间的位置
    //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    OptionalCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    CGFloat offset = 5 + cell.frame.size.width;
    [self.collectionView setContentOffset:CGPointMake(offset * indexPath.row - CGRectGetWidth(self.frame)/2 + (cell.frame.size.width/2 + 10), 0) animated:YES];
}

#pragma mark - 手势识别器是否能够开始识别手势.
//当手势识别器识别到手势,准备从UIGestureRecognizerStatePossible状态开始转换时.调用此代理,如果返回YES,那么就继续识别,如果返回NO,那么手势识别器将会将状态置为UIGestureRecognizerStateFailed.

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    
    //相对有手势父视图的坐标点(注意如果父视图是scrollView,locationPoint.x可能会大于视图的width)
    CGPoint locationPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    
    
    if (translation.x < 0) {
        //向左滑
        NSLog(@"向左滑");
    }else if (translation.x > 0) {
        //向右滑
        NSLog(@"向右滑");
    }
    
    if (translation.y < 0) {
        //向上滑
        NSLog(@"向上滑");
        return YES;
    }else if (translation.y > 0) {
        //向下滑
        NSLog(@"向下滑");
    }
    return NO;
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    
    CGPoint translation = [pan translationInView:pan.view];
    CGPoint center = pan.view.center;
    center.x = center.x + translation.x;
    center.y = center.y + translation.y;
    pan.view.center = center;
    
    // 复位
    [pan setTranslation:CGPointZero inView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [pan.view setCenter:CGPointZero];
        //判断触摸点是否在view里面
        CGPoint location = [pan locationInView:self.collectionView];
        location = CGPointMake(location.x, location.y + CGRectGetHeight(self.collectionView.frame)/2);
        if (location.y < 0) {
            [self deleteSelectedDictModel:selectedIndex];
        }
        [self reloadData];
    }
    else if (pan.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [pan locationInView:self.collectionView];
        if (location.y < 10) {
            //保证触摸到边缘计算到cell也是对的,否则容易出现获取cell的indexPath为nil
            location = CGPointMake(location.x, CGRectGetHeight(self.collectionView.frame)/2);
        }
        NSIndexPath *indexpath = [self.collectionView indexPathForItemAtPoint:location];
        if (indexpath) {
            //这里需要判断indexpath是否存在，因为快速滑动时location有可能坐标为负导致结果nil
            selectedIndex = indexpath.row;
        }
        else{
            //防止获取indexpath为空，然后selectedIndex保留之前的数值导致删除错
            selectedIndex = 1000;
        }
        
    }
    
}


#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:_flowLayout];
        _collectionView.pagingEnabled = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces = YES;//弹簧效果
        _collectionView.scrollEnabled = YES;//滚动
        _collectionView.alwaysBounceHorizontal = YES;//总是滚动效果
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.clipsToBounds = NO;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;//让它水平滚动
        _flowLayout.minimumLineSpacing = 5.0;//设置最小行间距为0
        _flowLayout.minimumInteritemSpacing = 5.0;
        _flowLayout.itemSize = CGSizeMake(self.frame.size.height - 10, self.frame.size.height - 10);
        _flowLayout.sectionInset = UIEdgeInsetsMake(5 ,10, 5, 10);
    }
    return _collectionView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"======================");
    
}

- (void)setMaxcount:(NSInteger)maxcount
{
    _maxcount = maxcount;
    if (_maxcount > 0) {
        _optionalDict = [[NSMutableDictionary alloc] initWithCapacity:_maxcount];
        for (int i = 0; i < _maxcount; i++) {
            LocalAssetModel *model = [[LocalAssetModel alloc] init];
            [_optionalDict setObject:model forKey:[NSString stringWithFormat:@"%d",i]];
        }
        _curIndex = 0;
        //刷新数据更新UI
        [self.collectionView reloadData];
    }
}

- (NSInteger)getNextIndex
{
    //获取下一个空缺cell的索引
    NSInteger index = 10000;
    for (int i = 0; i < _maxcount; i++) {
        NSString *key = [NSString stringWithFormat:@"%d",i];
        LocalAssetModel *model = [self.optionalDict objectForKey:key];
        if (!model.asset && index == 10000) {
            index = i;
            model.isSelect = YES;
        }
        else{
            model.isSelect = NO;
        }
    }
    _curIndex = index;
    
    if (_curIndex == 10000) {
        self.completed = YES;
    }
    else{
        self.completed = NO;
    }
    
    return index;
}

- (void)deleteSelectedDictModel:(NSInteger)index
{
    NSString *key = [NSString stringWithFormat:@"%ld",(long)index];
    LocalAssetModel *model = [self.optionalDict objectForKey:key];
    model.asset = nil;
    model.propertyThumbImage = nil;
    model.propertyName = nil;
    model.propertyType = 0;
    model.isSelect = NO;
    
    self.deleteOptionalModelBlock();
}

//- (void)setOptionalArray:(NSMutableArray *)optionalArray
//{
//    _optionalArray = optionalArray;
//
//    //刷新数据更新UI
//    [self.collectionView reloadData];
//}

- (void)reloadData
{
    //刷新数据更新UI
    [self getNextIndex];
    [self.collectionView reloadData];
    
}

@end

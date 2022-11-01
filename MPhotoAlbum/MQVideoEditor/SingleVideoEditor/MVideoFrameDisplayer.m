//
//  MVideoFrameDisplayer.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/14.
//

#import "MVideoFrameDisplayer.h"
#import "UIImage+Zoom.h"

static NSString* cellId = @"MQFrameCell";

@implementation FrameCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
        
    }
    
    return self;
}

- (void)setUpUI
{
    self.frameImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.frameImageView];
    self.frameImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.frameImageView.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frameImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

@end


@interface MVideoFrameDisplayer ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSTimeInterval totalTime;
    
    NSTimeInterval fragmentTime;
    
    NSTimeInterval timePreFrame;
    
    CGFloat viewWidth;
    CGFloat viewHeight;

    CGFloat frameCellWidthValue;
    CGFloat frameCellTotal;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, assign) CGFloat lengthPreSecond;
@property (nonatomic, assign) CGFloat videoLengthValue;
@property (nonatomic, assign) CGFloat widthPreFrame;
@property (nonatomic, strong) dispatch_queue_t thumbQueue;
@end


@implementation MVideoFrameDisplayer

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url videoFragmentDur:(NSTimeInterval)time
{
    if (self = [super initWithFrame:frame]) {
        viewWidth = frame.size.width;
        viewHeight = frame.size.height;
        self.videoUrl = url;
        fragmentTime = time;
        //[self setupUI];
        [self setupCollectionView];
        self.thumbQueue = dispatch_queue_create("GetVideoThumb", 0);
    }
    return self;
}

- (void)setupCollectionView
{
    self.backgroundColor = [UIColor blackColor];
    //设置scrollVIew布局 -> scrollVIew占界面的横向的宽的六分之四，其余六分之一为左右边距对称
    //默认无论任何时间段都是以这样的数据为基础实现，也就是说当前的播放时间段对应六分之四的宽度，决定了视频全部的长度和，间隔截取图片的时间长度
    AVAsset *asset = [AVAsset assetWithURL:self.videoUrl];
    totalTime = CMTimeGetSeconds(asset.duration);
    //片段时间一共有四帧画面，计算出每帧时间
    timePreFrame = fragmentTime / 4;
    
    CGFloat x = viewWidth / 6.0;
    CGFloat y = 0;
    CGFloat w = x * 4;
    CGFloat h = viewHeight;
    [self addSubview:self.collectionView];
    self.collectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    frameCellWidthValue = x;
    
    //左右边距的设置黑色半透明凸显中间区域
    UIView *leftEdgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, x, h)];
    leftEdgeView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.65];
    [self addSubview:leftEdgeView];
    UIView *rightEdgeView = [[UIView alloc] initWithFrame:CGRectMake(5*x, 0, viewWidth - 5*x, h)];
    rightEdgeView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.65];
    [self addSubview:rightEdgeView];
    
    //scrollview上面添加一个白色外边框显示区域
    UIImage *orginImage = [UIImage imageNamed:@"TimeRange0"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(x - 5, -2, w + 10, CGRectGetHeight(self.collectionView.frame) + 4)];
    [self addSubview:backgroundView];
    backgroundView.image = [orginImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 30, 10, 30) resizingMode:UIImageResizingModeTile];
    
    //选中固定的片段的时长与对应长度比值
    self.lengthPreSecond = w / fragmentTime; //单位为秒s,每秒的长度
    //设置scrollView的内容及大小
    CGFloat contentWidth = self.lengthPreSecond * totalTime;
    self.videoLengthValue = contentWidth;
    //self.scrollView.contentSize = CGSizeMake(contentWidth, viewHeight);
    NSInteger totalCount = ceilf(totalTime / timePreFrame);
    self.widthPreFrame = x;
    frameCellTotal = totalCount + 2; //这里是加上头尾两个空白的cell作为显示,那么计算的时候需要要减去
    
    [self.collectionView reloadData];
}

- (void)thumbnailImageAtTime:(NSTimeInterval)time image:(void(^)(UIImage *image))imageBlock {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    dispatch_async(self.thumbQueue, ^{
        
        @autoreleasepool {
            AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset] ;
            assetImageGenerator.appliesPreferredTrackTransform = YES;
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
            //补充修改
            assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
            assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
            
            //CMTime pointTime = CMTimeMakeWithSeconds(time, 30);
            CMTime pointTime = CMTimeMake(time * 600 , 600);
            
            NSError *thumbnailImageGenerationError = nil;
            CGImageRef  thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:pointTime actualTime:NULL error:&thumbnailImageGenerationError];
            
            if (thumbnailImageGenerationError) {
                NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
            }
            
            
            UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:thumbnailImageRef];
            CGImageRelease(thumbnailImageRef);
        //    NSData *data = UIImageJPEGRepresentation(thumbnailImage, 0.1);
        //    UIImage *image =  [UIImage imageWithData:data scale:20];
                UIImage *image = [thumbnailImage resizeImageToSize:CGSizeMake(180, 180) resizeMode:enSvResizeAspectFill];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                if (imageBlock) {
                    imageBlock(image);
                }
                    
                });
        }
    
    });
 
}

#pragma mark - UIScrollView (目前弃用)
- (void)setupUI
{
    self.backgroundColor = [UIColor blackColor];
    //设置scrollVIew布局 -> scrollVIew占界面的横向的宽的六分之四，其余六分之一为左右边距对称
    //默认无论任何时间段都是以这样的数据为基础实现，也就是说当前的播放时间段对应六分之四的宽度，决定了视频全部的长度和，间隔截取图片的时间长度
    AVAsset *asset = [AVAsset assetWithURL:self.videoUrl];
    totalTime = CMTimeGetSeconds(asset.duration);
    //片段时间一共有四帧画面，计算出每帧时间
    timePreFrame = fragmentTime / 4;
    
    CGFloat x = viewWidth / 6.0;
    CGFloat y = 0;
    CGFloat w = x * 4;
    CGFloat h = viewHeight;
    [self addSubview:self.scrollView];
    self.scrollView.frame = CGRectMake(x, y, w, h);
    
    //左右边距的设置黑色半透明凸显中间区域
    UIView *leftEdgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, x, h)];
    leftEdgeView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.65];
    [self addSubview:leftEdgeView];
    UIView *rightEdgeView = [[UIView alloc] initWithFrame:CGRectMake(viewWidth - x, 0, x, h)];
    rightEdgeView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:1.0/255.0 blue:1.0/255.0 alpha:0.65];
    [self addSubview:rightEdgeView];
    
    //scrollview上面添加一个白色外边框显示区域
    UIImage *orginImage = [UIImage imageNamed:@"TimeRange0"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scrollView.frame) - 5, -2, CGRectGetWidth(self.scrollView.frame) + 10, CGRectGetHeight(self.scrollView.frame) + 4)];
    [self addSubview:backgroundView];
    backgroundView.image = [orginImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 30, 10, 30) resizingMode:UIImageResizingModeTile];
    
    //选中固定的片段的时长与对应长度比值
    self.lengthPreSecond = w / fragmentTime; //单位为秒s,每秒的长度
    //设置scrollView的内容及大小
    CGFloat contentWidth = self.lengthPreSecond * totalTime;
    self.scrollView.contentSize = CGSizeMake(contentWidth, viewHeight);
    NSInteger totalCount = ceilf(totalTime / timePreFrame);
    CGFloat widthPreFame = x;
    for (int i = 0; i < totalCount; i++) {
        NSTimeInterval curtime;
        if (i == totalCount -1) {
            //最后一张图片
            curtime = totalTime-0.1;
        }
        else{
            curtime = timePreFrame * (i + 1);
        }
        [self thumbnailImageAtTime:curtime image:^(UIImage *image) {
            CGFloat w = widthPreFame;
            if (i == totalCount -1) {
                //最后一张图片
                w = contentWidth - (totalCount -1)*widthPreFame;
            }
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * widthPreFame, 0, w, h)];
             imageView.image = image;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            [self.scrollView addSubview:imageView];
            
        }];
    }
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //滑动限制左端的开始点位置，确定为00:00起点，或者倒数排除片段长度的起点
//    NSTimeInterval startTemp = scrollView.contentOffset.x / self.lengthPreSecond;
//    if (startTemp < 0) {
//        startTemp = 0;
//    }
//    if (startTemp > totalTime - fragmentTime) {
//        startTemp = totalTime - fragmentTime;
//    }
//    NSLog(@"拖动ScrollView:%.3f",startTemp);
//    self.videoRePlayBlock(startTemp, fragmentTime, NO);
//}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    NSLog(@"scrollViewDidEndDragging");
//    [self scrollViewDidEnd];
//}
//
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidEndScrollingAnimation");
//    [self scrollViewDidEnd];
//}
//
//- (void)scrollViewDidEnd
//{
//    NSTimeInterval startTemp = self.scrollView.contentOffset.x / self.lengthPreSecond;
//    if (startTemp < 0) {
//        startTemp = 0;
//    }
//    if (startTemp > totalTime - fragmentTime) {
//        startTemp = totalTime - fragmentTime;
//    }
//    self.videoRePlayBlock(startTemp, fragmentTime, YES);
//}

#pragma mark - CollectionViewDelegate&DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return frameCellTotal;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FrameCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    if (indexPath.row == 0) {
        //首张空白
        cell.backgroundColor = [UIColor blackColor];
        [cell.frameImageView setImage:nil];
    }
    else if (indexPath.row == frameCellTotal - 1)
    {
        //最后一张空白
        cell.backgroundColor = [UIColor blackColor];
        [cell.frameImageView setImage:nil];
    }
    else{
        cell.backgroundColor = [UIColor orangeColor];
        NSTimeInterval curtime;
        if (indexPath.row == frameCellTotal - 2) {
            //最后一张图片
            curtime = totalTime-0.5;
        }
        else{
            curtime = timePreFrame * indexPath.row;
        }
        __weak typeof(self) weakSelf = self;
//        dispatch_async( self.thumbQueue, ^{
            [self thumbnailImageAtTime:curtime image:^(UIImage *image) {
                CGFloat w = weakSelf.widthPreFrame;
                if (indexPath.row == self->frameCellTotal - 2) {
                    //最后一张图片
                    w = weakSelf.videoLengthValue - (self->frameCellTotal - 3) * weakSelf.widthPreFrame;
                }
                
                [cell.frameImageView setImage:image];
                
            }];
//        });
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float cellWidth = frameCellWidthValue;
    float cellHeight = CGRectGetHeight(self.frame);
    return (CGSize){cellWidth,cellHeight};
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //滑动限制左端的开始点位置，确定为00:00起点，或者倒数排除片段长度的起点
    NSTimeInterval startTemp = scrollView.contentOffset.x / self.lengthPreSecond;
    if (startTemp < 0) {
        startTemp = 0;
    }
    if (startTemp > totalTime - fragmentTime) {
        startTemp = totalTime - fragmentTime;
    }
    NSLog(@"拖动ScrollView:%.3f",startTemp);
    self.videoRePlayBlock(startTemp, fragmentTime, NO);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging");
    [self scrollViewDidEnd];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndDecelerating");
    [self scrollViewDidEnd];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidEndScrollingAnimation");
    [self scrollViewDidEnd];
}

- (void)scrollViewDidEnd
{
    CGFloat offsetX;
    if (self.collectionView.contentOffset.x > self.videoLengthValue - 4 * self.widthPreFrame) {
        offsetX = self.videoLengthValue - 4 * self.widthPreFrame;
    }
    else{
        offsetX = self.collectionView.contentOffset.x;
    }
    NSTimeInterval startTemp = offsetX / self.lengthPreSecond;
    if (startTemp < 0) {
        startTemp = 0;
    }
    if (startTemp > totalTime - fragmentTime - 0.2) {
        startTemp = totalTime - fragmentTime - 0.2;
    }
    
    self.videoRePlayBlock(startTemp, fragmentTime, YES);
}

#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.layer.masksToBounds = NO;
    }
    return _scrollView;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(self.frame.size.height, self.frame.size.height);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[FrameCell class] forCellWithReuseIdentifier:cellId];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        //_collectionView.layer.masksToBounds = NO;
        _collectionView.bounces = YES;
    }
    return _collectionView;
}


- (void)setStartPointTime:(NSTimeInterval)startPointTime
{
    _startPointTime = startPointTime;
    //设置scrollView偏移到播放位置
    //__weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
       
        CGFloat offsetX = startPointTime * self.lengthPreSecond;
        
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        
    });
}

@end

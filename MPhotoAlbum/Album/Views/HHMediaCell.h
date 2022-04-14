//
//  HHMediaCell.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/15.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"

typedef void(^LongPressGestureBlock)(BOOL enable ,NSInteger section,NSInteger row);

@interface HHMediaCell : UICollectionViewCell<UIGestureRecognizerDelegate>

//预览图的imageV
@property (nonatomic, strong) UIImageView *thumbImageView;
//居中位置的播放图片
@property (nonatomic, strong) UIImageView *playImageView;
//显示选中状态的imageV
@property (nonatomic, strong) UIImageView *selectStateImageView;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) NSInteger indexSection; //在哪一个section
 
@property (nonatomic, assign) NSInteger indexRow; //在section的哪一个位置row

@property (nonatomic, copy) LongPressGestureBlock gestureBlock;

- (void)displayModelDataWithModel:(LocalAssetModel *)model;

@end


//
//  OptionalCell.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/8.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"
#import "EditTemplateModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OptionalCell : UICollectionViewCell

@property (nonatomic, strong) LocalAssetModel *model;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) EditUnitModel *editUnitModel;

- (void)displayCellWithModel:(LocalAssetModel *)model templateModel:(EditUnitModel *)editModel;

@end

NS_ASSUME_NONNULL_END

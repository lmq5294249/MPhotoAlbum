//
//  GuideTableViewCell.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/17.
//

#import <UIKit/UIKit.h>
#import "GuideDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface GuideTableViewCell : UITableViewCell

@property (nonatomic, strong) GuideDataModel *dataModel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *chooseImageView;
@property (nonatomic, strong) UIView *SeparatorLine;

@end

NS_ASSUME_NONNULL_END

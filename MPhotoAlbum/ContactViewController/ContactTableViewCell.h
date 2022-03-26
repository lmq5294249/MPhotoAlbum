//
//  ContactTableViewCell.h
//
//  Created by linmanqin on 2021/8/4.
//

#import <UIKit/UIKit.h>
#import "ContactDataModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ContactTableViewCell : UITableViewCell
@property (nonatomic, strong) ContactDataModel *dataModel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailsLable;
@property (nonatomic, strong) UIImageView *chooseImageView;
@property (nonatomic, strong) UIView *SeparatorLine;

-(void)setDetailLabeFrame:(NSInteger)lineNum;

@end

NS_ASSUME_NONNULL_END

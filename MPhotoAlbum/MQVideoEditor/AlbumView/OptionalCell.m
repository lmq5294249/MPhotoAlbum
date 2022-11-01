//
//  OptionalCell.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/8.
//

#import "OptionalCell.h"

@implementation OptionalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.backgroundView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        self.backgroundView.layer.cornerRadius = self.frame.size.width / 5;
        self.backgroundView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.backgroundView];
        
        self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.thumbImageView.backgroundColor = [UIColor clearColor];
        self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.thumbImageView];
        self.thumbImageView.layer.cornerRadius = self.frame.size.width / 8;
        self.thumbImageView.layer.masksToBounds = YES;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.text = @"4s";
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    self.thumbImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)displayCellWithModel:(LocalAssetModel *)model templateModel:(EditUnitModel *)editModel
{
    _model = model;
    [self.thumbImageView setImage:model.propertyThumbImage];
    if (model.isSelect) {
        self.backgroundView.backgroundColor = [UIColor orangeColor];
    }
    else{
        self.backgroundView.backgroundColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    
    if (editModel) {
        self.timeLabel.text = [NSString stringWithFormat:@"%.1fs",editModel.mediaDuration];
    }
}

@end

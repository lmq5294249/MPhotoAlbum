//
//  GuideTableViewCell.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/17.
//

#import "GuideTableViewCell.h"

@implementation GuideTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        CGFloat fitRatio = [self getFitLengthRatio];
        CGFloat w = CGRectGetWidth(self.frame);
        self.SeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(17, 1, self.frame.size.width - 34, 1)];
        self.SeparatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.SeparatorLine.backgroundColor = [UIColor lightGrayColor];
        self.SeparatorLine.alpha = 0.4;
        [self.contentView addSubview:self.SeparatorLine];
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((68 - 32*fitRatio)/2, 16*fitRatio, 32*fitRatio, 32*fitRatio)];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.iconImageView];
        self.chooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(w - 24 - 16*fitRatio, 21*fitRatio, 22*fitRatio, 22*fitRatio)];
        self.chooseImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.chooseImageView];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(68*fitRatio, 21*fitRatio, 160*fitRatio, 22*fitRatio)];
        [self.contentView addSubview:self.titleLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //MARK:设置布局
    CGFloat fitRatio = [self getFitLengthRatio];
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    self.iconImageView.frame = CGRectMake((68 - 32)*fitRatio/2, (h - 32*fitRatio)/2, 32*fitRatio, 32*fitRatio);
    self.chooseImageView.frame = CGRectMake(w - 12 - 16*fitRatio, (h - 22*fitRatio)/2, 8*fitRatio, 18*fitRatio);
    self.titleLabel.frame = CGRectMake(68*fitRatio, (h - 22*fitRatio)/2, 160*fitRatio, 22*fitRatio);
}

- (CGFloat)getFitLengthRatio{

    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return min / 375.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    //[UIPasteboard generalPasteboard].string = self.dataModel.titleString;

    // Configure the view for the selected state
}

@end

//
//  ContactTableViewCell.m
//
//  Created by linmanqin on 2021/8/4.
//

#import "ContactTableViewCell.h"
#import "TationDeviceManager.h"

@interface ContactTableViewCell ()

@property (nonatomic, assign) CGFloat fitRatio;

@end

@implementation ContactTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.fitRatio = [self getFitLengthRatio];
        CGFloat w = CGRectGetWidth(self.frame);
        self.SeparatorLine = [[UIView alloc] initWithFrame:CGRectMake(17, 1, self.frame.size.width - 34, 1)];
        self.SeparatorLine.backgroundColor = [UIColor lightGrayColor];
        self.SeparatorLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.SeparatorLine.alpha = 0.4;
        [self.contentView addSubview:self.SeparatorLine];
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((96 - 32*_fitRatio)/2, 12*_fitRatio, 32*_fitRatio, 32*_fitRatio)];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.iconImageView];
        self.chooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(w - 24 - 16*_fitRatio, 16*_fitRatio, 24*_fitRatio, 24*_fitRatio)];
        self.chooseImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.chooseImageView];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(68*_fitRatio, 16*_fitRatio, 160*_fitRatio, 22)];
        [self.contentView addSubview:self.titleLabel];
        self.detailsLable = [[UILabel alloc] initWithFrame:CGRectMake(68*_fitRatio, 36*_fitRatio, 235*_fitRatio, 36)];
        self.detailsLable.numberOfLines = 3;
        [self.contentView addSubview:self.detailsLable];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat w = CGRectGetWidth(self.frame);
    CGFloat h = CGRectGetHeight(self.frame);
    
    if (h > 100) {
        self.titleLabel.frame = CGRectMake(68*_fitRatio, 21*_fitRatio, 160*_fitRatio, 22);
        self.detailsLable.frame = CGRectMake(68*_fitRatio, 49*_fitRatio, 235*_fitRatio, 36);
        //设置文本后以标题文本作为参考点
        CGPoint titleLabelCenter = self.titleLabel.center;
        [self.iconImageView setCenter:CGPointMake(68*_fitRatio/2.0, titleLabelCenter.y)];
        self.chooseImageView.frame = CGRectMake(w - 12 - 16*_fitRatio, 26*_fitRatio, 8*_fitRatio, 18*_fitRatio);
        [self.chooseImageView setCenter:CGPointMake(w - 12 - 16*_fitRatio, titleLabelCenter.y)];
    }
    else{
        self.titleLabel.frame = CGRectMake(68*_fitRatio, 16*_fitRatio, 160*_fitRatio, 22);
        self.detailsLable.frame = CGRectMake(68*_fitRatio, 40*_fitRatio, 235*_fitRatio, 36);
        CGPoint titleLabelCenter = self.titleLabel.center;
        [self.iconImageView setCenter:CGPointMake(68*_fitRatio/2.0, titleLabelCenter.y)];
        self.chooseImageView.frame = CGRectMake(w - 12 - 16*_fitRatio, 16*_fitRatio, 8*_fitRatio, 18*_fitRatio);
        [self.chooseImageView setCenter:CGPointMake(w - 12 - 16*_fitRatio, titleLabelCenter.y)];
    }
}

- (void)setDetailLabeFrame:(NSInteger)lineNum
{
    self.detailsLable.frame = CGRectMake(68*_fitRatio, 36*[self getFitLengthRatio], CGRectGetWidth(self.detailsLable.frame), lineNum * CGRectGetHeight(self.titleLabel.frame));
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

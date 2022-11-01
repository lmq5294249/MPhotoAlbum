//
//  MQDragingCell.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/8.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MQDragingCell.h"

@interface MQDragingCell ()

@property (nonatomic, strong) CAShapeLayer *borderLayer;

@end


@implementation MQDragingCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
    }
    
    return self;
}

- (void)setUpUI
{
    self.userInteractionEnabled = YES;
    self.layer.cornerRadius = 5.0f;
    self.backgroundColor = [self backgroundColor];
    
    _thumbImageView = [[UIImageView alloc] init];
    _thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_thumbImageView];
    
    _editImageView = [[UIImageView alloc] init];
    [_editImageView setImage:[UIImage imageNamed:@"VideoEdit"]];
    [self.contentView addSubview:_editImageView];
    
//    self.timeLabel = [[UILabel alloc] init];
//    self.timeLabel.backgroundColor = [UIColor clearColor];
//    self.timeLabel.text = @"0s";
//    self.timeLabel.textAlignment = NSTextAlignmentCenter;
//    self.timeLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
//    [self.contentView addSubview:self.timeLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat iconImageH = self.bounds.size.height;
    CGFloat iconImageW = self.bounds.size.width;
    _thumbImageView.frame = CGRectMake(0, 0, iconImageW, iconImageH);
    _thumbImageView.layer.cornerRadius = 5.0;
    _thumbImageView.clipsToBounds = YES;
    
    CGFloat editImageW = iconImageW - 15*2;
    CGFloat editImageH = iconImageH - 15*2;
    
    _editImageView.frame = CGRectMake(15, 15, editImageW, editImageH);
    _editImageView.alpha = 0.8;
    _timeLabel.frame = CGRectMake(0, 0, iconImageW, iconImageH);
}

- (void)setThumbImage:(UIImage *)thumbImage
{
    _thumbImage = thumbImage;
    _thumbImageView.image = _thumbImage;
}

#pragma mark 配置方法

-(UIColor*)backgroundColor{
    return [UIColor clearColor];
}

-(UIColor*)textColor{
    return [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1];
}

-(UIColor*)lightTextColor{
    return [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
}


@end

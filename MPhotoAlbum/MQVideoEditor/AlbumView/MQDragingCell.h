//
//  MQDragingCell.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/8.
//  Copyright © 2021 mac. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MQDragingCell : UICollectionViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, strong) UIImage *editImage;

@property (nonatomic, strong) UIImage *thumbImage;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *editImageView;

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, assign) BOOL isMoving; //是否正在移动状态

@property (nonatomic, assign) BOOL isFixed; //是否不可移动

@end



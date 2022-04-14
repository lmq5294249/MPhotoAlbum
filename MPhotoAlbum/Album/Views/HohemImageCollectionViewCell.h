//
//  HohemImageCollectionViewCell.h
//  Hohem Pro
//
//  Created by jolly on 2019/11/28.
//  Copyright © 2019 jolly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaPlayerView.h"
#import "LocalAssetModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol HohemImageCollectionViewCellDelegate;

@interface HohemImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id <HohemImageCollectionViewCellDelegate>delegate;

@property (nonatomic, weak) id controller;

@property (nonatomic, strong) LocalAssetModel *assetModel;

@property (nonatomic, assign) BOOL hiddenSlideView;

- (void)updateImageWithImage:(UIImage *)image;
- (void)showPlayBtn:(BOOL)isShow;
- (void)videoStopPlay;
- (void)setScrollViewZoomScale;

@end

@protocol HohemImageCollectionViewCellDelegate <NSObject>

- (void)HohemImageCollectionViewCellDelegate:(HohemImageCollectionViewCell *)cell functionStr:(NSString *)functionStr value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

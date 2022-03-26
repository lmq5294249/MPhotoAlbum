//
//  HohemAlbumPlayViewController.h
//  Hohem Pro
//
//  Created by jolly on 2020/4/15.
//  Copyright © 2020 jolly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HohemAlbumPlayViewController : UIViewController

//播放视频链接
@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) PHAsset *asset;

@end

NS_ASSUME_NONNULL_END

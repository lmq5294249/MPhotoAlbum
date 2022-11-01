//
//  MVideoToolControlView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/15.
//

#import <UIKit/UIKit.h>
#import "MVideoPlayerView.h"
#import "MVideoPreviewView.h"

typedef void(^SliderChangeValueBlock)(NSTimeInterval pointInTime, BOOL finish);

NS_ASSUME_NONNULL_BEGIN

@interface MVideoToolControlView : UIView<MVideoPlayerDelegate,MVideoPreviewDelegate>

@property (nonatomic, strong) UILabel *leftTimeLabel;

@property (nonatomic, strong) UILabel *rightTimeLabel;

@property (nonatomic, strong) UISlider *timeSlider;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, copy) SliderChangeValueBlock sliderChangeValueBlock;

@property (nonatomic, assign) BOOL isDragEnable;

- (void)resetVideoTool;

@end

NS_ASSUME_NONNULL_END

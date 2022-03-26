//
//  MediaPlayerView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/22.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol MediaPlayerDelegate <NSObject>

@optional
- (void)hiddenControlView:(BOOL)isHidden;
@end


@interface MediaPlayerView : UIView

@property (nonatomic, weak) id<MediaPlayerDelegate> delegate;
@property (nonatomic, strong) LocalAssetModel *assetModel;


- (void)videoPlayerPlay;
- (void)videoPlayerPause;
- (void)videoPlayerStop;
- (void)hiddenSlideView:(BOOL)isHidden;
@end

NS_ASSUME_NONNULL_END

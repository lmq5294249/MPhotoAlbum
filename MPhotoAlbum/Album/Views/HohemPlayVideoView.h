//
//  HohemPlayVideoView.h
//  Hohem Pro
//
//  Created by jolly on 2019/11/28.
//  Copyright © 2019 jolly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HohemPlayVideoViewDelegate;

@interface HohemPlayVideoView : UIView

@property (nonatomic, weak) id <HohemPlayVideoViewDelegate>delegate;

- (void)updateVideoUrl:(NSURL *)videoUrl;

@end

@protocol HohemPlayVideoViewDelegate <NSObject>

- (void)HohemPlayVideoViewDelegate:(HohemPlayVideoView *)playView function:(NSString *)function value:(NSString *)value;

@end

NS_ASSUME_NONNULL_END

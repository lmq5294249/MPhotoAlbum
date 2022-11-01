//
//  MQVideoEditor.h
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//  Copyright © 2022 lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "EditTemplateModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MQVideoEditor : NSObject

@property (nonatomic, copy) NSArray<AVURLAsset *> *clips;
@property (nonatomic, copy) NSArray *clipTimeRanges;
@property (nonatomic) CMTime transitionDuration;

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) EditTemplateModel *templateModel;

@property (nonatomic, strong) NSMutableArray *paramModelArray;
@property (nonatomic, strong) NSMutableArray *transTimeArray;

- (void)buildCompositionObjectsForPlayback;
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;
- (AVPlayerItem *)playerItem;

@end

NS_ASSUME_NONNULL_END

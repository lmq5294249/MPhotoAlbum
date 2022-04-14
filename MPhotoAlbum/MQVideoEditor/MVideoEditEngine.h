//
//  MVideoEditEngine.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/3.
//  Copyright © 2021 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>
#import "VideoEditorParamTypeHeader.h"
#import "MediaAssetModel.h"

@class AVPlayerItem, AVAssetExportSession;


@interface MVideoEditEngine : NSObject

// Set these properties before building the composition objects.
@property (nonatomic, copy) NSArray *clips; // array of AVURLAssets
@property (nonatomic, copy) NSArray *clipTimeRanges; // array of CMTimeRanges stored in NSValues.

@property (nonatomic) NSInteger transitionType;
@property (nonatomic) CMTime transitionDuration;

@property (nonatomic, assign) SpeedType speedType; //Variable speed setting value

@property (nonatomic) CGSize screenSize;

@property (nonatomic, strong) NSMutableArray *gifImageArray;

// Builds the composition and videoComposition
- (void)buildCompositionObjectsForPlayback:(BOOL)forPlayback;

- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName;

- (AVPlayerItem *)playerItem;

- (void)trimStartVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete; 
- (void)trimMiddleVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete;
- (void)trimEndVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete;


// Builds the composition and videoComposition
- (void)buildCompositionObjectsForExploreVideo;

@end


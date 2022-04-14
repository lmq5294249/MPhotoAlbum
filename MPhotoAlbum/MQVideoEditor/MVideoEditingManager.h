//
//  MVideoEditingManager.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/15.
//  Copyright © 2021 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MVideoEditEngine.h"
#import "VideoEditorParamTypeHeader.h"

@interface MVideoEditingManager : NSObject

@property (nonatomic, strong) NSMutableArray *gifImageArray;

- (void)startEditVideo:(VideoAssetModel *)videoModel VideoAssetClip:(NSMutableArray*)videoClips ClipTimeRanges:(NSMutableArray*)videoclipTimeRanges VideoProgram:(VideoProgram)videoStage completionHandler:(void(^)(NSURL *))block;

- (void)exporeResultVideo:(NSString *)videoName videoAssetClip:(NSMutableArray*)videoClips completionHandler:(void(^)(NSURL *))block;

@end

//
//  MVideoEditingManager.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/15.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MVideoEditingManager.h"
#import <AVFoundation/AVFoundation.h>

//path
#define CACAHPAtH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface MVideoEditingManager ()

@end

@implementation MVideoEditingManager



- (void)startEditVideo:(VideoAssetModel *)videoModel VideoAssetClip:(NSMutableArray*)videoClips ClipTimeRanges:(NSMutableArray*)videoclipTimeRanges VideoProgram:(VideoProgram)videoStage completionHandler:(void(^)(NSURL *))block
{
    MVideoEditEngine *videoClipEditor = [[MVideoEditEngine alloc] init];
    videoClipEditor.clips = videoClips;
    videoClipEditor.clipTimeRanges = videoclipTimeRanges;
    //videoClipEditor.transitionDuration = _transitionDuration;
    videoClipEditor.speedType = videoModel.videoSpeedType;
    
    NSString *newVideoName;
    if (videoStage == VideoProgramForEditing) {
        if (videoModel.editingVideoUrl) {
            //已经存在编辑了的连接时，再次编辑需要修改名字
            newVideoName = [self getEditVideoPrefixNameFromVideoUrl:videoModel.editingVideoUrl needTempFlag:YES];
        }
        else{
            newVideoName = [self getEditVideoPrefixNameFromVideoUrl:videoModel.originalVideoUrl needTempFlag:NO];
        }
        
    }
    else if (videoStage == VideoProgramForMerging)
    {
        newVideoName = [self getMergeVideoPrefixNameFromVideoUrl:videoModel.originalVideoUrl];
    }
    else{
        newVideoName = [self getNewVideoPrefixNameFromVideoUrl:videoModel.originalVideoUrl];
    }

    [self videoEditor:videoClipEditor exportVideo:newVideoName withBlock:^(NSURL *videoUrl) {
        if (videoUrl) {
            block(videoUrl);
        }
    }];
}

- (void)exporeResultVideo:(NSString *)videoName videoAssetClip:(NSMutableArray*)videoClips completionHandler:(void(^)(NSURL *))block
{
    MVideoEditEngine *videoExpore = [[MVideoEditEngine alloc] init];
    videoExpore.gifImageArray = self.gifImageArray;
    videoExpore.clips = videoClips;
    videoExpore.clipTimeRanges = [NSMutableArray array];
    videoExpore.speedType = SpeedTypeNormal;

    [videoExpore buildCompositionObjectsForExploreVideo];
    
    AVAssetExportSession *session = [videoExpore assetExportSessionWithPreset:AVAssetExportPreset1920x1080];
    NSString *filePath = [self getImageToVideoFilePathStringWithImageName:videoName];
    
    session.outputURL = [NSURL fileURLWithPath:filePath];
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"成功");
                NSURL *outputURL = session.outputURL;
                block(outputURL);
            }else{
                NSLog(@"失败--%@",session.error);
            }
        });
    }];
}

- (void)videoEditor:(MVideoEditEngine *)videoClipEditor exportVideo:(NSString *)videoName withBlock:(void(^)(NSURL *))finishBlock
{
    [videoClipEditor buildCompositionObjectsForPlayback:NO];
    
    AVAssetExportSession *session = [videoClipEditor assetExportSessionWithPreset:AVAssetExportPreset1920x1080];
    // Remove the file if it already exists
//    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
//    [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    NSString *filePath = [self getImageToVideoFilePathStringWithImageName:videoName];
    

    session.outputURL = [NSURL fileURLWithPath:filePath];
    session.outputFileType = AVFileTypeMPEG4;
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"成功");
                NSURL *outputURL = session.outputURL;
                finishBlock(outputURL);
            }else{
                NSLog(@"失败--%@",session.error);
            }
        });
    }];
}


#pragma mark - Public
-(NSString *)getNewVideoPrefixNameFromVideoUrl:(NSURL *)videoUrl
{
    NSString *videoFileString = [videoUrl absoluteString];
    NSString *originVideoString = [[videoFileString lastPathComponent] stringByDeletingPathExtension];
    NSString *pathStr = [[videoFileString lastPathComponent] pathExtension];
    NSString *newVideoName = [NSString stringWithFormat:@"%@NVP",originVideoString];
    return newVideoName;
}

-(NSString *)getEditVideoPrefixNameFromVideoUrl:(NSURL *)videoUrl needTempFlag:(BOOL)flag
{
    NSString *videoFileString = [videoUrl absoluteString];
    NSString *originVideoString = [[videoFileString lastPathComponent] stringByDeletingPathExtension];
    NSString *pathStr = [[videoFileString lastPathComponent] pathExtension];
    NSString *newVideoName;
    if (flag) {
        newVideoName = [NSString stringWithFormat:@"%@Tmp",originVideoString];//后面再编辑
    }
    else{
        newVideoName = [NSString stringWithFormat:@"%@Edit",originVideoString]; //第一次编辑
    }
    
    return newVideoName;
}

-(NSString *)getMergeVideoPrefixNameFromVideoUrl:(NSURL *)videoUrl
{
    NSString *videoFileString = [videoUrl absoluteString];
    NSString *originVideoString = [[videoFileString lastPathComponent] stringByDeletingPathExtension];
    NSString *pathStr = [[videoFileString lastPathComponent] pathExtension];
    NSString *newVideoName = [NSString stringWithFormat:@"%@Merge",originVideoString];
    return newVideoName;
}

- (NSString *)getImageToVideoFilePathStringWithImageName:(NSString *)imageName
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoPath = [DOCUMENTPATH stringByAppendingPathComponent:@"VideoTemp"];
    if (![fileManager fileExistsAtPath:videoPath]) {
        NSError *error;
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:NO attributes:nil error:&error];
        //NSLog(videoPath);
    }
    
    NSString *path = [DOCUMENTPATH stringByAppendingPathComponent:@"VideoTemp"];
    
    if (![fileManager fileExistsAtPath:path]) {
        NSError *error;
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
        //NSLog(path);
    }
    NSString *videoFilePath = [[path stringByAppendingPathComponent:imageName] stringByAppendingString:@".mp4"];
    if ([fileManager fileExistsAtPath:videoFilePath]) {
        NSError *error;
        [fileManager removeItemAtPath:videoFilePath error:&error];
        //NSLog(path);
    }
    return videoFilePath;
}


@end

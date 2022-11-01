//
//  MQVideoExportManager.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/17.
//

#import "MQVideoExportManager.h"
#import "MQVideoEditor.h"
#import <AVFoundation/AVFoundation.h>

//path
#define CACAHPAtH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]


@interface MQVideoExportManager ()

@end

@implementation MQVideoExportManager

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)exporeResultVideo:(NSString *)videoName completionHandler:(void(^)(NSURL *))block
{
    MQVideoEditor *videoExpore = [[MQVideoEditor alloc] init];
    videoExpore.clips = self.clips;
    videoExpore.clipTimeRanges = self.clipTimeRanges;
    videoExpore.transTimeArray = self.transTimeArray;
    videoExpore.templateModel = self.templateModel;

    [videoExpore buildCompositionObjectsForPlayback];
    
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

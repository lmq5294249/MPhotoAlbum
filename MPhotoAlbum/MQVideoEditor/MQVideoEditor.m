//
//  MQVideoEditor.m
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//  Copyright © 2022 lin. All rights reserved.
//

#import "MQVideoEditor.h"
#import <CoreMedia/CoreMedia.h>
#import "MQCustomVideoCompositionInstruction.h"
#import "MQVideoComposition.h"

typedef enum {
    MQVideoOrientationUp,               //Device starts recording in Portrait
    MQVideoOrientationDown,             //Device starts recording in Portrait upside down
    MQVideoOrientationLeft,             //Device Landscape Left  (home button on the left side)
    MQVideoOrientationRight,            //Device Landscape Right (home button on the Right side)
    MQVideoOrientationNotFound = 99     //An Error occurred or AVAsset doesn't contains video track
} MQVideoOrientation;

static inline CGFloat RadiansToDegrees(CGFloat radians) {
    return radians * 180 / M_PI;
};

@interface MQVideoEditor ()

@property (nonatomic) CGSize videoSize;

@property (nonatomic, assign) CGFloat scalableValue; //缩放比例系数

@end

@implementation MQVideoEditor

- (void)buildCompositionObjectsForPlayback
{
    if ( (self.clips == nil) || [self.clips count] == 0 ) {
        self.composition = nil;
        self.videoComposition = nil;
        return;
    }
    
    _videoSize = [[self.clips objectAtIndex:0] naturalSize];
    
    //这里判断视频的分辨率，进行比例调整
    if (_videoSize.width > 1920) {
        //横屏模式下
        _scalableValue = 1920.0 / _videoSize.width;
        _videoSize = CGSizeMake(1920, _scalableValue * _videoSize.height);
        
    }
    else{
        if (_videoSize.height > 1920) {
            //竖屏模式下
            _scalableValue = 1920.0 / _videoSize.height;
            _videoSize = CGSizeMake(_scalableValue * _videoSize.width, 1920);
            
        }
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = nil;
    _videoSize = CGSizeMake(1920, 1080);
    
    //混合拼接
    videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.customVideoCompositorClass = [MQVideoComposition class];
//    [self buildSequenceComposition:composition andVideoComposition:videoComposition];
    [self buildTransitionComposition:composition andVideoComposition:videoComposition];
    
    //[self buildTransitionComposition:composition];
    //videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    
    
    
    videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
    videoComposition.renderSize = _videoSize;
    self.videoComposition = videoComposition;
    
}

- (void)buildSequenceComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    NSUInteger clipsCount = [self.clips count];

    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加视频轨道0
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加视频轨道1
//    compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加音频轨道0
//    compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加音频轨道1
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    CMTime transitionDuration = CMTimeMake(1000, 1000);
    
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [self.clips objectAtIndex:i];
        NSValue *clipTimeRange = [self.clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange) {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else {
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        NSError* error;
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:&error];
        
        NSLog(@"video track %ld, insert start:%lf, length:%lf, at time:%lf", alternatingIndex, CMTimeGetSeconds(timeRangeInAsset.start), CMTimeGetSeconds(timeRangeInAsset.duration), CMTimeGetSeconds(nextClipStartTime));
        
//        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        
        
        // 计算下一个插入点
        //passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration); // 加上持续时间

    }
    
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets
        
        // Pass through clip i.
//        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//        passThroughInstruction.timeRange = passThroughTimeRanges[i];
//
//        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
//
//
//        CGAffineTransform transform = [self makeTransformForAsset:i];
//
//        CMTimeRange passTimeRange = passThroughTimeRanges[i];
//        [passThroughLayer setTransform:transform atTime:passTimeRange.start];
//
//        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
//        [instructions addObject:passThroughInstruction];
        
        //MQCustomVideoCompositionInstruction *videoInstruction = [[MQCustomVideoCompositionInstruction alloc] initPassThroughTrackID:compositionVideoTracks[alternatingIndex].trackID forTimeRange:passThroughTimeRanges[i]];
        
//        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"Value",@"1",@"rotateDirection",nil];
//        MQCustomVideoCompositionInstruction *videoInstruction = [[MQCustomVideoCompositionInstruction alloc] initWithSourceTrackIDs:@[[NSNumber numberWithInt:compositionVideoTracks[alternatingIndex].trackID]] shaderType:i paramDic:dic forTimeRange:passThroughTimeRanges[i]];
//        videoInstruction.foregroundTrackID = compositionVideoTracks[alternatingIndex].trackID;
//        [instructions addObject:videoInstruction];
        
        
    }
    

    videoComposition.instructions = instructions;
    
    self.composition = composition;
}

- (void)buildTransitionComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    NSUInteger clipsCount = [self.clips count];

    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[3];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加视频轨道0
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加视频轨道1
    compositionVideoTracks[2] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid]; //
    compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加音频轨道0
    compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid]; // 添加音频轨道1
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [self.clips objectAtIndex:i];
        NSValue *clipTimeRange = [self.clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange) {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else {
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        double transValue = [(NSNumber *)self.transTimeArray[i] doubleValue];
        CMTime transitionDuration = CMTimeMake(transValue * 1000, 1000);
        
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        NSError* error;
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:&error];
        
        NSLog(@"video track %ld, insert start:%lf, length:%lf, at time:%lf", alternatingIndex, CMTimeGetSeconds(timeRangeInAsset.start), CMTimeGetSeconds(timeRangeInAsset.duration), CMTimeGetSeconds(nextClipStartTime));
        
//        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:&error];
        
        
        // 计算下一个插入点
        //passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        if (i > 0) {
            double lastTransValue = [(NSNumber *)self.transTimeArray[i - 1] doubleValue];
            CMTime lastTransitionDuration = CMTimeMake(lastTransValue * 1000, 1000);
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, lastTransitionDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, lastTransitionDuration);
        }
        if (i+1 < clipsCount) {
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration); // 加上持续时间
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, transitionDuration); // 减去变换时间，得到下一个插入点
        
        // Remember the time range for the transition to the next item.
        if (i+1 < clipsCount) {
            transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, transitionDuration);
        }
    }
    
    //这里注意音频时间长度不应该比视频的还长，否则会出现后面的playItem播放加载错误情况
    //如果非要延长音频时间那么可以选择先先延长视频时间，两者先判断后再取舍
    //所以目前这里先用nextClipStartTime来处理,进行加减处理
//    for (int i = 0; i < _musicArray.count; i++) {
//        MusicSelectedModel *model = self.musicArray[i];
//        CMTimeRange playTimeRange = model.playTimeRange;
//        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:model.fileURL options:nil];
//        AVAssetTrack *clipAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//        CMTimeRange audioTimeRange = CMTimeRangeMake(playTimeRange.start, CMTimeSubtract(nextClipStartTime, playTimeRange.start));
//        [compositionAudioTracks[0] insertTimeRange:audioTimeRange ofTrack:clipAudioTrack atTime:playTimeRange.start error:nil];
//    }
    
    CMTime audioTime = kCMTimeZero;
    for (i = 0; i < clipsCount; i ++) {
        CMTimeRange videoTimeRange = passThroughTimeRanges[i];
        audioTime = CMTimeAdd(audioTime, videoTimeRange.duration);
        CMTimeRange tranTimeRange = transitionTimeRanges[i];
        NSTimeInterval videoDuration = CMTimeGetSeconds(tranTimeRange.duration);
        if (i < clipsCount - 1 && videoDuration > 0) {
            audioTime = CMTimeAdd(audioTime, tranTimeRange.duration);
        }
    }
    
    NSString *maskVideoName = self.templateModel.maskVideoName;
    if (![maskVideoName isEqualToString:@"empty"]) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:maskVideoName ofType:@"mp4"]]];
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        NSError* error;
    //    CMTimeRange timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        [compositionVideoTracks[2] insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioTime) ofTrack:clipVideoTrack atTime:kCMTimeZero error:&error];
    }
    
//    NSString *musicName = self.templateModel.music;
//    if (![musicName isEqualToString:@"empty"]) {
        AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"夏文娜-错位时空" ofType:@"mp3"]] options:nil];
        AVAssetTrack *clipAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTracks[0] insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioTime) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
//    }
    
    
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    
    for (i = 0; i < clipsCount; i++ ) {
        
        float transValue = [(NSNumber *)self.transTimeArray[i] doubleValue];
        EditUnitModel *model = self.templateModel.scripts[i];
        
        NSInteger alternatingIndex = i % 2; // alternating targets
        
        NSMutableArray *passArray = [NSMutableArray array];
        int orientationValue = 0;
        UIImage *testImage;
        BOOL playingImage = NO;
        if (model.mediaType == MQMediaTypePhoto) {
            testImage = model.image;
            playingImage = YES;
            orientationValue = [self getImageOrientation:testImage];
        }
        else{
            orientationValue = [self getVideoOrientationForAsset:i];
        }
        NSDictionary *passDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithLong:model.filterType],@"FilterType",
                                 [NSNumber numberWithLong:model.transitionsType],@"TransitionType",
                                 [NSNumber numberWithInt:orientationValue],@"VideoOrientation",
                                 [NSNumber numberWithFloat:transValue],@"TransitionDuration",
                                 model,@"EditUnitModel",
                                 testImage,@"ImageData",
                                 [NSNumber numberWithBool:playingImage],@"PlayImage",
                                 nil];
        [passArray addObject:passDic];
        
        if (i == 0) {
            NSDictionary *maskDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithInt:1],@"MaskVideoEffect",
                                     nil];
            [passArray addObject:maskDic];
        }
        // Pass through clip i.
        MQCustomVideoCompositionInstruction *passThroughInstruction = [[MQCustomVideoCompositionInstruction alloc]
                                                                       initWithSourceTrackIDs:@[[NSNumber numberWithInt:compositionVideoTracks[alternatingIndex].trackID],[NSNumber numberWithInt:compositionVideoTracks[2].trackID]]
                                                                       paramArray:passArray
                                                                       forTimeRange:passThroughTimeRanges[i]];
        passThroughInstruction.foregroundTrackID = compositionVideoTracks[alternatingIndex].trackID;
        passThroughInstruction.maskVideoTrackID = compositionVideoTracks[2].trackID;
        
        [instructions addObject:passThroughInstruction];
        
        if (i+1 < clipsCount) {
            //补充转场两个视频的参数数组：包括渲染的shader类型 - 渲染的方向 - 转场类型
            EditUnitModel *model = self.templateModel.scripts[i+1];
            int orientationValue2 = 0;
            UIImage *secondImage;
            BOOL playingImage = NO;
            if (model.mediaType == MQMediaTypePhoto) {
                secondImage = model.image;
                playingImage = YES;
                orientationValue2 = [self getImageOrientation:secondImage];
            }
            else{
                orientationValue2 = [self getVideoOrientationForAsset:i+1];
            }
            NSMutableArray *transitionArray = [NSMutableArray array];
            [transitionArray addObject:passDic];
            NSDictionary *transDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      [NSNumber numberWithLong:model.filterType],@"FilterType",
                                      [NSNumber numberWithLong:model.transitionsType],@"TransitionType",
                                      [NSNumber numberWithInt:orientationValue2],@"VideoOrientation",
                                      secondImage,@"ImageData",
                                      [NSNumber numberWithBool:playingImage],@"PlayImage",
                                      nil];
            [transitionArray addObject:transDic];
            
            // Add transition from clip i to clip i+1.
            MQCustomVideoCompositionInstruction *transitionInstruction = [[MQCustomVideoCompositionInstruction alloc]
                                                                          initWithSourceTrackIDs:@[[NSNumber numberWithInt:compositionVideoTracks[0].trackID],[NSNumber numberWithInt:compositionVideoTracks[1].trackID],[NSNumber numberWithInt:compositionVideoTracks[2].trackID]]
                                                                          paramArray:transitionArray
                                                                          forTimeRange:transitionTimeRanges[i]];
            
            // First track -> Foreground track while compositing
            transitionInstruction.foregroundTrackID = compositionVideoTracks[alternatingIndex].trackID;
            // Second track -> Background track while compositing
            transitionInstruction.backgroundTrackID = compositionVideoTracks[1-alternatingIndex].trackID;
            // Third track -> MaskVideo track while compositing
            transitionInstruction.maskVideoTrackID = compositionVideoTracks[2].trackID;

            [instructions addObject:transitionInstruction];
        }
        
        
        
    }
    

    videoComposition.instructions = instructions;
    
    self.composition = composition;
}

- (CGAffineTransform)makeTransformForAsset:(NSInteger)i
{
    AVURLAsset *videoAsset = [_clips objectAtIndex:i];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGFloat videoWidth = videoAssetTrack.naturalSize.width;
    CGFloat videoHeight = videoAssetTrack.naturalSize.height;

    //MARK:第一步 开始判断方向
    BOOL isVideoAssetPortrait  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        //        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        //        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait = YES;
    }

    
    NSLog(@"当前视频的大小width = %lf height = %lf",videoAssetTrack.naturalSize.width,videoAssetTrack.naturalSize.height);
    CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
    MQVideoOrientation videoOrientation = [self videoOrientationWithAsset:videoAsset];
    if (naturalSize.height > naturalSize.width) {
        //竖屏视频的宽高正常，但是方向确是横向需要修改特殊情况
        videoOrientation = MQVideoOrientationUp;
    }

    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    CGAffineTransform t3 = CGAffineTransformIdentity;

    CGFloat ratio = _videoSize.width/ videoWidth;

    NSLog(@" --- 视频转向 -- %ld",(long)videoOrientation);

    switch (videoOrientation) {
        case MQVideoOrientationUp:
        {
            CGFloat ratio;
            if (naturalSize.width > naturalSize.height) {
                //说明是虚假竖的视频
                ratio = _videoSize.height/ naturalSize.width;
                CGFloat x_offset = _videoSize.width - (_videoSize.width - (naturalSize.height*ratio))/2;
                t1 = CGAffineTransformMakeTranslation(x_offset,0);
                t2 = CGAffineTransformRotate(t1, M_PI_2);
                t3 = CGAffineTransformScale(t2, ratio, ratio);
            }
            else{
                ratio = _videoSize.height/ naturalSize.height;
                CGFloat x_offset = (_videoSize.width - (naturalSize.width*ratio))/2;
                t1 = CGAffineTransformMakeTranslation(x_offset,0);
                t2 = CGAffineTransformRotate(t1, 0);
                t3 = CGAffineTransformScale(t2, ratio, ratio);
            }
        }
            break;

        case MQVideoOrientationDown:
            t1 = CGAffineTransformMakeTranslation(0,0);
            t2 = CGAffineTransformRotate(t1, 0);
            t3 = CGAffineTransformScale(t2, 1.0, 1.0);
            break;

        case MQVideoOrientationLeft:

            t1 = CGAffineTransformMakeTranslation(_videoSize.width,_videoSize.height);
            t2 = CGAffineTransformRotate(t1, M_PI);
            t3 = CGAffineTransformScale(t2, _scalableValue, _scalableValue);
            break;

        case MQVideoOrientationRight:


            t1 = CGAffineTransformMakeTranslation(0,0);
            t2 = CGAffineTransformRotate(t1, 0);
            t3 = CGAffineTransformScale(t2, ratio, ratio);
            break;

        default:
            t1 = CGAffineTransformMakeTranslation(0,0);
            t2 = CGAffineTransformRotate(t1, 0);
            t3 = CGAffineTransformScale(t2, 1.0, 1.0);
            break;
    }
    
    return t3;
}

- (int)getVideoOrientationForAsset:(NSInteger)i
{
    int orientationValue; //后面再添加枚举定义
    
    AVURLAsset *videoAsset = [_clips objectAtIndex:i];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    //MARK:第一步 开始判断方向
    
    NSLog(@"当前视频的大小width = %lf height = %lf",videoAssetTrack.naturalSize.width,videoAssetTrack.naturalSize.height);
    CGSize naturalSize = CGSizeMake(videoAssetTrack.naturalSize.width, videoAssetTrack.naturalSize.height);
    MQVideoOrientation videoOrientation = [self videoOrientationWithAsset:videoAsset];
    if (naturalSize.height > naturalSize.width) {
        //竖屏视频的宽高正常，但是方向确是横向需要修改特殊情况
        videoOrientation = MQVideoOrientationUp;
    }

    switch (videoOrientation) {
        case MQVideoOrientationUp:
        {
            CGFloat ratio;
            if (naturalSize.width > naturalSize.height) {
                //说明是虚假竖的视频
                orientationValue = 2;
            }
            else{
                orientationValue = 1;
            }
        }
            break;

        case MQVideoOrientationDown:
            orientationValue = 1;
            break;

        case MQVideoOrientationLeft:
            //数据反转180°
            orientationValue = 3;
            break;

        case MQVideoOrientationRight:
            orientationValue = 0;
            break;

        default:
            orientationValue = 0;
            break;
    }
    
    NSLog(@" --- 视频转向 -- %d",orientationValue);
    
    return orientationValue;
}

- (int)getImageOrientation:(UIImage *)image
{
    int orientationValue; //后面再添加枚举定义
    CGSize naturalSize = CGSizeMake(image.size.width, image.size.height);
    CGSize size;
    NSInteger ori = image.imageOrientation;
    switch (ori) {
        case MQVideoOrientationUp:
        {
            CGFloat ratio;
            if (naturalSize.width > naturalSize.height) {
                orientationValue = 0;
            }
            else{
                orientationValue = 1;
            }
        }
            break;

        case MQVideoOrientationDown:
            orientationValue = 1;
            break;

        case MQVideoOrientationLeft:
            //数据反转180°
            orientationValue = 3;
            break;

        case MQVideoOrientationRight:
            orientationValue = 0;
            break;

        default:
            orientationValue = 0;
            break;
    }
    
    NSLog(@" --- 视频转向 -- %d",orientationValue);
    
    return orientationValue;
}

-(MQVideoOrientation)videoOrientationWithAsset:(AVAsset *)asset
{
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([videoTracks count] == 0) {
        return MQVideoOrientationNotFound;
    }
    
    AVAssetTrack* videoTrack    = [videoTracks objectAtIndex:0];
    CGAffineTransform txf       = [videoTrack preferredTransform];
    CGFloat videoAngleInDegree  = RadiansToDegrees(atan2(txf.b, txf.a));
    
    MQVideoOrientation orientation = 0;
    switch ((int)videoAngleInDegree) {
        case 0:
            orientation = MQVideoOrientationRight;
            break;
        case 90:
            orientation = MQVideoOrientationUp;
            break;
        case 180:
            orientation = MQVideoOrientationLeft;
            break;
        case -90:
            orientation = MQVideoOrientationDown;
            break;
        default:
            orientation = MQVideoOrientationNotFound;
            break;
    }
    
    return orientation;
}

#pragma mark - 编辑后处理
- (AVAssetExportSession*)assetExportSessionWithPreset:(NSString*)presetName
{
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:presetName];
    if (self.videoComposition) {
        session.videoComposition = self.videoComposition;
    }
    return session;
}


- (AVPlayerItem *)playerItem
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
    playerItem.videoComposition = self.videoComposition;
    
    return playerItem;
}

@end

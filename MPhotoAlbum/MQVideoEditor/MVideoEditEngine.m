//
//  MVideoEditEngine.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/3.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MVideoEditEngine.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
//#import "RainEmitterLayer.h"
//#import "StickerView.h"
//#import "GifAnimationLayer.h"

//path
#define CACAHPAtH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define DOCUMENTPATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

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

@interface MVideoEditEngine ()

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, assign) float speedValue;

@property (nonatomic, assign) CGFloat scalableValue; //缩放比例系数

@property (nonatomic) CGSize videoSize;

@end

@implementation MVideoEditEngine

- (instancetype)init{
    if (self = [super init]) {
        _speedType = SpeedTypeNormal; //默认加速两倍
        _speedValue = 1.0;
        _screenSize = CGSizeMake(1920, 1080); //默认横屏
        _scalableValue = 1.0;
    }
    return self;
}


- (void)buildCompositionObjectsForPlayback:(BOOL)forPlayback
{
    if ( (_clips == nil) || [_clips count] == 0 ) {
        self.composition = nil;
        self.videoComposition = nil;
        return;
    }
    
    _videoSize = [[_clips objectAtIndex:0] naturalSize];
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableVideoComposition *videoComposition = nil;
    
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
    
    
    
    // With transitions:
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    // Set up the video composition to cycle between "pass through A", "transition from A to B",
    // "pass through B".
    
    videoComposition = [AVMutableVideoComposition videoComposition];
    
//    if (self.transitionType == kDiagonalWipeTransition) {
//        videoComposition.customVideoCompositorClass = [APLDiagonalWipeCompositor class];
//    } else {
//        videoComposition.customVideoCompositorClass = [APLCrossDissolveCompositor class];
//    }
    
    //[self buildTransitionComposition:composition andVideoComposition:videoComposition];
    
    //[self buildSequenceComposition:composition];
    
    [self buildMakeTransformComposition:composition andVideoComposition:videoComposition];
    
    composition.naturalSize = _videoSize;
    self.composition = composition;
    
    if (videoComposition) {
        // Every videoComposition needs these properties to be set:
        videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
        videoComposition.renderSize = _videoSize;
        self.videoComposition = videoComposition;
    }
}

- (void)buildCompositionObjectsForExploreVideo
{
//    if ( (_clips == nil) || [_clips count] == 0 ) {
//        self.composition = nil;
//        self.videoComposition = nil;
//        return;
//    }
//
//    _videoSize = [[_clips objectAtIndex:0] naturalSize];
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    AVMutableVideoComposition *videoComposition = nil;
//
//    _videoSize = CGSizeMake(1920, 1080);
//    composition.naturalSize = _videoSize;
//
//
//    //单纯的顺序拼接
//    //[self buildSequenceComposition:composition];
//
//    //混合拼接
//    videoComposition = [AVMutableVideoComposition videoComposition];
//    [self buildSequenceComposition:composition andVideoComposition:videoComposition];
//
//    self.composition = composition;
//
//    if (videoComposition) {
//
//        // Every videoComposition needs these properties to be set:
//        videoComposition.frameDuration = CMTimeMake(1, 30); // 30 fps
//        videoComposition.renderSize = _videoSize;
//        self.videoComposition = videoComposition;
//
//        // Animation
//        CALayer *parentLayer = [CALayer layer];
//        CALayer *videoLayer = [CALayer layer];
//        parentLayer.frame = CGRectMake(0, 0, _videoSize.width, _videoSize.height);
//        videoLayer.frame = parentLayer.frame;
//        [parentLayer addSublayer:videoLayer];
//
//        //MARK:添加贴图 Animation effects
//        for (StickerView *view in self.gifImageArray) {
//
//            CALayer *animatedLayer =  [self createAnimationLayer:view videoSizeResult:_videoSize];
//            if (animatedLayer) {
//                //形变设置
////                CGFloat scaleValue = 0;
////                if (fabs(view.arg) > 0) {
////                    scaleValue = 0.75;
////                }
////
////                CGAffineTransform t1 = CGAffineTransformIdentity;
////                CGAffineTransform t2 = CGAffineTransformIdentity;
////                CGAffineTransform t3 = CGAffineTransformIdentity;
////                t1 = CGAffineTransformMakeTranslation(0,0);
////                t2 = CGAffineTransformRotate(t1, -1 *view.arg);
////                t3 = CGAffineTransformScale(t2, scaleValue, scaleValue);
////                //t3 = CGAffineTransformMakeRotation(-1 *view.arg);
////                [animatedLayer setAffineTransform:t3];
//
//                animatedLayer.transform = CATransform3DMakeRotation(-1 *view.arg, 0, 0, 1.0);
//
//                [parentLayer addSublayer:animatedLayer];
//
//            }
//        }
//
//        //MARK:添加例子特效
//        //添加例子特效动画 下雨
////        CAEmitterLayer *rainLayer = [RainEmitterLayer creatRainEmitterLayerWithFrame:parentLayer.frame];
////        rainLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 1, 0, 0); //由于渲染时，layer方向是反的所以在这里处理
////        [parentLayer addSublayer:rainLayer];
//
//        self.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
//    }
}

- (void)buildTransitionComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    NSUInteger clipsCount = [_clips count];
    
    // Make transitionDuration no greater than half the shortest clip duration.
    CMTime transitionDuration = self.transitionDuration;
    for (i = 0; i < clipsCount; i++ ) {
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        if (clipTimeRange) {
            CMTime halfClipDuration = [clipTimeRange CMTimeRangeValue].duration;
            halfClipDuration.timescale *= 2; // You can halve a rational by doubling its denominator.
            transitionDuration = CMTimeMinimum(transitionDuration, halfClipDuration);
        }
    }
    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    CMTimeRange *transitionTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    
    // Place clips into alternating video & audio tracks in composition, overlapped by transitionDuration.
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [_clips objectAtIndex:i];
        NSValue *clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
        AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        
        AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
        [compositionAudioTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
        
        // Remember the time range in which this clip should pass through.
        // First clip ends with a transition.
        // Second clip begins with a transition.
        // Exclude that transition from the pass through time ranges.
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
//        if (i > 0) {
//            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
//            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
//        }
//        if (i+1 < clipsCount) {
//            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
//        }
        
        if (i == 0)
        {
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        else if (i == (clipsCount -1))
        {
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, transitionDuration);
        }
        else
        {
            passThroughTimeRanges[i].start = CMTimeAdd(passThroughTimeRanges[i].start, transitionDuration);
            passThroughTimeRanges[i].duration = CMTimeSubtract(passThroughTimeRanges[i].duration, CMTimeMake(transitionDuration.value * 2.0, transitionDuration.timescale));
        }
        
        
        // The end of this clip will overlap the start of the next by transitionDuration.
        // (Note: this arithmetic falls apart if timeRangeInAsset.duration < 2 * transitionDuration.)
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration);
        nextClipStartTime = CMTimeSubtract(nextClipStartTime, transitionDuration);
        
        // Remember the time range for the transition to the next item.
        if (i+1 < clipsCount) {
            transitionTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, transitionDuration);
        }
    }
    
    // Set up the video composition to perform cross dissolve or diagonal wipe transitions between clips.
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    
    // Cycle between "pass through A", "transition from A to B", "pass through B"
    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets
        
        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
    
        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        [instructions addObject:passThroughInstruction];
        
        if (i+1 < clipsCount) {
            // Add transition from clip i to clip i+1.
            
            AVMutableVideoCompositionInstruction *transitionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            transitionInstruction.timeRange = transitionTimeRanges[i];
            AVMutableVideoCompositionLayerInstruction *fromLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
            AVMutableVideoCompositionLayerInstruction *toLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[1 - alternatingIndex]];
            
            //溶解转场
//            [fromLayer setOpacityRampFromStartOpacity:1.0 toEndOpacity:0.0 timeRange:transitionTimeRanges[i]];
            
            //擦除转场
            CGSize videoSize = [[_clips objectAtIndex:0] naturalSize];
            CGFloat videoWidth = videoSize.width;
            CGFloat videoHeight = videoSize.height;
            CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
            CGRect endRect = CGRectMake(0.0f, 0.0f, videoWidth, 0.0f);
            [fromLayer setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:transitionTimeRanges[i]];
            
            //切换转场
            // Set a transform ramp on toLayer from all the way right of the screen to identity.
//            [fromLayer setTransformRampFromStartTransform:CGAffineTransformIdentity toEndTransform:CGAffineTransformMakeTranslation(-composition.naturalSize.width, 0.0) timeRange:transitionTimeRanges[i]];
//            [toLayer setTransformRampFromStartTransform:CGAffineTransformMakeTranslation(+composition.naturalSize.width, 0.0) toEndTransform:CGAffineTransformIdentity timeRange:transitionTimeRanges[i]];
            
            transitionInstruction.layerInstructions = [NSArray arrayWithObjects:fromLayer, toLayer, nil];
            [instructions addObject:transitionInstruction];
        }
    }
    
    videoComposition.instructions = instructions;
}

- (void)buildSequenceComposition:(AVMutableComposition *)composition
{
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    // No transitions: place clips into one video track and one audio track in composition.
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (i = 0; i < [_clips count]; i++) {
        AVURLAsset *asset = [_clips objectAtIndex:i];
        NSValue *clipTimeRange;
        if (_clipTimeRanges.count > 0) {
            clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        }
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange) {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else{
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        if ([[asset tracksWithMediaType:AVMediaTypeVideo] count]) {
            AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            [compositionVideoTrack insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        }
        
//        if ([[asset tracksWithMediaType:AVMediaTypeAudio] count]) {
//            AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//            [compositionAudioTrack insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
//        }
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration); //全部视频叠加在同一个视频轨道上面
        
    }
    //旋转轨道
    //compositionVideoTrack.preferredTransform = CGAffineTransformMakeRotation(M_PI/2);
    //视频变速
    [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,nextClipStartTime) toDuration:CMTimeMake(nextClipStartTime.value * _speedValue , nextClipStartTime.timescale)];
    //音频变速
//    [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,nextClipStartTime) toDuration:CMTimeMake(nextClipStartTime.value * 0.50 , nextClipStartTime.timescale)];
    
    
}

- (void)buildSequenceComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    // No transitions: place clips into one video track and one audio track in composition.
   // AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    
    // Add two video tracks and two audio tracks.
    AVMutableCompositionTrack *compositionVideoTracks[2];
    //AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSUInteger clipsCount = [_clips count];
    CMTimeRange *passThroughTimeRanges = alloca(sizeof(CMTimeRange) * clipsCount);
    
    for (i = 0; i < [_clips count]; i++) {
        
        NSInteger alternatingIndex = i % 2;
        
        AVURLAsset *asset = [_clips objectAtIndex:i];
        NSValue *clipTimeRange;
        if (_clipTimeRanges.count > 0) {
            clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        }
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange) {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else{
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        if ([[asset tracksWithMediaType:AVMediaTypeVideo] count]) {
            AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [compositionVideoTracks[alternatingIndex] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        }
        
        passThroughTimeRanges[i] = CMTimeRangeMake(nextClipStartTime, timeRangeInAsset.duration);
        
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration); //全部视频叠加在同一个视频轨道上面
        
        
    }
    
    for (i = 0; i < [_clips count]; i++) {
        
        NSInteger alternatingIndex = i % 2;
        
        // Pass through clip i.
        AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        passThroughInstruction.timeRange = passThroughTimeRanges[i];
        AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTracks[alternatingIndex]];
    
        AVURLAsset *videoAsset = [_clips objectAtIndex:i];
        AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        CGFloat videoWidth = videoAssetTrack.naturalSize.width;
        CGFloat videoHeight = videoAssetTrack.naturalSize.height;
        CGFloat ratio = _videoSize.width/ videoWidth;
        CGAffineTransform t1 = CGAffineTransformIdentity;
        CGAffineTransform t2 = CGAffineTransformIdentity;
        CGAffineTransform t3 = CGAffineTransformIdentity;
        t1 = CGAffineTransformMakeTranslation(0,0);
        t2 = CGAffineTransformRotate(t1, 0);
        t3 = CGAffineTransformScale(t2, ratio, ratio);
        //形变设置
        CGAffineTransform finalTransform = t3;
        [passThroughLayer setTransform:t3 atTime:kCMTimeZero];
        
        passThroughInstruction.layerInstructions = [NSArray arrayWithObject:passThroughLayer];
        [instructions addObject:passThroughInstruction];
        
    }
    
    videoComposition.instructions = instructions;
}

- (void)buildMakeTransformComposition:(AVMutableComposition *)composition andVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    // No transitions: place clips into one video track and one audio track in composition.
    AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    for (i = 0; i < [_clips count]; i++) {
        AVURLAsset *asset = [_clips objectAtIndex:i];
        NSValue *clipTimeRange;
        if (_clipTimeRanges.count > 0) {
            clipTimeRange = [_clipTimeRanges objectAtIndex:i];
        }
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange) {
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        }
        else{
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        }
        
        if ([[asset tracksWithMediaType:AVMediaTypeVideo] count]) {
            AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            [compositionVideoTrack insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:nextClipStartTime error:nil];
        }
        
//        if ([[asset tracksWithMediaType:AVMediaTypeAudio] count]) {
//            AVAssetTrack *clipAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
//            [compositionAudioTrack insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:nextClipStartTime error:nil];
//        }
        
        nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration); //全部视频叠加在同一个视频轨道上面
        
    }
    //旋转轨道
    //compositionVideoTrack.preferredTransform = CGAffineTransformMakeRotation(M_PI/2);
    //视频变速
    [compositionVideoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,nextClipStartTime) toDuration:CMTimeMake(nextClipStartTime.value * _speedValue , nextClipStartTime.timescale)];
    //音频变速
//    [compositionAudioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero,nextClipStartTime) toDuration:CMTimeMake(nextClipStartTime.value * 0.50 , nextClipStartTime.timescale)];
    
    //3.1 AVMutableVideoCompositionInstruction 视频轨道中的一个视频，可以缩放、旋转等
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeFromTimeToTime(kCMTimeZero, compositionVideoTrack.timeRange.duration);
    // 3.2 AVMutableVideoCompositionLayerInstruction 一个视频轨道，包含了这个轨道上的所有视频素材
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    AVURLAsset *videoAsset = [_clips objectAtIndex:0];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //开始判断方向
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        //        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        //        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    //设置默认视频模板的大小
    if (_screenSize.width == 0) {
        _screenSize = CGSizeMake(1920, 1080);
    }
    NSLog(@"当前视频的大小width = %lf height = %lf",videoAssetTrack.naturalSize.width,videoAssetTrack.naturalSize.height);
    CGSize naturalSize;
    
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake( videoAssetTrack.naturalSize.height,videoAssetTrack.naturalSize.width);
    } else {
        naturalSize =  CGSizeMake( videoAssetTrack.naturalSize.width,videoAssetTrack.naturalSize.height);;
    }
    //比例旋转后缩放
    CGFloat scaleValue = _screenSize.height/naturalSize.height; //1920 缩到 1080 比例为 1920*0.5625 = 1080
    
    MQVideoOrientation videoOrientation = [self videoOrientationWithAsset:videoAsset];
    if (_videoSize.height > _videoSize.width) {
        //竖屏视频的宽高正常，但是方向确是横向需要修改特殊情况
        videoOrientation = MQVideoOrientationUp;
    }
    
    CGAffineTransform t1 = CGAffineTransformIdentity;
    CGAffineTransform t2 = CGAffineTransformIdentity;
    CGAffineTransform t3 = CGAffineTransformIdentity;
    CGFloat ratio;
    NSLog(@" --- 视频转向 -- %ld",(long)videoOrientation);
    
    switch (videoOrientation) {
        case MQVideoOrientationUp:
        {
            CGFloat ratio;
            if (_videoSize.width > _videoSize.height) {
                //说明是虚假竖的视频
                ratio = _videoSize.height/ _videoSize.width;
                CGFloat x_offset = _videoSize.width - (_videoSize.width - (_videoSize.height*ratio))/2;
                t1 = CGAffineTransformMakeTranslation(x_offset,0);
                t2 = CGAffineTransformRotate(t1, M_PI_2);
                t3 = CGAffineTransformScale(t2, ratio, ratio);
            }
            else{
                ratio = _videoSize.width/ _videoSize.height;
                CGFloat x_offset = (_videoSize.height - (_videoSize.width*ratio))/2;
                t1 = CGAffineTransformMakeTranslation(x_offset,0);
                t2 = CGAffineTransformRotate(t1, 0);
                t3 = CGAffineTransformScale(t2, ratio, ratio);
                //这里要改变videoSize，因为竖屏变横屏需要做变化,交换宽高,以便设置后面的视频参数
                CGFloat w = _videoSize.width;
                CGFloat h = _videoSize.height;
                _videoSize = CGSizeMake(h, w);
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
            t3 = CGAffineTransformScale(t2, 1.0, 1.0);
            break;

        default:
            t1 = CGAffineTransformMakeTranslation(0,0);
            t2 = CGAffineTransformRotate(t1, 0);
            t3 = CGAffineTransformScale(t2, 1.0, 1.0);
            break;
    }
    //形变设置
    CGAffineTransform finalTransform = t3;
    [videolayerInstruction setTransform:t3 atTime:kCMTimeZero];
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    //AVMutableVideoComposition：管理所有视频轨道，可以决定最终视频的尺寸，裁剪需要在这里进行
    videoComposition.instructions = [NSArray arrayWithObject:mainInstruction];
    
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

#pragma mark - 分段式裁剪视频
- (void)trimStartVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete
{
    NSURL *videoUrl = model.editingVideoUrl;
    
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];

    CMTimeRange exportTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(1000, 1000));
    NSString *videoName = [self getNewVideoPrefixNameFromVideoUrl:model.originalVideoUrl suffixString:@"Start"];
    NSString *startVideoStr = [self getImageToVideoFilePathStringWithImageName:videoName];
    NSURL *startVideoUrl = [NSURL fileURLWithPath:startVideoStr];
    exportSession.outputURL = startVideoUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            
            model.startVideoClipUrl = startVideoUrl;
            complete();
        }
        else{
            NSLog(@"Error: %@", exportSession.error.localizedDescription);
        }
        
    }];
    
    
    
}

- (void)trimMiddleVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete
{
    NSURL *videoUrl = model.editingVideoUrl;
    
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];

    NSTimeInterval videoDruation = CMTimeGetSeconds(asset.duration) * 1000; //单位改为ms
    CMTimeRange middleTimeRange = CMTimeRangeMake(CMTimeMake(1000, 1000), CMTimeMake(videoDruation - 2000, 1000));
    NSString *videoName = [self getNewVideoPrefixNameFromVideoUrl:model.originalVideoUrl suffixString:@"Middle"];
    NSString *middleVideoStr = [self getImageToVideoFilePathStringWithImageName:videoName];
    NSURL *middleVideoUrl = [NSURL fileURLWithPath:middleVideoStr];
    exportSession.outputURL = middleVideoUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.timeRange = middleTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            
            model.middleVideoClipUrl = middleVideoUrl;
            complete();
        }
        else{
            NSLog(@"Error: %@", exportSession.error.localizedDescription);
        }
        
    }];
}

- (void)trimEndVideoClip:(VideoAssetModel *)model andComplete:(void (^) (void)) complete
{
    NSURL *videoUrl = model.editingVideoUrl;
    
    AVAsset *asset = [AVAsset assetWithURL:videoUrl];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];

    NSTimeInterval videoDruation = CMTimeGetSeconds(asset.duration) * 1000; //单位改为ms
    CMTimeRange middleTimeRange = CMTimeRangeMake(CMTimeMake(videoDruation - 1000, 1000), CMTimeMake(1000, 1000));
    NSString *videoName = [self getNewVideoPrefixNameFromVideoUrl:model.originalVideoUrl suffixString:@"End"];
    NSString *endVideoStr = [self getImageToVideoFilePathStringWithImageName:videoName];
    NSURL *endVideoUrl = [NSURL fileURLWithPath:endVideoStr];
    exportSession.outputURL = endVideoUrl;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.timeRange = middleTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            
            model.endVideoClipUrl = endVideoUrl;
            complete();
        }
        else{
            NSLog(@"Error: %@", exportSession.error.localizedDescription);
        }
        
    }];
}

#pragma mark - 属性设置
- (void)setSpeedType:(SpeedType)speedType
{
    _speedType = speedType;
    switch (_speedType) {
        case SpeedTypeNormal:
            _speedValue = 1.0;
            break;
        case SpeedTypeFastDouble:
            _speedValue = 0.5;
            break;
        case SpeedTypeFastThreefold:
            _speedValue = 0.3;
            break;
        case SpeedTypeFastFourfold:
            _speedValue = 0.25;
            break;
        case SpeedTypeSlowDouble:
            _speedValue = 2.0;
            break;
            
        default:
            _speedValue = 1.0;
            break;
    }
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


//#pragma mark - GIF动画
///**
// *  gif动画
// */
//- (CALayer *)createAnimationLayer:(StickerView *)view videoSizeResult:(CGSize)videoSizeResult
//{
//    
//    CALayer *animatedLayer = nil;
//    NSString *gifPath = view.getFilePath;
//    CGFloat maxScale = 0;
//
//    maxScale = (videoSizeResult.width / videoSizeResult.height) > (D_SCREEN_WIDTH/D_SCREEN_HEIGHT) ?  videoSizeResult.width / D_SCREEN_WIDTH : videoSizeResult.height / D_SCREEN_HEIGHT;
//    view.imageFrame = [view getInnerFrame];
//    
////    CGFloat widthFactor  = videoSizeResult.width / CGRectGetWidth(view.getInnerFrame);
////    CGFloat heightFactor = CGRectGetHeight(view.getVideoContentRect) / CGRectGetHeight(view.getInnerFrame);
////
////    CGPoint origin = CGPointMake((view.getInnerFrame.origin.x / CGRectGetWidth(view.getVideoContentRect)) * videoSizeResult.width,  videoSizeResult.height - ((view.getInnerFrame.origin.y / CGRectGetHeight(view.getVideoContentRect)) * videoSizeResult.height) - videoSizeResult.height/heightFactor);
////    CGRect gifFrame = CGRectMake(origin.x, origin.y, view.imageFrame.size.height * maxScale, view.imageFrame.size.height * maxScale);
//    
////    CGFloat widthFactor  = videoSizeResult.width / CGRectGetWidth(view.imageView.frame);
////    CGFloat heightFactor = CGRectGetHeight(view.getVideoContentRect) / CGRectGetHeight(view.imageView.frame);
////    CGPoint origin = CGPointMake((view.imageView.frame.origin.x / CGRectGetWidth(view.getVideoContentRect)) * videoSizeResult.width,  videoSizeResult.height - ((view.imageView.frame.origin.y / CGRectGetHeight(view.getVideoContentRect)) * videoSizeResult.height) - videoSizeResult.height/heightFactor);
////    CGRect gifFrame = CGRectMake(origin.x, origin.y, view.imageView.frame.size.width * maxScale, view.imageView.frame.size.height * maxScale);
//    
//    //另外一种方法求出中心点的位置就可以Layer的原点是在左下角，所以y是要用高度减去原有值
//    CGPoint centerScreen = view.center;
//    CGFloat gifWidth = view.imageView.frame.size.width * maxScale;
//    CGFloat gifHeight = view.imageView.frame.size.height * maxScale;
//    
//    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
//    CGFloat scaleFromScreen = videoSizeResult.width / screenWidth;
//    
//    CGPoint centerVideo = CGPointMake(centerScreen.x * scaleFromScreen, videoSizeResult.height - centerScreen.y * scaleFromScreen);
//    
//    CGRect gifFrame = CGRectMake(centerVideo.x - gifWidth/2.0, centerVideo.y - gifHeight/2.0, gifWidth, gifHeight);
//    
//    // 动画时间设置
//    //CGFloat second = CMTimeGetSeconds(self.asset.duration);
//    CFTimeInterval beginTime = view.timeRange.beginPercent / 1000.0;
//    if (beginTime == 0) {
//        beginTime = 0.01;
//    }
//    animatedLayer = [GifAnimationLayer layerWithGifFilePath:gifPath withFrame:gifFrame withAniBeginTime:beginTime];
//    CFTimeInterval duration = view.timeRange.endPercent / 1000.0;;
//    
//    
//    NSMutableArray *imageArray = [NSMutableArray array];
//    if (animatedLayer && [animatedLayer isKindOfClass:[GifAnimationLayer class]])
//    {
//        animatedLayer.opacity = 1.0f;
//        
//        CAKeyframeAnimation *animation = [[CAKeyframeAnimation alloc]init];
//        
//        [animation setKeyPath:@"contents"];
//        animation.calculationMode = kCAAnimationDiscrete;
//        animation.autoreverses = NO;
//        animation.repeatCount = INT16_MAX;
//        animation.beginTime = beginTime;
//        animation.repeatDuration = duration;
//        NSDictionary *gifDic = [(GifAnimationLayer*)animatedLayer getValuesAndKeyTimes];
//        NSMutableArray *keyTimes = [gifDic objectForKey:@"keyTimes"];
//        for (int i = 0; i < [keyTimes count]; ++i)
//        {
//            CGImageRef image = [(GifAnimationLayer*)animatedLayer copyImageAtFrameIndex:i];
//            if (image)
//            {
//                [imageArray addObject:(__bridge id)image];
//            }
//        }
//        
//        animation.values   = imageArray;
//        animation.keyTimes = keyTimes;
//        animation.duration = [(GifAnimationLayer*)animatedLayer getTotalDuration];
//        animation.removedOnCompletion = NO;
//        [animation setValue:@"stop" forKey:@"TAG"];
//        
//        [animatedLayer addAnimation:animation forKey:@"contents"];
//        
////        CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
////        fadeOutAnimation.fromValue = @1.0f;
////        fadeOutAnimation.toValue = @0.1f;
////        fadeOutAnimation.additive = YES;
////        fadeOutAnimation.removedOnCompletion = NO;
////        fadeOutAnimation.beginTime = beginTime;
////        fadeOutAnimation.duration = animation.beginTime + animation.duration + 2;
////        fadeOutAnimation.fillMode = kCAFillModeBoth;
////        fadeOutAnimation.repeatCount = INT16_MAX;
////        [animatedLayer addAnimation:fadeOutAnimation forKey:@"opacityOut"];
//        
//    }
//    
//    return animatedLayer;
//    
//}


#pragma mark - 获取视频名
-(NSString *)getNewVideoPrefixNameFromVideoUrl:(NSURL *)videoUrl suffixString:(NSString *)sstr
{
    NSString *videoFileString = [videoUrl absoluteString];
    NSString *originVideoString = [[videoFileString lastPathComponent] stringByDeletingPathExtension];
    NSString *newVideoName = [NSString stringWithFormat:@"%@_%@",originVideoString,sstr];
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

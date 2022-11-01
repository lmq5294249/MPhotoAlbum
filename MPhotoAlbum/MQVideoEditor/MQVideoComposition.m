//
//  MQVideoComposition.m
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/2/10.
//

#import "MQVideoComposition.h"
#import "MOpenGLEngine.h"
#import "MQCustomVideoCompositionInstruction.h"
#import "EditTemplateModel.h"

@interface MQVideoComposition ()
{
    CVPixelBufferRef _previousBuffer;
}
@property (nonatomic, strong) MOpenGLEngine *openGLRender;

@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, assign) BOOL renderContextDidChange;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) dispatch_queue_t renderContextQueue;
@property (nonatomic, strong) AVVideoCompositionRenderContext *renderContext;
@property (nonatomic, assign) BOOL enableMaskEffect;
@property (nonatomic, assign) float lastStartTimer;

@property (nonatomic, assign) NSInteger curFilter;
@property (nonatomic, assign) NSInteger curForeFilter;
@property (nonatomic, assign) NSInteger curBackFilter;

@end

@implementation MQVideoComposition

- (instancetype)init
{
    self = [super init];
    if (self) {
        _renderingQueue = dispatch_queue_create("loying.lin.LYVideoCompostion.renderQueue", DISPATCH_QUEUE_SERIAL);
        _renderContextQueue = dispatch_queue_create("loying.lin.LYVideoCompostion.renderContextQueue", DISPATCH_QUEUE_SERIAL);
        _previousBuffer = nil;
        _renderContextDidChange = NO;
        
        self.openGLRender = [[MOpenGLEngine alloc] initWithFilter:6];
        self.openGLRender.transitionDuration = 0.9;
        
        _shouldCancelAllRequests = NO;
        
        self.curForeFilter = 1000; //不能设置为0
        self.curBackFilter = 1000;
    }
    return self;
}

- (NSDictionary *)sourcePixelBufferAttributes {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (NSDictionary *)requiredPixelBufferAttributesForRenderContext {
    return @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
              (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : [NSNumber numberWithBool:YES]};
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request {
    
    __weak typeof(self) weakSelf = self;
    
    @autoreleasepool {
        dispatch_async(_renderingQueue,^() {
            // Check if all pending requests have been cancelled
            if (weakSelf.shouldCancelAllRequests) {
                [request finishCancelledRequest];
            } else {
                NSError *err = nil;
                // Get the next rendererd pixel buffer
                
                MQCustomVideoCompositionInstruction *currentInstruction = request.videoCompositionInstruction;
                CMTime currentTime = request.compositionTime;
                CMTimeRange timeRange = currentInstruction.timeRange;
                NSLog(@"打印时间段start:%f end:%f -> 测试时间%f",CMTimeGetSeconds(timeRange.start) * 1000,
                      CMTimeGetSeconds(timeRange.duration) * 1000,CMTimeGetSeconds(currentTime) * 1000);
                //记录上一次的时间可切换时间段
                if (self.lastStartTimer != CMTimeGetSeconds(timeRange.start) * 1000) {
                    [self.openGLRender clearForeImageCache];
                    [self.openGLRender clearBackImageCache];
                    self.lastStartTimer = CMTimeGetSeconds(timeRange.start) * 1000;
                }
                
                NSLog(@"打印当前的轨道值：%lu",(unsigned long)request.sourceTrackIDs.count);
                //NSLog(@"打印当前的shaderType值：%@",currentInstruction.paramArray);
                
                CVPixelBufferRef resultPixels;
                if (request.sourceTrackIDs.count > 2)
                {
                    //获取是视频渲染参数
                    NSDictionary *passDic1 = currentInstruction.paramArray[0];
                    NSInteger foreFilterType = [[passDic1 objectForKey:@"FilterType"] integerValue];
                    NSInteger foreOrienValue = [[passDic1 objectForKey:@"VideoOrientation"] intValue];
                    NSInteger transitionType = [[passDic1 objectForKey:@"TransitionType"] integerValue];
                    float transTimeValue = [[passDic1 objectForKey:@"TransitionDuration"] floatValue];
                    UIImage *foreImage = [passDic1 objectForKey:@"ImageData"];
                    BOOL foreImagePlaying = [passDic1 objectForKey:@"PlayImage"];
                    NSDictionary *passDic2 = currentInstruction.paramArray[1];
                    NSInteger backFilterType = [[passDic2 objectForKey:@"FilterType"] intValue];
                    NSInteger backOrienValue = [[passDic2 objectForKey:@"VideoOrientation"] intValue];
                    UIImage *backImage = [passDic2 objectForKey:@"ImageData"];
                    BOOL backImagePlaying = [passDic2 objectForKey:@"PlayImage"];
                    
                    if (self.curForeFilter != foreFilterType) {
                        [self.openGLRender setForeFilterPragramIDWithType:foreFilterType];
                        [self.openGLRender setForeVideoRenderType:foreOrienValue];
                        self.curForeFilter = foreFilterType;
                    }
                    
                    if (self.curBackFilter != backFilterType) {
                        [self.openGLRender setBackFilterPragramIDWithType:backFilterType];
                        [self.openGLRender setBackVideoRenderType:backOrienValue];
                        self.curBackFilter = backFilterType;
                    }
                    
                    [self.openGLRender setCurrentTransitionProgressValue:(CMTimeGetSeconds(currentTime) - CMTimeGetSeconds(timeRange.start)) / transTimeValue];
                    
                    CVPixelBufferRef foreBuffer = NULL,backBuffer = NULL;
                    if (foreImagePlaying) {
                        foreBuffer = [self.openGLRender startRenderWithForeImage:foreImage];
                    }else{
                        CVPixelBufferRef foreImageBuffer = [request sourceFrameByTrackID:currentInstruction.foregroundTrackID];
                        foreBuffer = [self.openGLRender renderForePixelBuffer:foreImageBuffer];
                    }
                    if (backImagePlaying) {
                        backBuffer = [self.openGLRender startRenderWithBackImage:backImage];
                    }
                    else{
                        CVPixelBufferRef backImageBuffer = [request sourceFrameByTrackID:currentInstruction.backgroundTrackID];
                        backBuffer = [self.openGLRender renderBackPixelBuffer:backImageBuffer];
                    }
                    

                    //NSLog(@"openGLRender Buffer");
                    [self.openGLRender switchTransitionFilter:transitionType];
                    resultPixels = [self.openGLRender startRenderVideoWithPixelBufferRef:foreBuffer andPixelBufferRef:backBuffer];
                    //CVPixelBufferRelease(foreBuffer);
                    //CVPixelBufferRelease(backBuffer);

                }else if (request.sourceTrackIDs.count > 0)
                {
                    if (currentInstruction.paramArray.count > 1) {
                        NSDictionary *passDic = currentInstruction.paramArray[1];
                        weakSelf.enableMaskEffect = ([[passDic objectForKey:@"MaskVideoEffect"] intValue] == 1) ? YES : NO;
                    }
                    //获取是视频渲染参数
                    NSDictionary *passDic = currentInstruction.paramArray[0];
                    NSInteger filterType = [[passDic objectForKey:@"FilterType"] intValue];
                    NSInteger orientationValue = [[passDic objectForKey:@"VideoOrientation"] intValue];
                    UIImage *image = [passDic objectForKey:@"ImageData"];
                    BOOL playingImage = [passDic objectForKey:@"PlayImage"];
                    
                    CVPixelBufferRef foreImageBuffer = [request sourceFrameByTrackID:currentInstruction.foregroundTrackID];

                    if (foreImageBuffer) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self.openGLRender setForeFilterPragramIDWithType:filterType];
                            [self.openGLRender setForeVideoRenderType:orientationValue];
                        });
                        if (playingImage) {
                            resultPixels = [self.openGLRender startRenderWithForeImage:image];
                        }
                        else{
                            resultPixels = [self.openGLRender startRenderVideoWithPixelBufferRef:foreImageBuffer];
                        }
                        
                    }
                    else{
                        resultPixels = NULL;
                        NSLog(@"%s:获取数据异常",__func__);
                    }
                    
                    
//                    resultPixels = [request sourceFrameByTrackID:[[request.sourceTrackIDs objectAtIndex:0] intValue]];
//                    CVPixelBufferRetain(resultPixels);
                }
                else{
                    NSLog(@"%s:获取数据异常",__func__);
                    [request finishCancelledRequest];
                    return;
                }
                
                /*
                 模拟耗时[NSThread sleepForTimeInterval:0.1];
                 这个耗时的话获取的BUffer相应的减少就照成视频卡顿
                 */
                CVPixelBufferRef maskImageBuffer;
                if (weakSelf.enableMaskEffect) {
                    maskImageBuffer = [request sourceFrameByTrackID:currentInstruction.maskVideoTrackID];
                }
                else{
                    maskImageBuffer = NULL;
                }
                
                [self.openGLRender switchSpecialEffect];
                CVPixelBufferRef maskPixelBuffer = [self.openGLRender startRenderMaskVideoWithPixelBufferRef:resultPixels maskVideoBuffer:maskImageBuffer];
//                CFRelease(resultPixels);
                //NSLog(@"Get the next rendererd pixel buffer");
                //MARK:导出时需要设置等待时间，不然内存分分钟暴涨
                [NSThread sleepForTimeInterval:0.005];
                
                if (resultPixels) {
                    // The resulting pixelbuffer from OpenGL renderer is passed along to the request
                    [request finishWithComposedVideoFrame:maskPixelBuffer];
                    CFRelease(maskPixelBuffer);
                } else {
                    [request finishWithError:err];
                }
            }
        });
    }
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    dispatch_sync(_renderContextQueue, ^() {
        _renderContext = newRenderContext;
        _renderContextDidChange = YES;
    });
}

- (void)cancelAllPendingVideoCompositionRequests
{
    // pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
    _shouldCancelAllRequests = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_barrier_async(_renderingQueue, ^() {
        // start accepting requests again
        weakSelf.shouldCancelAllRequests = NO;
    });
}

@end

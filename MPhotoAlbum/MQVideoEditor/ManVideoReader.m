//
//  ManVideoReader.m
//  RenderVideoOpenGL
//
//  Created by lin on 2021/3/27.
//

#import "ManVideoReader.h"

@interface ManVideoReader ()

@property (nonatomic, strong) AVAsset *avAsset;

@property (nonatomic, strong) AVAssetReader *reader;


@property (nonatomic, strong) AVAssetReaderTrackOutput *asset_reader_output;

@property (nonatomic, strong) NSURL *videoUrl;

@end

@implementation ManVideoReader

-(instancetype)initVideoReaderWithFilePath:(NSURL *)fileUrl
{
    if (self = [super init]) {
        
        self.frameNums = 0;
        
        self.videoUrl = fileUrl;
        
        [self initAVAssetReader:fileUrl];
        
    }
    return self;
}

-(void)initAVAssetReader:(NSURL *)pathString
{
    //NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"world001.mp4"];
    _avAsset = [[AVURLAsset alloc] initWithURL:pathString options:nil];
    NSError *error = nil;
    _reader = [[AVAssetReader alloc] initWithAsset:_avAsset error:&error]; // crashing right around here!
    NSArray *videoTracks = [_avAsset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count == 0) {
        return;
    }
    AVAssetTrack *videoTrack = [videoTracks objectAtIndex:0];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    _asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    _asset_reader_output.supportsRandomAccess = YES;
    [_reader addOutput:_asset_reader_output];
    [_reader startReading];
    
    self.frameRate = videoTrack.nominalFrameRate;
    self.frameNums = CMTimeGetSeconds(_avAsset.duration)*self.frameRate;
}

- (void)resetVideoReader
{
    [self initAVAssetReader:_videoUrl];
}

-(CMSampleBufferRef)getFrameSampleBuffer
{
//    static int countFrame = 0;
//    countFrame++;
//    if (countFrame > _frameNums + 10) {
//        CMTime startTime = CMTimeMake(_frameNums - 5, _frameRate);
//        CMTime durationTime = CMTimeMake(_frameNums, _frameRate);
//        NSValue *videoTimeValue = [NSValue valueWithCMTimeRange:CMTimeRangeMake(startTime, durationTime)];
//        [_asset_reader_output resetForReadingTimeRanges:@[videoTimeValue]];
//    }
    CMSampleBufferRef samplebuffer = [_asset_reader_output copyNextSampleBuffer];
   // CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(samplebuffer);
    //NSLog(@"获取帧数据!!!!!")
    if (samplebuffer == NULL) {
        
        if (_reader.status == AVAssetReaderStatusFailed) {
            //重置reader
            [self resetVideoReader];
            samplebuffer = [_asset_reader_output copyNextSampleBuffer];
        }
        else{
            CMTime startTime = CMTimeMake(1, _frameRate);
            CMTime durationTime = CMTimeMake(_frameNums, _frameRate);
            NSValue *videoTimeValue = [NSValue valueWithCMTimeRange:CMTimeRangeMake(startTime, durationTime)];
            [_asset_reader_output resetForReadingTimeRanges:@[videoTimeValue]];
            samplebuffer = [_asset_reader_output copyNextSampleBuffer];
        }
    }
    if (samplebuffer) {
        CFRetain(samplebuffer);
    }
    
    return samplebuffer;
}

-(NSInteger)getAVAssetReaderState
{
    return [_reader status];
}


-(UIImage*)getVideoLastImage
{
    AVAssetImageGenerator *generate = [AVAssetImageGenerator assetImageGeneratorWithAsset:_avAsset];
    generate.appliesPreferredTrackTransform = YES;

    NSError *error;

    CMTime time = CMTimeMake(_frameNums - 2, self.frameRate);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:nil error:&error];
    UIImage *image = [UIImage imageWithCGImage:imgRef];
    return image;
}

-(CMSampleBufferRef)getLastSampleBuffer
{
    CMTime startTime = CMTimeMake(_frameNums - 5, _frameRate);
    CMTime durationTime = CMTimeMake(_frameNums, _frameRate);
    NSValue *videoTimeValue = [NSValue valueWithCMTimeRange:CMTimeRangeMake(startTime, durationTime)];
    [_asset_reader_output resetForReadingTimeRanges:@[videoTimeValue]];
    CMSampleBufferRef samplebuffer = [_asset_reader_output copyNextSampleBuffer];
    
    return samplebuffer;
}

-(UIImage *)imageFromCVPixelBufferRef1:(CVPixelBufferRef)pixelBuffer{
    UIImage *image;
    @autoreleasepool {
        CGImageRef cgImage = NULL;
        CVPixelBufferRef pb = (CVPixelBufferRef)pixelBuffer;
        CVPixelBufferLockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        OSStatus res = CreateCGImageFromCVPixelBuffer(pb,&cgImage);
        if (res == noErr){
            image= [UIImage imageWithCGImage:cgImage scale:1.0 orientation:UIImageOrientationUp];
        }
        CVPixelBufferUnlockBaseAddress(pb, kCVPixelBufferLock_ReadOnly);
        CGImageRelease(cgImage);
    }
    return image;
}

static OSStatus CreateCGImageFromCVPixelBuffer(CVPixelBufferRef pixelBuffer, CGImageRef *imageOut)
{
    OSStatus err = noErr;
    OSType sourcePixelFormat;
    size_t width, height, sourceRowBytes;
    void *sourceBaseAddr = NULL;
    CGBitmapInfo bitmapInfo;
    CGColorSpaceRef colorspace = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef image = NULL;
    sourcePixelFormat = CVPixelBufferGetPixelFormatType( pixelBuffer );
    if ( kCVPixelFormatType_32ARGB == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipFirst;
    else if ( kCVPixelFormatType_32BGRA == sourcePixelFormat )
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst;
    else
        return -95014; // only uncompressed pixel formats
    sourceRowBytes = CVPixelBufferGetBytesPerRow( pixelBuffer );
    width = CVPixelBufferGetWidth( pixelBuffer );
    height = CVPixelBufferGetHeight( pixelBuffer );
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    sourceBaseAddr = CVPixelBufferGetBaseAddress( pixelBuffer );
    colorspace = CGColorSpaceCreateDeviceRGB();
    CVPixelBufferRetain( pixelBuffer );
    provider = CGDataProviderCreateWithData( (void *)pixelBuffer, sourceBaseAddr, sourceRowBytes * height, ReleaseCVPixelBuffer);
    image = CGImageCreate(width, height, 8, 32, sourceRowBytes, colorspace, bitmapInfo, provider, NULL, true, kCGRenderingIntentDefault);
    if ( err && image ) {
        CGImageRelease( image );
        image = NULL;
    }
    if ( provider ) CGDataProviderRelease( provider );
    if ( colorspace ) CGColorSpaceRelease( colorspace );
    *imageOut = image;
    return err;
}

static void ReleaseCVPixelBuffer(void *pixel, const void *data, size_t size)
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)pixel;
    CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    CVPixelBufferRelease( pixelBuffer );
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

@end

//
//  ManVideoReader.h
//  RenderVideoOpenGL
//
//  Created by lin on 2021/3/27.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface ManVideoReader : NSObject

@property (nonatomic, assign) int frameNums;

@property (nonatomic, assign) int frameRate;

-(instancetype)initVideoReaderWithFilePath:(NSURL *)fileUrl;

- (void)resetVideoReader;

-(CMSampleBufferRef)getFrameSampleBuffer;

-(NSInteger)getAVAssetReaderState;

-(UIImage*)getVideoLastImage;

-(CMSampleBufferRef)getLastSampleBuffer;

@end


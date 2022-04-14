//
//  MOpenGLEngine.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/11.
//  Copyright © 2021 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import "VideoEditorParamTypeHeader.h"

typedef NS_ENUM(NSUInteger, MGPUImageFilter) {
    MGPUImageFilterNone = 0, //无滤镜
    MGPUImageBeautyFilter, //美颜滤镜
    MGPUImageGrayscaleFilter,  //黑白
    //MGPUImageGaussianBlurFilter, //高斯模糊
    MGPUImageSepiaFilter, //怀旧
    MGPUImageMacaronPinkFilter, //5 - 马卡龙滤镜
    MGPUImageDarkGreenFilter,   //6 - 暗绿风格滤镜 - 适用于拍摄时过亮将风格变得深邃偏暗 场景推荐：带有绿色山水房屋还可以突出灯光效果
    MGPUImageBlackGoldFilter,  //7 - 黑金风格
    MGPUImageGreenOrangeFilter,  //8 - 青橙色调
    MGPUImageGreenOrangeBuildingFilter, //9 - 青橙古建筑
    MGPUImageInsDarkFilter,   //10 - 暗黑色调
    MGPUImageGrayOrangeFilter,  //11 - 中灰橙色调
    MGPUImageLividityFilter,     //12 - 青灰色调
    MGPUImageGrayStyleFilter,    //13 - 灰色调
    MGPUImageCyberpunkFilter,   //14 - 赛博朋克风格夜景专用
    MGPUImageSweetCandyColorFilter,   //15 - 糖果色色调
    MGPUImageSunsetWarmFilmFilter,   //16 - 落日暖系胶片效果
    MGPUImageBlueCartoonFilter,   //17 - 日系漫画蓝系风格
    MGPUImageAmaroFilter,
    MGPUImageHudsonFilter,
    MGPUImageNashvilleFilter,
    MGPUImageRiseFilter,
    MGPUImageWaldenFilter,
    MGPUImageMagicCrayonFilter, //蜡笔
    MGPUImageSketchFilter, //黑白素描
    MGPUImageColorPencilSketchFilter, //素描
    MGPUImageZoomInFilter, //放大哈哈镜效果
    MGPUImageKaleidoscopeFilter, //2021-10-09新增:万花筒滤镜 竖屏为例，从右上角向左下角划分三角形以右下角三角形为内容，万花筒中心点是右上角位置
};


typedef NS_ENUM(NSUInteger, MCameraType) {
    MCameraTypeBack,
    MCameraTypeFront,
};

typedef NS_ENUM(NSUInteger, MScreenOrientation) {
    MScreenPortrait,
    MScreenLandscapeLeft,
    MScreenLandscapeRight,
};

typedef NS_ENUM(NSUInteger, MVideoOrientationType) {
    MVideoOrientationTypeNormalLandscape = 0,
    MVideoOrientationTypeNormalPortrait,
    MVideoOrientationTypeFakePortrait, //这个就是虚假的竖向视频
    MVideoOrientationTypeLandscapeleft,
};

@interface MOpenGLEngine : NSObject

@property (nonatomic, assign) NSTimeInterval transitionDuration;

- (instancetype)initWithFilter:(MQTransitionType)filter;

- (void)switchGPUImageFilter:(MGPUImageFilter)filterType;

- (void)switchTransitionFilter:(MQTransitionType)filterType;

- (CVPixelBufferRef)startRenderVideoWithPixelBufferRef:(CVPixelBufferRef)foreBuffer;

- (CVPixelBufferRef)startRenderVideoWithPixelBufferRef:(CVPixelBufferRef)foreBuffer andPixelBufferRef:(CVPixelBufferRef)backBuffer;

- (void)setForeFilterPragramIDWithType:(MGPUImageFilter)filterType;
- (void)setForeVideoRenderType:(MVideoOrientationType)videoType;
- (CVPixelBufferRef)renderForePixelBuffer:(CVPixelBufferRef)imagePB;

- (void)setBackFilterPragramIDWithType:(MGPUImageFilter)filterType;
- (void)setBackVideoRenderType:(MVideoOrientationType)videoType;
- (CVPixelBufferRef)renderBackPixelBuffer:(CVPixelBufferRef)imagePB;

- (CVPixelBufferRef)startRenderWithForeImage:(UIImage *)image;
- (CVPixelBufferRef)startRenderWithBackImage:(UIImage *)image;
- (void)clearForeImageCache;
- (void)clearBackImageCache;

- (void)setCurrentTransitionProgressValue:(float)value;
- (void)clearTransitionProgress;

- (void)switchSpecialEffect;
- (CVPixelBufferRef)startRenderMaskVideoWithPixelBufferRef:(CVPixelBufferRef)backBuffer maskVideoBuffer:(CVPixelBufferRef)foreBuffer;

@end


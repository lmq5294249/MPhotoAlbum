//
//  MOpenGLEngine.m
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/11.
//  Copyright © 2021 mac. All rights reserved.
//

#import "MOpenGLEngine.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import "ManVideoReader.h"

typedef NS_ENUM(NSUInteger, SpecialFilterType) {
    NormalFilterType, //普通滤镜模式
    LookUpTableFilterType,
    InstagramFilterType, //其中代表类型1977Filter
};

@interface MOpenGLEngine ()
{
    CGSize frameSize;
    GLuint targetTextureID;
    GLuint textureID;
    
    GLuint foreTextureID;
    GLuint backTextureID;
    
    GLuint LUTProgramId;
    GLuint INSprogramId;
    GLuint programId1;
    GLuint programId2;
    GLuint programId3;
    GLuint programId4;
    GLuint programId5;
    GLuint beautyProgramID;
    GLuint transformProgramID; //形变的shaderID，横竖屏的视频互相转换
    
    
    SpecialFilterType specialFilterType;
    
    NSTimeInterval preFrameProgressValue; //每一帧增加的进度值
    
    CVPixelBufferRef tempPixelBuffer;
    
    GLuint transitionID;
    GLuint foreProgramID;
    GLuint backProgramID;
    GLuint maskProgramID;
    
    GLuint foreFilterProgramID;
    GLuint backFilterProgramID;
    
    //固定保存图片PixelBuffer
    CVPixelBufferRef forePixelBuffer;
    CVPixelBufferRef backPixelBuffer;
    CVPixelBufferRef newPixelBuffer;
    CVPixelBufferRef transPixelBuffer;
    CVPixelBufferRef foreImageBuffer;
    CVPixelBufferRef backImageBuffer;
    
    ManVideoReader *foreVideoReader;
    
}
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint programId;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, assign) CVOpenGLESTextureRef renderTexture;
@property (nonatomic, assign) GLuint VBO;
@property (nonatomic, assign) GLuint rotateVBO;

@property (nonatomic, assign) GLuint foreVBO;
@property (nonatomic, assign) GLuint backVBO;

@property (nonatomic, assign) MVideoOrientationType curForeVideoType;
@property (nonatomic, assign) MVideoOrientationType curBackVideoType;

@property (nonatomic, assign) MGPUImageFilter currentFilter;
@property (nonatomic, assign) MQTransitionType curTransitionFilter;//当前的转场滤镜

//转场时间计时控制
@property (nonatomic, assign) NSTimeInterval currentProgress; //以1为进度的话如果过渡时长2s，那么1/(2*30) = 0.016667没帧增加的进度
@property (nonatomic, assign) CGFloat frameIndex;

//MARK:manYUV数据
@property (nonatomic, assign) CVOpenGLESTextureRef      luminanceTextureRef;
@property (nonatomic, assign) CVOpenGLESTextureRef      chromaTextureRef;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef videoTextureCache;

//MARK:phtot数据
@property (nonatomic, assign) CVOpenGLESTextureCacheRef photoTextureCache;

//滤镜参数
@property (nonatomic, assign) CGFloat thinFaceValue;//取值范围0~0.2
@property (nonatomic, assign) CGFloat bigEyeValue;//取值范围0~0.06
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) CGFloat progress; //进度系数。比如美颜滤镜下进度系数代表美颜程度值 ，其他滤镜也可代表其特定值
@property (nonatomic, assign) CGFloat brightValue; //美白深度值
@property (nonatomic, assign) CGFloat zoomValue; //娃哈哈镜放大值 设置为 0.5~1.0 为放大 小于0.5为缩小一般不缩小容易画面。。。

//其他图片作为附带纹理实现
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, assign) GLuint maskImgTextureID;

//多视频渲染模式
@property (nonatomic, assign) BOOL multiVideo;
@property (nonatomic, assign) BOOL resetMaskVideo;
@property (nonatomic, copy) NSArray *maskVideoArray;
@property (nonatomic, strong) NSURL *curMaskUrl;

//渲染进程锁
@property (nonatomic, strong) NSLock *renderLock;

@end

@implementation MOpenGLEngine

- (instancetype)initWithFilter:(MQTransitionType)filter
{
    if (self = [super init]) {
        
        //渲染初始化
        if (!self.context) {
            self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
            [EAGLContext setCurrentContext:_context];
        }
        _currentFilter = 1000;
        //渲染绑定ID
        [self switchGPUImageFilter:filter];
        [self setupVBO];
        
        [self initAllTheParameters];
        self.renderLock = [[NSLock alloc] init];
        //mask纹理初始化
//        _maskImage = [UIImage imageNamed:@"lookup_BlackGoldStyle.png"];
//        _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
        //默认转场设置为1s，公式为 1.0 / 30 = 0.0333333
        preFrameProgressValue = 1.0/30.0;
        _currentProgress = 0.0;
    }
    return self;
}

- (void)initAllTheParameters
{
    //参数设置
    //默认不开启瘦脸模式:才可以支持原生4K否则一般手机内存溢出

    self.totalTime = 0.f;
    self.startTime = [NSDate date];
//    self.highPerformancePhone = [self getHighPerformancePhoneModels];
    
    _curTransitionFilter = 5;
    
    foreImageBuffer = NULL;
    backImageBuffer = NULL;
    forePixelBuffer = NULL;
    backPixelBuffer = NULL;
    newPixelBuffer = NULL;
    transPixelBuffer = NULL;
}

//MARK:处理各个滤镜的相关数据
- (void)switchGPUImageFilter:(MGPUImageFilter)filterType{

    if (filterType == _currentFilter) {
        //如果滤镜一致就退出
        return;
    }
    
    //默认通用滤镜，先进入YUV数据转换，里面包含了瘦脸大眼执行程序
//    if (!self.programId) {
//        _programId = [self programWithShaderName:@"YUVNormalFilter"];//NV12
//    }
    
//    if (!foreProgramID) {
//        foreProgramID = [self programWithShaderName:@"NormalFilter"];
//    }
//    
//    if (!backProgramID) {
//        backProgramID = [self programWithShaderName:@"NormalFilter"];
//    }
    
    //下面是渲染特定美化滤镜---------------------------------------------------
    switch (filterType) {
        case MGPUImageFilterNone:
            programId1 = [self programWithShaderName:@"NormalFilter"];//RGB
            beautyProgramID = 0;
            beautyProgramID = programId1;
            specialFilterType = NormalFilterType;
            break;
            
        case MGPUImageBeautyFilter:
        {
            programId2 = [self programWithShaderName:@"MQBeautyFaceFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId2;
            specialFilterType = NormalFilterType;
        }
            break;
            
        case MGPUImageGrayscaleFilter:
        {
            programId3 = [self programWithShaderName:@"GPUImageGrayscaleFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
        }
            break;
            
//        case MGPUImageGaussianBlurFilter:
//        {
//            programId4 = [self programWithShaderName:@"MQGaussianFilter"];
//            beautyProgramID = 0;
//            beautyProgramID = programId4;
//            specialFilterType = NormalFilterType;
//            _zoomValue = 0.0;//设置0.0就是高斯模糊
//        }
//            break;
            
        case MGPUImageSepiaFilter:
        {
            programId5 = [self programWithShaderName:@"GPUImageSepiaFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId5;
            specialFilterType = NormalFilterType;
        }
            break;
            
        case MGPUImageMagicCrayonFilter:
        {
            programId3 = [self programWithShaderName:@"MQMagicCrayonFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
        }
            break;
            
        case MGPUImageSketchFilter:
        {
            programId3 = [self programWithShaderName:@"GPUImageSketchFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
            _progress = 0.7;
        }
            break;
            
        case MGPUImageZoomInFilter:
        {
            programId3 = [self programWithShaderName:@"MQZoomInFilter"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
            _zoomValue = 0.9; //设置放大系数0.9
        }
            break;
            
        case MGPUImageKaleidoscopeFilter:
        {
            programId3 = [self programWithShaderName:@"MQKaleidoscope"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
        }
            break;
            
        case MGPUImageColorPencilSketchFilter:
        {
            programId3 = [self programWithShaderName:@"MQSketchDrawing"];
            beautyProgramID = 0;
            beautyProgramID = programId3;
            specialFilterType = NormalFilterType;
        }
            break;
          
        //MARK:以下为InstagramFilterType-
        case MGPUImageBlackGoldFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_BlackGoldStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageMacaronPinkFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_MacaronPink.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageDarkGreenFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_DarkGreenStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageGreenOrangeFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_GreenOrangeStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageGreenOrangeBuildingFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_GreenOrangeBuilding.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
           
        case MGPUImageInsDarkFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_InsDarkStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageGrayOrangeFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_GrayOrangeStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageLividityFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_LividityStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageGrayStyleFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_GrayStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageCyberpunkFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_CyberpunkStyle2.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageSweetCandyColorFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_SweetCandyColor.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageSunsetWarmFilmFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_SunsetWarmFilm.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        case MGPUImageBlueCartoonFilter:
        {
            if (specialFilterType != LookUpTableFilterType) {
                LUTProgramId = [self programWithShaderName:@"MQLookUpTableFilter"];
                beautyProgramID = 0;
                beautyProgramID = LUTProgramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"lookup_BlueCartoonStyle.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = LookUpTableFilterType;
        }
            break;
            
        //MARK:以下为InstagramFilterType-
        case MGPUImageAmaroFilter:
        {
            if (specialFilterType != InstagramFilterType) {
                INSprogramId = [self programWithShaderName:@"MQ1977Filter"];
                beautyProgramID = 0;
                beautyProgramID = INSprogramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"amaroMap.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = InstagramFilterType;
        }
            break;
            
        case MGPUImageHudsonFilter:
        {
            if (specialFilterType != InstagramFilterType) {
                INSprogramId = [self programWithShaderName:@"MQ1977Filter"];
                beautyProgramID = 0;
                beautyProgramID = INSprogramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"hudsonMap.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = InstagramFilterType;
        }
            break;
            
        case MGPUImageNashvilleFilter:
        {
            if (specialFilterType != InstagramFilterType) {
                INSprogramId = [self programWithShaderName:@"MQ1977Filter"];
                beautyProgramID = 0;
                beautyProgramID = INSprogramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"nashvilleMap.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = InstagramFilterType;
        }
            break;
            
        case MGPUImageRiseFilter:
        {
            if (specialFilterType != InstagramFilterType) {
                INSprogramId = [self programWithShaderName:@"MQ1977Filter"];
                beautyProgramID = 0;
                beautyProgramID = INSprogramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"riseMap.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = InstagramFilterType;
        }
            break;
            
        case MGPUImageWaldenFilter:
        {
            if (specialFilterType != InstagramFilterType) {
                INSprogramId = [self programWithShaderName:@"MQ1977Filter"];
                beautyProgramID = 0;
                beautyProgramID = INSprogramId;
            }
            else{
                glDeleteTextures(1, &_maskImgTextureID);
                _maskImgTextureID = 0;
            }
            _maskImage = [UIImage imageNamed:@"waldenMap.png"];
            _maskImgTextureID = [self getTextureFromImage:_maskImage needTranslate:NO];
            specialFilterType = InstagramFilterType;
        }
            break;
            
        default:
            programId1 = [self programWithShaderName:@"NormalFilter"];//RGB
            beautyProgramID = 0;
            beautyProgramID = programId1;
            specialFilterType = NormalFilterType;
            break;
    }
    //滤镜生效------------------------------------------------------------------
    //glUseProgram(_programId); //滤镜生效设置
    _currentFilter = filterType; //获取当前的正在运行的滤镜
}


- (void)switchTransitionFilter:(MQTransitionType)filterType{

    //默认通用转场滤镜
    if (_curTransitionFilter == filterType) {
        return;
    }
    
    self.currentProgress = 0;//从0开始否则转场无效
    
    switch (filterType) {
        case MQTransitionTypeDoorWay:
            transitionID = [self programWithShaderName:@"doorway"];
            break;
        case MQTransitionTypeCrosswarp:
            transitionID = [self programWithShaderName:@"crosswarp"];
            break;
        case MQTransitionTypeScaleIn:
            transitionID = [self programWithShaderName:@"scaleIn"];
            break;
        case MQTransitionTypeSwipeLeft:
            transitionID = [self programWithShaderName:@"swipeLeft"];
            break;
        case MQTransitionTypeWindowSlice:
            transitionID = [self programWithShaderName:@"windowSlice"];
            break;
        case MQTransitionTypeSwap:
            transitionID = [self programWithShaderName:@"swap"];
            break;
        case MQTransitionTypeSquareswire:
            transitionID = [self programWithShaderName:@"squareswire"];
            break;
        case MQTransitionTypeRotateScaleFade:
            transitionID = [self programWithShaderName:@"rotateScaleFade"];
            break;
        case MQTransitionTypeCube:
            transitionID = [self programWithShaderName:@"cube"];
            break;
        case MQTransitionTypeRipple:
            transitionID = [self programWithShaderName:@"ripple"];
            break;
        case MQTransitionTypeWaterDrop:
            transitionID = [self programWithShaderName:@"WaterDrop"];
            break;
        case MQTransitionTypeColourDistance:
            transitionID = [self programWithShaderName:@"ColourDistance"];
            break;
        case MQTransitionTypeGirdFlip:
            transitionID = [self programWithShaderName:@"GridFlip"];
            break;
        case MQTransitionTypeGlitchMemories:
            transitionID = [self programWithShaderName:@"GlitchMemories"];
            break;
        case MQTransitionTypeLeftRight:
            transitionID = [self programWithShaderName:@"LeftRight"];
            break;
        case MQTransitionTypeInvertedPageCurl:
            transitionID = [self programWithShaderName:@"InvertedPageCurl"];
            break;

        default:
            break;
    }
    
    _curTransitionFilter = filterType;
}

//MARK:以下为特效视频MASKVideoFilterType-
- (void)switchSpecialEffect
{
    
    if (!maskProgramID) {
        maskProgramID = [self programWithShaderName:@"MASKVideo"];
    }
    else{
        return;
    }
    _multiVideo = YES; //视频特效合并
    _resetMaskVideo = NO;
    NSURL *foreVideoUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"HappyNewYear.mp4" ofType:nil]];
    _curMaskUrl = foreVideoUrl;
    
    foreVideoReader = [[ManVideoReader alloc] initVideoReaderWithFilePath:_curMaskUrl]; //前景读取器
}

#pragma mark - OpenGLShaderInit
- (void)setupGLProgram
{
    self.programId = [self programWithShaderName:@"NormalFilter"];
}

- (void)setupVBO {
    float vertices[] = {
        -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
        -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
        1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
        1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
    };
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setForeFilterPragramIDWithType:(MGPUImageFilter)filterType
{
    [self switchGPUImageFilter:filterType];
    foreFilterProgramID = beautyProgramID;
}

- (void)setBackFilterPragramIDWithType:(MGPUImageFilter)filterType
{
    [self switchGPUImageFilter:filterType];
    backFilterProgramID = beautyProgramID;
}

- (void)setForeVideoRenderType:(MVideoOrientationType)videoType
{
    if (_curForeVideoType == videoType && foreProgramID) {
        return;
    }
    
    if (videoType == MVideoOrientationTypeFakePortrait) {
        
        foreProgramID = [self programWithShaderName:@"FakePortraitVideoToLandscape"];
        
        //旋转90°顶点数组 => 适用于伪竖方向的视频，其实输出是横向数据
        float rotateVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
        };
        glGenBuffers(1, &_foreVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _foreVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(rotateVertices), rotateVertices, GL_STATIC_DRAW);
    }
    else if (videoType == MVideoOrientationTypeLandscapeleft)
    {
        foreProgramID = [self programWithShaderName:@"NormalFilter"];
        
        float reversalVertices[] = {
            -1.0f, -1.0f, 0.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, -1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, 1.0f, 0.0f, 0.0f, 0.0f,
        };
        glGenBuffers(1, &_foreVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _foreVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(reversalVertices), reversalVertices, GL_STATIC_DRAW);
    }
    else if (videoType == MVideoOrientationTypeNormalPortrait)
    {
        foreProgramID = [self programWithShaderName:@"PortraitVideoToLandscape"];
        
        float normalVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        };
        glGenBuffers(1, &_foreVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _foreVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_STATIC_DRAW);
    }
    else{
        foreProgramID = [self programWithShaderName:@"NormalFilter"];
        
        float normalVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        };
        glGenBuffers(1, &_foreVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _foreVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_STATIC_DRAW);
    }
    
    _curForeVideoType = videoType;
}

- (void)setBackVideoRenderType:(MVideoOrientationType)videoType
{
    if (_curBackVideoType == videoType && backProgramID) {
        return;
    }
    
    if (videoType == MVideoOrientationTypeFakePortrait) {
        backProgramID = [self programWithShaderName:@"FakePortraitVideoToLandscape"];
        
        //旋转90°顶点数组 => 适用于伪竖方向的视频，其实输出是横向数据
        float rotateVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
        };
        glGenBuffers(1, &_backVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _backVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(rotateVertices), rotateVertices, GL_STATIC_DRAW);
    }
    else if (videoType == MVideoOrientationTypeLandscapeleft)
    {
        backProgramID = [self programWithShaderName:@"NormalFilter"];
        
        float reversalVertices[] = {
            -1.0f, -1.0f, 0.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, -1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, 1.0f, 0.0f, 0.0f, 0.0f,
        };
        glGenBuffers(1, &_backVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _backVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(reversalVertices), reversalVertices, GL_STATIC_DRAW);
    }
    else if (videoType == MVideoOrientationTypeNormalPortrait)
    {
        backProgramID = [self programWithShaderName:@"PortraitVideoToLandscape"];
        
        float normalVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        };
        glGenBuffers(1, &_backVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _backVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_STATIC_DRAW);
    }
    else{
        backProgramID = [self programWithShaderName:@"NormalFilter"];
        
        float normalVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        };
        glGenBuffers(1, &_backVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _backVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(normalVertices), normalVertices, GL_STATIC_DRAW);
    }
    
    _curBackVideoType = videoType;
}

- (void)setupRotateVBO:(BOOL)isRotate
{
    if (isRotate) {
        //旋转90°顶点数组 => 适用于伪竖方向的视频，其实输出是横向数据
        float rotateVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 1.0f,
            -1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 0.0f,
        };
        glGenBuffers(1, &_rotateVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _rotateVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(rotateVertices), rotateVertices, GL_STATIC_DRAW);
    }
    else{
        //旋转90°顶点数组 => 适用于伪竖方向的视频，其实输出是横向数据
        float rotateVertices[] = {
            -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
            -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
            1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
            1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
        };
        glGenBuffers(1, &_rotateVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _rotateVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(rotateVertices), rotateVertices, GL_STATIC_DRAW);
    }
}

#pragma mark - 渲染PixelBuffer输出实时预览 -
- (CVPixelBufferRef)startRenderVideoWithPixelBufferRef:(CVPixelBufferRef)foreBuffer andPixelBufferRef:(CVPixelBufferRef)backBuffer
{
    CVPixelBufferRef output;
    
    frameSize = CGSizeMake(CVPixelBufferGetWidth(backBuffer),CVPixelBufferGetHeight(backBuffer));
    
    //目前强制1080P输出
//    if (frameSize.width > 1920) {
        frameSize = CGSizeMake(1920, 1080);
//    }
    
    self.programId = transitionID;
    
    output = [self convertTexture:foreBuffer ToPixelBufferWith:backBuffer textureSize:frameSize];
    
    return output;
}

- (CVPixelBufferRef)startRenderVideoWithPixelBufferRef:(CVPixelBufferRef)foreBuffer
{
    CVPixelBufferRef output;
    
    frameSize = CGSizeMake(CVPixelBufferGetWidth(foreBuffer),CVPixelBufferGetHeight(foreBuffer));
    
    if (frameSize.width != CVPixelBufferGetWidth(newPixelBuffer) || frameSize.height != CVPixelBufferGetHeight(newPixelBuffer)) {
        CVPixelBufferRelease(newPixelBuffer);
        newPixelBuffer = NULL;
    }
    
    if (frameSize.width > 1920) {
        frameSize = CGSizeMake(1920, 1080);
    }
    
    output = [self convertTextureToPixelBuffer:foreBuffer];
    
    //output = [self convertTextueWithRGBPixelBuffer:tempBuffer textureSize:frameSize];
    
    [self clearTransitionProgress];
    
    return output;
}

- (CVPixelBufferRef)startRenderWithForeImage:(UIImage *)image
{
    if (foreImageBuffer == NULL) {
        foreImageBuffer = [self CVPixelBufferRefFromUiImage:image];
    }
    frameSize = CGSizeMake(CVPixelBufferGetWidth(foreImageBuffer),CVPixelBufferGetHeight(foreImageBuffer));
    CVPixelBufferRef output = [self renderForePixelBuffer:foreImageBuffer];
    //CVPixelBufferRelease(tempixelBuffer);
    return output;
}

- (void)clearForeImageCache
{
    if (foreImageBuffer) {
        CVPixelBufferRelease(foreImageBuffer);
        foreImageBuffer = NULL;
    }
}

- (CVPixelBufferRef)startRenderWithBackImage:(UIImage *)image
{
    if (backImageBuffer == NULL) {
        backImageBuffer = [self CVPixelBufferRefFromUiImage:image];
    }
    frameSize = CGSizeMake(CVPixelBufferGetWidth(backImageBuffer),CVPixelBufferGetHeight(backImageBuffer));
    CVPixelBufferRef output = [self renderBackPixelBuffer:backImageBuffer];
    //CVPixelBufferRelease(tempixelBuffer);
    return output;
}

- (void)clearBackImageCache
{
    if (backImageBuffer) {
        CVPixelBufferRelease(backImageBuffer);
        backImageBuffer = NULL;
    }
}

//MARK:边框特效视频渲染
- (CVPixelBufferRef)startRenderMaskVideoWithPixelBufferRef:(CVPixelBufferRef)backBuffer maskVideoBuffer:(CVPixelBufferRef)foreBuffer
{
    CVPixelBufferRef output;
    
    frameSize = CGSizeMake(CVPixelBufferGetWidth(backBuffer),CVPixelBufferGetHeight(backBuffer));
    
    if (frameSize.width > 1920) {
        frameSize = CGSizeMake(1920, 1080);
    }
    
    self.programId = maskProgramID;
    
    output = [self convertMaskVideoTexture:foreBuffer ToPixelBufferWith:backBuffer];
    
    return output;
}

- (CVPixelBufferRef)convertTextureToPixelBuffer:(CVPixelBufferRef)imagePB
{
    if (!self.context) {
        return nil;
    }
    
    CGSize textureSize = CGSizeMake(CVPixelBufferGetWidth(imagePB),CVPixelBufferGetHeight(imagePB));
    
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
    
    //新建一个空的CVPixelBuffer用来存储渲染后的数据
    if (!newPixelBuffer) {
        newPixelBuffer = [self createPixelBufferWithSize:textureSize];
    }
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:newPixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    CVOpenGLESTextureRef imageTexture = [self convertRGBPixelBufferToTextureRef:imagePB];
    textureID = CVOpenGLESTextureGetName(imageTexture);
    
    GLuint frameRGBBuffer;
    glGenFramebuffers(1, &frameRGBBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameRGBBuffer);
    GLuint frameRGBBufferTexture;
    glGenTextures(1, &frameRGBBufferTexture);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameRGBBufferTexture, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //方向旋转
    glUseProgram(foreProgramID);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(foreProgramID, "toTexture"), 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.foreVBO);
    GLuint secondPositionSlot = glGetAttribLocation(foreProgramID, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(foreProgramID, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //添加渲染滤镜
    glUseProgram(foreFilterProgramID);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(foreFilterProgramID, "fromTexture"), 1);
    
    glActiveTexture(GL_TEXTURE4);
    //附带的纹理图片存在，且未生成纹理ID
    glBindTexture(GL_TEXTURE_2D, _maskImgTextureID);
    glUniform1i(glGetUniformLocation(foreFilterProgramID, "maskImageTexture"), 4);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint PositionSlot = glGetAttribLocation(foreFilterProgramID, "Position");
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint TextureSlot = glGetAttribLocation(foreFilterProgramID, "TextureCoords");
    glEnableVertexAttribArray(TextureSlot);
    glVertexAttribPointer(TextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameRGBBuffer);
    if (resultTexture) {
        CFRelease(resultTexture);
        resultTexture = NULL;
    }
    if (imageTexture) {
        CFRelease(imageTexture);
        imageTexture = NULL;
    }
    if (_photoTextureCache) {
        CFRelease(_photoTextureCache);
        _photoTextureCache = NULL;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &frameRGBBufferTexture);
    glFlush();
    
    return newPixelBuffer;
}

//MARK:横竖方向视频转换
- (CVPixelBufferRef)renderForePixelBuffer:(CVPixelBufferRef)imagePB
{
    if (!self.context) {
        return nil;
    }
    
    CGSize textureSize = CGSizeMake(1920,1080);
    
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
    
    if (!forePixelBuffer) {
        forePixelBuffer = [self createPixelBufferWithSize:textureSize];
    }
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:forePixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    CVOpenGLESTextureRef imageTexture = [self convertRGBPixelBufferToTextureRef:imagePB];
    textureID = CVOpenGLESTextureGetName(imageTexture);
    
    GLuint frameRGBBuffer;
    glGenFramebuffers(1, &frameRGBBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameRGBBuffer);
    GLuint frameRGBBufferTexture;
    glGenTextures(1, &frameRGBBufferTexture);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameRGBBufferTexture, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //方向旋转
    glUseProgram(foreProgramID);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(foreProgramID, "toTexture"), 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.foreVBO);
    GLuint secondPositionSlot = glGetAttribLocation(foreProgramID, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(foreProgramID, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //添加渲染滤镜
    glUseProgram(foreFilterProgramID);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(foreFilterProgramID, "fromTexture"), 1);
    
    glActiveTexture(GL_TEXTURE4);
    //附带的纹理图片存在，且未生成纹理ID
    glBindTexture(GL_TEXTURE_2D, _maskImgTextureID);
    glUniform1i(glGetUniformLocation(foreFilterProgramID, "maskImageTexture"), 4);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint PositionSlot = glGetAttribLocation(foreFilterProgramID, "Position");
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint TextureSlot = glGetAttribLocation(foreFilterProgramID, "TextureCoords");
    glEnableVertexAttribArray(TextureSlot);
    glVertexAttribPointer(TextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameRGBBuffer);
    if (resultTexture) {
        CFRelease(resultTexture);
        resultTexture = NULL;
    }
    if (imageTexture) {
        CFRelease(imageTexture);
        imageTexture = NULL;
    }
    if (_photoTextureCache) {
        CFRelease(_photoTextureCache);
        _photoTextureCache = NULL;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &frameRGBBufferTexture);
    glFlush();
    
    return forePixelBuffer;
}

- (CVPixelBufferRef)renderBackPixelBuffer:(CVPixelBufferRef)imagePB
{
    if (!self.context) {
        return nil;
    }
    
    CGSize textureSize = CGSizeMake(1920,1080);
    
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
    
    if (!backPixelBuffer) {
        backPixelBuffer = [self createPixelBufferWithSize:textureSize];
    }
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:backPixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    CVOpenGLESTextureRef imageTexture = [self convertRGBPixelBufferToTextureRef:imagePB];
    textureID = CVOpenGLESTextureGetName(imageTexture);
    
    GLuint frameRGBBuffer;
    glGenFramebuffers(1, &frameRGBBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameRGBBuffer);
    GLuint frameRGBBufferTexture;
    glGenTextures(1, &frameRGBBufferTexture);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameRGBBufferTexture, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //方向旋转
    glUseProgram(backProgramID);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(backProgramID, "toTexture"), 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.backVBO);
    GLuint secondPositionSlot = glGetAttribLocation(backProgramID, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(backProgramID, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //添加渲染滤镜
    glUseProgram(backFilterProgramID);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, frameRGBBufferTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(backFilterProgramID, "fromTexture"), 1);
    
    glActiveTexture(GL_TEXTURE2);
    //附带的纹理图片存在，且未生成纹理ID
    glBindTexture(GL_TEXTURE_2D, _maskImgTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(backFilterProgramID, "maskImageTexture"), 2);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint PositionSlot = glGetAttribLocation(backFilterProgramID, "Position");
    glEnableVertexAttribArray(PositionSlot);
    glVertexAttribPointer(PositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint TextureSlot = glGetAttribLocation(backFilterProgramID, "TextureCoords");
    glEnableVertexAttribArray(TextureSlot);
    glVertexAttribPointer(TextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameRGBBuffer);
    if (resultTexture) {
        CFRelease(resultTexture);
        resultTexture = NULL;
    }
    if (imageTexture) {
        CFRelease(imageTexture);
        imageTexture = NULL;
    }
    if (_photoTextureCache) {
        CFRelease(_photoTextureCache);
        _photoTextureCache = NULL;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &frameRGBBufferTexture);
    glFlush();
    
    return backPixelBuffer;
}

//MARK:单独RGB渲染
- (CVPixelBufferRef)convertTextueWithRGBPixelBuffer:(CVPixelBufferRef)imagePB textureSize:(CGSize)textureSize {
    
    if (!self.context) {
        NSLog(@"===============context为空==================");
        
        return nil;
    }
    
    [EAGLContext setCurrentContext:self.context];
    
    CVPixelBufferRef pixelBuffer = [self createPixelBufferWithSize:textureSize];
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:pixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    CVOpenGLESTextureRef imageTexture = [self convertRGBPixelBufferToTextureRef:imagePB];
    textureID = CVOpenGLESTextureGetName(imageTexture);
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(beautyProgramID);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(beautyProgramID, "fromTexture"), 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint secondPositionSlot = glGetAttribLocation(beautyProgramID, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(beautyProgramID, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameBuffer);
    
    if (resultTexture) {
        CFRelease(resultTexture);
    }
    if (imageTexture) {
        CFRelease(imageTexture);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glFlush();
    
    return pixelBuffer;
}


//MARK:单独RGB渲染
- (CVPixelBufferRef)convertTexture:(CVPixelBufferRef)foreBuffer ToPixelBufferWith:(CVPixelBufferRef)backBuffer textureSize:(CGSize)textureSize {
    
    if (!self.context) {
        NSLog(@"===============context为空==================");
        
        return nil;
    }
    
    [EAGLContext setCurrentContext:self.context];
    //新建一个空的CVPixelBuffer用来存储渲染后的数据
    if (!transPixelBuffer) {
        transPixelBuffer = [self createPixelBufferWithSize:textureSize];
    }
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:transPixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    
    CVOpenGLESTextureRef foreTexture = [self convertRGBPixelBufferToTextureRef:foreBuffer];
    foreTextureID = CVOpenGLESTextureGetName(foreTexture);
    CVOpenGLESTextureRef backTexture = [self convertRGBPixelBufferToTextureRef:backBuffer];
    backTextureID = CVOpenGLESTextureGetName(backTexture);
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(self.programId);
    
    //绑定输入参数
    [self bindUniforms];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, foreTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(self.programId, "fromTexture"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, backTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(self.programId, "toTexture"),1);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint secondPositionSlot = glGetAttribLocation(self.programId, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(self.programId, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameBuffer);
    
    if (resultTexture) {
        CFRelease(resultTexture);
    }
    if (foreTexture) {
        CFRelease(foreTexture);
    }
    if (backTexture) {
        CFRelease(backTexture);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glFlush();
    
    return transPixelBuffer;
}

- (CVPixelBufferRef)convertMaskVideoTexture:(CVPixelBufferRef)foreBuffer ToPixelBufferWith:(CVPixelBufferRef)backBuffer {
    
    if (!self.context) {
        NSLog(@"===============context为空==================");
        
        return nil;
    }
    
    [EAGLContext setCurrentContext:self.context];
    CGSize textureSize = CGSizeMake(1920, 1080);
    //新建一个空的CVPixelBuffer用来存储渲染后的数据
    CVPixelBufferRef pixelBuffer = [self createPixelBufferWithSize:textureSize];
    CVOpenGLESTextureRef resultTexture = [self convertRGBPixelBufferToTextureRef:pixelBuffer];
    targetTextureID = CVOpenGLESTextureGetName(resultTexture);
    
    CVOpenGLESTextureRef foreTexture = [self convertRGBPixelBufferToTextureRef:foreBuffer];
    foreTextureID = CVOpenGLESTextureGetName(foreTexture);
    CVOpenGLESTextureRef backTexture = [self convertRGBPixelBufferToTextureRef:backBuffer];
    backTextureID = CVOpenGLESTextureGetName(backTexture);
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glBindTexture(GL_TEXTURE_2D, targetTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, targetTextureID, 0);
    glViewport(0, 0, textureSize.width, textureSize.height);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(self.programId);
    
    //绑定输入参数
    [self bindUniforms];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, foreTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(self.programId, "fromTexture"), 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, backTextureID);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glUniform1i(glGetUniformLocation(self.programId, "toTexture"),1);
    
    glBindBuffer(GL_ARRAY_BUFFER, self.VBO);
    GLuint secondPositionSlot = glGetAttribLocation(self.programId, "Position");
    glEnableVertexAttribArray(secondPositionSlot);
    glVertexAttribPointer(secondPositionSlot, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    GLuint secondTextureSlot = glGetAttribLocation(self.programId, "TextureCoords");
    glEnableVertexAttribArray(secondTextureSlot);
    glVertexAttribPointer(secondTextureSlot, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3* sizeof(float)));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDeleteFramebuffers(1, &frameBuffer);
    
    if (resultTexture) {
        CFRelease(resultTexture);
    }
    if (foreTexture) {
        CFRelease(foreTexture);
    }
    if (backTexture) {
        CFRelease(backTexture);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glFlush();
    
    return pixelBuffer;
}


#pragma mark - 属性设置 参数设置 Uniforms-
- (void)bindUniforms
{
    
    glUniform1f( [self getLoc:@"progress" program:self.programId], _currentProgress );

    glUniform1f( [self getLoc:@"iTime" program:self.programId], [self getTime] );
    
    _frameIndex++;
    glUniform1f( [self getLoc:@"iFrame" program:self.programId], _frameIndex);
    
    //_currentProgress = _currentProgress + preFrameProgressValue;
    if (_currentProgress > 1.0) {
        _currentProgress = 1.0;
    }
}

- (GLuint) getLoc:(NSString *)key program:(GLuint)program {
   // NSLog(@"%@ %d", key, glGetUniformLocation(program, key.UTF8String));
    return glGetUniformLocation(program, key.UTF8String);
}

- (CVOpenGLESTextureCacheRef)textureCache {
    if (!_textureCache) {
        EAGLContext *context = self.context;
        CVReturn status = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, nil, context, nil, &_textureCache);
        if (status != kCVReturnSuccess) {
            NSLog(@"Can't create textureCache");
        }
    }
    return _textureCache;
}

- (void)setTransitionDuration:(NSTimeInterval)transitionDuration
{
    _transitionDuration = transitionDuration;
    if (_transitionDuration > 0) {
        preFrameProgressValue = 1.0 / (_transitionDuration * 29.0);
    }
    self.currentProgress = 0; //设置时间时清零
}

- (void)setCurrentTransitionProgressValue:(float)value
{
    self.currentProgress = value;
    NSLog(@"转场进度时间:%f",value);
}

- (void)clearTransitionProgress
{
    if (self.currentProgress) {
        self.currentProgress = 0; //设置时间时清零
    }
}

- (float)getIGlobalTime {
    CGFloat value = _totalTime + [[NSDate date] timeIntervalSinceDate:_startTime];
//    NSLog(@"totalTime = %f",value);
    return value/3.0;
}

- (float)getTime {
    return [self getIGlobalTime];
}

#pragma mark - Shader Compile and Link
//link Program
- (GLuint)programWithShaderName:(NSString *)shaderName {
    //1. 编译顶点着色器/片元着色器
    GLuint vertexShader = [self compileShaderWithName:shaderName type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:shaderName type:GL_FRAGMENT_SHADER];
    
    //2. 将顶点/片元附着到program
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    //3.linkProgram
    glLinkProgram(program);
    
    //4.检查是否link成功
    GLint linkSuccess;
    glGetProgramiv(program, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(program, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"program链接失败：%@", messageString);
        exit(1);
    }
    glDetachShader(program, vertexShader);
    glDeleteShader(vertexShader);
    glDetachShader(program, fragmentShader);
    glDeleteShader(fragmentShader);
    
    //5.返回program
    return program;
}

//编译shader代码
- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    
    //1.获取shader 路径
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:name ofType:shaderType == GL_VERTEX_SHADER ? @"vsh" : @"fsh"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    
    //2. 创建shader->根据shaderType
    GLuint shader = glCreateShader(shaderType);
    
    //3.获取shader source
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    //4.编译shader
    glCompileShader(shader);
    
    //5.查看编译是否成功
    GLint compileSuccess;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shader, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSAssert(NO, @"shader编译失败：%@", messageString);
        exit(1);
    }
    //6.返回shader
    return shader;
}

#pragma mark - Public
- (CVPixelBufferRef)createPixelBufferWithSize:(CGSize)size {
    CVPixelBufferRef pixelBuffer;
    NSDictionary *pixelBufferAttributes = @{(id)kCVPixelBufferIOSurfacePropertiesKey: @{}};
    CVReturn status = CVPixelBufferCreate(nil,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef _Nullable)(pixelBufferAttributes),
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        NSLog(@"Can't create pixelbuffer");
    }
    return pixelBuffer;
}

- (CVOpenGLESTextureRef)convertRGBPixelBufferToTextureRef:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) {
        return 0;
    }
    
    CGSize textureSize = CGSizeMake(CVPixelBufferGetWidth(pixelBuffer),
                                    CVPixelBufferGetHeight(pixelBuffer));
    CVOpenGLESTextureRef texture = nil;
    
    CVReturn status = CVOpenGLESTextureCacheCreateTextureFromImage(nil,
                                                                   self.textureCache,
                                                                   pixelBuffer,
                                                                   nil,
                                                                   GL_TEXTURE_2D,
                                                                   GL_RGBA,
                                                                   textureSize.width,
                                                                   textureSize.height,
                                                                   GL_BGRA,
                                                                   GL_UNSIGNED_BYTE,
                                                                   0,
                                                                   &texture);
    
    if (status != kCVReturnSuccess) {
        NSLog(@"Can't create texture");
    }
    return texture;
}

- (GLuint)getTextureFromImage:(UIImage *)image needTranslate:(BOOL)need {
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(textureData, width, height, bitsPerComponent, bytesPerRow, colorSpaceRef, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    
    if (need) {
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
    }

    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, imageRef);
    
    glEnable(GL_TEXTURE_2D);
    
    GLuint texureName;
    glGenTextures(1, &texureName);
    glBindTexture(GL_TEXTURE_2D, texureName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpaceRef);
    free(textureData);
    return texureName;
}
//MARK: - Image 转为 CVPixelBufferRef
static OSType inputPixelFormat(){
    return kCVPixelFormatType_32BGRA;
}

static uint32_t bitmapInfoWithPixelFormatType(OSType inputPixelFormat, bool hasAlpha){
    
    if (inputPixelFormat == kCVPixelFormatType_32BGRA) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        return bitmapInfo;
    }else if (inputPixelFormat == kCVPixelFormatType_32ARGB) {
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big;
        return bitmapInfo;
    }else{
        NSLog(@"不支持此格式");
        return 0;
    }
}

// alpha的判断
BOOL CGImageRefContainsAlpha(CGImageRef imageRef) {
    if (!imageRef) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}
// 此方法能还原真实的图片
- (CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img {
    CGSize size;
    UIImageOrientation ori = img.imageOrientation;
    switch (ori) {
        case UIImageOrientationRight:
        case UIImageOrientationLeft:
        {
            CGFloat width = img.size.width;
            CGFloat height = img.size.height;
            if (width > height) {
                size = CGSizeMake(width, height);
            }
            else{
                size = CGSizeMake(height, width);
            }
        }
            break;
        case UIImageOrientationUp:
        {
            CGFloat width = img.size.width;
            CGFloat height = img.size.height;
            size = CGSizeMake(width, height);
        }
            break;
        case UIImageOrientationDown:
        {
            CGFloat width = img.size.width;
            CGFloat height = img.size.height;
            if (width < height) {
                size = CGSizeMake(width, height);
            }
            else{
                size = CGSizeMake(height, width);
            }
        }
            break;
            
        default:
            break;
    }
    CGImageRef image = [img CGImage];
    
    BOOL hasAlpha = CGImageRefContainsAlpha(image);
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             empty, kCVPixelBufferIOSurfacePropertiesKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, inputPixelFormat(), (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t bitmapInfo = bitmapInfoWithPixelFormatType(inputPixelFormat(), (bool)hasAlpha);
    
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, CVPixelBufferGetBytesPerRow(pxbuffer), rgbColorSpace, bitmapInfo);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CFRelease(empty);
    
    return pxbuffer;
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

- (void)cleanUpContext
{
    if (self.context) {
        self.context = nil;
    }
    
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
    
    if (self.programId) {
        glDeleteProgram(self.programId);
        self.programId = 0;
    }
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    if (forePixelBuffer) {
        CVPixelBufferRelease(forePixelBuffer);
        forePixelBuffer = NULL;
    }
    if (backPixelBuffer) {
        CVPixelBufferRelease(backPixelBuffer);
        backPixelBuffer = NULL;
    }
    if (newPixelBuffer) {
        CVPixelBufferRelease(newPixelBuffer);
        newPixelBuffer = NULL;
    }
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    if (self.VBO) {
        glDeleteBuffers(1, &_VBO);
    }
    if (self.foreVBO) {
        glDeleteBuffers(1, &_foreVBO);
    }
    if (self.backVBO) {
        glDeleteBuffers(1, &_backVBO);
    }
    if (self.rotateVBO) {
        glDeleteBuffers(1, &_rotateVBO);
    }
    
    
    if (foreTextureID != 0) {
        glDeleteTextures(1, &foreTextureID);
        foreTextureID = 0;
    }
    
    if (backTextureID != 0) {
        glDeleteTextures(1, &backTextureID);
        backTextureID = 0;
    }
    
    if (targetTextureID != 0) {
        glDeleteTextures(1, &targetTextureID);
        targetTextureID = 0;
    }
    
    [self cleanUpContext];
    
    
    if (foreImageBuffer != NULL) {
        CVPixelBufferRelease(foreImageBuffer);
    }
    
    if (backImageBuffer != NULL) {
        CVPixelBufferRelease(backImageBuffer);
    }
    
    if (transitionID) {
        glDeleteProgram(transitionID);
        transitionID = 0;
    }
    if (foreProgramID) {
        glDeleteProgram(foreProgramID);
        foreProgramID = 0;
    }
    if (backProgramID) {
        glDeleteProgram(backProgramID);
        backProgramID = 0;
    }
    
    if (foreFilterProgramID) {
        glDeleteProgram(foreFilterProgramID);
        foreFilterProgramID = 0;
    }
    if (backFilterProgramID) {
        glDeleteProgram(backFilterProgramID);
        backFilterProgramID = 0;
    }
}

@end

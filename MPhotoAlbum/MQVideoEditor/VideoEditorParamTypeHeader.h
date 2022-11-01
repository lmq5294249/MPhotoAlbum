//
//  VideoEditorParamTypeHeader.h
//  音视频特效
//
//  Created by 林漫钦 on 2021/12/10.
//  Copyright © 2021 mac. All rights reserved.
//

#ifndef VideoEditorParamTypeHeader_h
#define VideoEditorParamTypeHeader_h

#define D_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define D_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

typedef void(^WaitingBlock)(void);

typedef void(^HideAlertViewBlock)(void);

typedef void(^UpdateBlock)(void);

typedef NS_ENUM(NSUInteger, MQEditWorkModel) {
    MQEditVideoModel,
    MQEditMusicModel,
    MQEditStickerModel, //贴图GIF或者文字类型
    MQEditTemplateModel, //特殊架构的模板类型
};


/*
 
 */
typedef NS_ENUM(NSUInteger, VideoProgram) {
    VideoProgramForEditing, //编辑加减速倒放
    VideoProgramForCliping, //裁剪分段视频
    VideoProgramForTransition, //转场渲染过度
    VideoProgramForMerging, //合并部分视频
    VideoProgramForExportVideo, //导出最终视频
};


/*
 这个是媒体数据数组中的一个选项，model中的类型
 */
typedef NS_ENUM(NSUInteger, MQMediaType) {
    MQMediaTypeVideo,
    MQMediaTypePhoto,
    MQMediaTypeAudio,
};

/*
 转场动画类型选项
 */
typedef NS_ENUM(NSUInteger, MQTransitionType) {
    MQTransitionTypeDoorWay             = 0, //开门转场
    MQTransitionTypeCrosswarp           = 1,
    MQTransitionTypeScaleIn             = 2,
    MQTransitionTypeSwipeLeft           = 3,
    MQTransitionTypeWindowSlice         = 4,
    MQTransitionTypeSwap                = 5,
    MQTransitionTypeSquareswire         = 6,
    MQTransitionTypeRotateScaleFade     = 7,
    MQTransitionTypeCube                = 8,
    MQTransitionTypeRipple              = 9,
    MQTransitionTypeWaterDrop           = 10,
    MQTransitionTypeColourDistance      = 11,
    MQTransitionTypeGirdFlip            = 12,
    MQTransitionTypeGlitchMemories      = 13,
    MQTransitionTypeLeftRight           = 14,
    MQTransitionTypeInvertedPageCurl    = 15,
};

/*
 视频剪辑的设置项 -> 选择设置播放类型 （一般是预处理视频的固定选项）
 */
typedef NS_ENUM(NSUInteger, SpeedType) {
    SpeedTypeNormal,         //正常播放X1
    SpeedTypeFastDouble,     //加速X2
    SpeedTypeFastThreefold,  //加速X3
    SpeedTypeFastFourfold,   //加速X4
    SpeedTypeSlowDouble,     //减速X2
};




#endif /* VideoEditorParamTypeHeader_h */

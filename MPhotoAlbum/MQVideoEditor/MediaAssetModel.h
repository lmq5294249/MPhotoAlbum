//
//  MediaAssetModel.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/8.
//  Copyright © 2021 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <Photos/PHAsset.h>
#import "VideoEditorParamTypeHeader.h"

//@class MediaAssetModel
//MARK:- MTransitionNode定义一个转场节点的类来设置 -
@interface MTransitionNode : NSObject

@property (nonatomic, assign) NSInteger nodeIndex; // 转场节点的序列号

@property (nonatomic, assign) MQTransitionType transitionType;  //转场类型

@property (nonatomic, assign) NSTimeInterval transitionDuration; //转场时间

@property (nonatomic, strong) NSURL *transVideoUrl; //结果存入这个位置

//MARK:转场第一个文件
@property (nonatomic, assign) SpeedType firstSpeedType;

@property (nonatomic, assign) MQMediaType firstMediaType;

@property (nonatomic, strong) NSURL *firstVideoUrl;

@property (nonatomic, strong) UIImage *firstImage;



//MARK:转场第一个文件
@property (nonatomic, assign) SpeedType secondSpeedType;

@property (nonatomic, assign) MQMediaType secondMediaType;

@property (nonatomic, strong) NSURL *secondVideoUrl;

@property (nonatomic, strong) UIImage *secondImage;

@end


//MARK:- 父类MediaAssetModel -

@interface MediaAssetModel : NSObject

@property (nonatomic, assign) MQMediaType mediaType;

@property (nonatomic, strong) PHAsset * asset;

@property (nonatomic, assign)PHAssetMediaType propertyType;

@property (nonatomic, strong)UIImage * propertyThumbImage; //缩略图，截取一张低清用来显示

@property (nonatomic, strong) NSURL *originalVideoUrl; //视频的Url地址 单纯的视频不包含转场动画

@property (nonatomic, assign) SpeedType videoSpeedType;

@property (nonatomic, strong) UIImage *image; //图片的原图

@property (nonatomic, assign) BOOL needCompressed;//这里针对高清视频或者高分辨率图片，需要进行压缩处理，不然内存会爆

@property (nonatomic, assign) MQTransitionType transitionType;

@property (nonatomic, assign) NSTimeInterval transitionDuration; //转场时长一般控制在1s内，不宜过长，其实也没关系，不过会影响到后面时长

@property (nonatomic, assign) NSInteger locationIndex; //文件排列在数组中的位置，也就是视频播放的顺序

@property (nonatomic, assign) MTransitionNode *transitionNode; //保存转场的节点

@end

//MARK:- 视频子类VideoAssetModel -
@interface VideoAssetModel : MediaAssetModel

/*
 clipTimeRanges =  clipStartTimeRanges + clipEndTimeRanges
 这里这样设置是因为便于后续的转场读取数据做渲染，避免需要读取很多数据，只需要读取特定的需要转场的那部分数据就OK，节省渲染的时间更好更快的显示处理后的视频效果
 */

@property (nonatomic) CMTimeRange clipStartTimeRanges; //开头前一部分的时间长度范围

@property (nonatomic, strong) NSURL *startVideoClipUrl; //开头前一部分可能是转场专用

@property (nonatomic) CMTimeRange clipMiddleTimeRanges; //中间视频片段的时间长度范围

@property (nonatomic, strong) NSURL *middleVideoClipUrl; //中间独立播放

@property (nonatomic) CMTimeRange clipEndTimeRanges; //后面视频片段的时间长度范围

@property (nonatomic, strong) NSURL *endVideoClipUrl; //后面视频片段 是 转场专用片段 跟后面视频混合

@property (nonatomic, strong) NSURL *editingVideoUrl; //经过剪辑后的视频

@property (nonatomic, strong) NSURL *mergeVideoUrl; //经过处理后的播放独立的视频不包含转场动画（用于拼接部分）

@property (nonatomic, strong) NSString * videoDuration;

@property (nonatomic) CMTimeRange clipTimeRanges; //(这个是总的片段)defaultTimeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMake(5, 1));视频属性截取部分视频长度

@end

//MARK:- 图片子类PhotoAssetModel -
@interface PhotoAssetModel : MediaAssetModel

@property (nonatomic, strong) NSURL *imageVideoUrl; //图片转为视频数据（这部分只是为了便于在AVplayer里面播放而设置的）

@property (nonatomic, assign) NSTimeInterval imageDuration; //图片在片段中停留的时长，去除掉转场后的时间默认设置 1s，因为前后转场说加起来 2s =>图片独立播放的时间

@end





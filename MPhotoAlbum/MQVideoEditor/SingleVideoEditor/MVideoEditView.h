//
//  MVideoEditView.h
//  抖音特效-音视频变速
//
//  Created by 林漫钦 on 2021/12/17.
//  Copyright © 2021 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaAssetModel.h"
#import "VideoEditorParamTypeHeader.h"
#import "LocalAssetModel.h"
#import "EditTemplateModel.h"

@interface MVideoEditView : UIView

//---2022.4.22修改---
/*
 需要传入数据是视频源数据 和 模板对应的编辑模型数据
 */

@property (nonatomic, strong) AVURLAsset * assetURL;

@property (nonatomic, strong) EditUnitModel *editModel;

//------------------
@property (nonatomic, strong) NSMutableArray <LocalAssetModel*>* mediaAssetArray;

@property (nonatomic, strong) NSMutableArray *clipTimeRanges;

@property (nonatomic, strong) EditTemplateModel *templateModel;

@property (nonatomic, strong) NSMutableArray <MTransitionNode*>* transitionNodeArray;

@property (nonatomic, assign) NSInteger index; //需要编辑的媒体编号

@property (nonatomic, copy) WaitingBlock waitingBlock;

@property (nonatomic, copy) UpdateBlock updateBlock;

@property (nonatomic, copy) HideAlertViewBlock hideAlertBlock;

- (instancetype)initWithFrame:(CGRect)frame withMediaAssetArray:(NSMutableArray*)array mediaIndex:(NSInteger)mediaIndex;

- (void)updateInterfaceAndData;
@end

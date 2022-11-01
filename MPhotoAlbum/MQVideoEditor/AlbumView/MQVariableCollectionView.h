//
//  MQVariableCollectionView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/22.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"
#import "VideoEditorParamTypeHeader.h"

@protocol VideoEditedDelegate <NSObject>

- (void)startToEditSingleVideoWithIndex:(NSInteger)index;

@end

@interface MQVariableCollectionView : UIView

@property (weak) id<VideoEditedDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *mediaDic;

@property (nonatomic, copy) NSArray *templateModelArray;

@property (nonatomic, strong) NSMutableArray *clipTimeRanges; //各个片段对应的时间起始点

@property (nonatomic, strong) NSMutableArray <LocalAssetModel*>*mediaAssetArray; //各个片段的排列顺序

@property (nonatomic, assign) NSInteger fixedNum;

@property (nonatomic, copy) UpdateBlock updateBlock;

-(void)reloadData;

@end



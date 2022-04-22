//
//  MQVariableCollectionView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/22.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"
#import "VideoEditorParamTypeHeader.h"

@interface MQVariableCollectionView : UIView

@property (nonatomic, strong) NSMutableDictionary *mediaDic;

@property (nonatomic, copy) NSArray *templateModelArray;

@property (nonatomic, strong) NSMutableArray <LocalAssetModel*>*mediaAssetArray;

@property (nonatomic, assign) NSInteger fixedNum;

@property (nonatomic, strong) UIView *fatherView;

@property (nonatomic, copy) UpdateBlock updateBlock;

-(void)reloadData;

@end



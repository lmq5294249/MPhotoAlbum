//
//  OptionalEditView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/4/7.
//

#import <UIKit/UIKit.h>
#import "LocalAssetModel.h"
#import "EditTemplateModel.h"

typedef void(^DeleteOptionalModelBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface OptionalEditView : UIView

@property (nonatomic, strong) NSMutableDictionary *optionalDict;

@property (nonatomic, assign) NSInteger maxcount;

@property (nonatomic, assign) NSInteger currentCount;

@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, assign) BOOL completed;

@property (nonatomic, copy) NSArray <EditUnitModel*>* templateModelArray;

@property (nonatomic, copy) DeleteOptionalModelBlock deleteOptionalModelBlock;

- (NSInteger)getNextIndex;

- (void)deleteSelectedDictModel:(NSInteger)index;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END

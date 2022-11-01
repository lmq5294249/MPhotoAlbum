//
//  MExportVideoViewController.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/16.
//

#import <UIKit/UIKit.h>
#import "EditTemplateModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MExportVideoViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *clips;

@property (nonatomic, strong) NSMutableArray *clipTimeRanges;

@property (nonatomic, strong) NSMutableArray *transTimeArray;

@property (nonatomic, strong) EditTemplateModel *templateModel;

- (void)initVideoExportManagerParam;

- (void)didClickExportVideoButton;

@end

NS_ASSUME_NONNULL_END

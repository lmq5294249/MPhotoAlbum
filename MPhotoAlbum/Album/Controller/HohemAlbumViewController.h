//
//  HohemAlbumViewController.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/14.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <Photos/Photos.h>
#import "TationDeviceManager.h"
#import "MSlidePageView.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    
    HohemAlbumViewController_ShowType_Photo,
    HohemAlbumViewController_ShowType_Video
    
} HohemAlbumViewController_ShowType;

typedef enum{
    
    HohemAlbum_Mode_Viewer,
    HohemAlbum_Mode_DeleteItems,
    HohemAlbum_Mode_VideoEditor,
    HohemAlbum_Mode_ReplaceMedia,
} HohemAlbum_Mode;

@interface HohemAlbumViewController : UIViewController

@property (nonatomic, assign) HohemAlbum_Mode albumMode; //相册模式
@property (nonatomic, assign) BOOL hiddenBackBtn;

@property (nonatomic, assign) HohemAlbumViewController_ShowType showType;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*dataFetchResult;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*photoFetchResult;
@property (nonatomic, copy) PHFetchResult <PHAsset *>*videoFetchResult;
@property (nonatomic, strong) NSMutableDictionary *videoDic;
@property (nonatomic, strong) NSMutableDictionary *photoDic;
@property (nonatomic, strong) NSMutableArray *photoKeyArr;
@property (nonatomic, strong) NSMutableArray *videoKeyArr;
@property (nonatomic, strong) NSMutableDictionary *mediaModelDataDic;
@property (nonatomic, strong) NSMutableArray *mediaModelDataArr;
@property (nonatomic, strong) NSMutableArray *mediaModelArr;
@property (nonatomic, strong) NSMutableArray *fileNameArray;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIImageView *labelImageVIew;
@property (nonatomic, strong) MSlidePageView *slidePageView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UIButton *deletedBtn;
@property (nonatomic, strong) UIButton *videoEditorBtn;
@property (nonatomic, strong) UIButton *editedBtn;
@property (nonatomic, assign) BOOL isEnableEdit;
@property (nonatomic, assign) CGFloat fitRatio;

@end

NS_ASSUME_NONNULL_END

//
//  HohemAlbumViewController.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/14.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import <Photos/Photos.h>


NS_ASSUME_NONNULL_BEGIN

typedef enum{
    
    HohemAlbumViewController_ShowType_Photo,
    HohemAlbumViewController_ShowType_Video
    
} HohemAlbumViewController_ShowType;

typedef enum{

    HohemAlbum_Mode_Viewer,
    HohemAlbum_Mode_DeleteItems,
    HohemAlbum_Mode_VideoEditor,
    
} HohemAlbum_Mode;

@interface HohemAlbumViewController : UIViewController

@property (nonatomic, assign) BOOL hiddenBackBtn;

@end

NS_ASSUME_NONNULL_END

//
//  PHPhotoLibraryManage.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Photos/PHFetchResult.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/PHImageManager.h>

@interface PHPhotoLibraryManage : NSObject


@property(nonatomic,strong)NSDictionary * dic;


/**
 *  遍历相册
 *
 *  @param photoName      相册名
 */
- (void)ergodicPhotoAlbumWithPhotoName:(NSString *)photoName;

@end

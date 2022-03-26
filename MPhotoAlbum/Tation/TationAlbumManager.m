//
//  TationAlbumManager.m
//  Hohem Pro
//
//  Created by jolly on 2020/4/19.
//  Copyright © 2020 jolly. All rights reserved.
//

#import "TationAlbumManager.h"
#import <PhotosUI/PhotosUI.h>
#import <Photos/Photos.h>

@implementation TationAlbumManager

//获取相册封面图片
+ (void)getAlbumCoverImage:(TationAlbumManager_Type)type imageSize:(CGSize)imageSize finish:(void(^)(UIImage *coverImage))finish {
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    options.sortDescriptors = @[descriptor];
    if (type == TationAlbumManager_Type_Image) {
        
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeImage];
    }else if (type == TationAlbumManager_Type_Video) {
        
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
    }
    
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = result.firstObject;
    
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
    imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    if (asset) {
        
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            if (result) finish(result);
        }];
    }
}


@end

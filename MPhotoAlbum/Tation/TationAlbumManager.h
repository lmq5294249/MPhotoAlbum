//
//  TationAlbumManager.h
//  Hohem Pro
//
//  Created by jolly on 2020/4/19.
//  Copyright © 2020 jolly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,TationAlbumManager_Type) {
    
    TationAlbumManager_Type_Image = 1,
    TationAlbumManager_Type_Video = 2
};

@interface TationAlbumManager : NSObject

//获取相册封面图片
+ (void)getAlbumCoverImage:(TationAlbumManager_Type)type imageSize:(CGSize)imageSize finish:(void(^)(UIImage *coverImage))finish;

@end

NS_ASSUME_NONNULL_END

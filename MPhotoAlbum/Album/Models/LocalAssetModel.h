//
//  LocalAssetModel.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
NS_ASSUME_NONNULL_BEGIN

@interface LocalAssetModel : NSObject

/**
 *  源地址
 */
@property (strong,nonatomic) PHAsset * asset;
///**
// *  资源大小
// */
@property(nonatomic, assign)long long propertySize;
/**
 *  缩略图
 */
@property (nonatomic, strong)UIImage * propertyThumbImage;
/**
 *  文件名称
 */
@property (nonatomic, strong)NSString *propertyName;
/**
 *  文件类型
 */
@property (nonatomic, assign)PHAssetMediaType propertyType;
/**
 *  文件拍摄地址
 */
@property (nonatomic, strong)NSString * propertyLocation;
/**
 *  文件时长
 */
@property (nonatomic, assign)double propertyDuration;//是照片返回kALErrorInvalidProperty
/**
 *  方向
 */
@property (nonatomic, strong)NSString * propertyOrientation;
/**
 *  创建时间
 */
@property (nonatomic, strong)NSString * propertyDate;
/**
 *  描述信息
 */
@property (nonatomic, strong)NSString * propertyRepresentations;
/**
 *  URL地址
 */
@property (nonatomic, strong)NSURL * propertyAssetURL;
/**
 *  model选中状态的bool值
 */
@property (nonatomic,assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END

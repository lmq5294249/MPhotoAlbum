//
//  GuideDataModel.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/17.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GuideType) {
    ProductManualGuideType, //产品手册
    FAQGuideType, //常见问题
};

NS_ASSUME_NONNULL_BEGIN

@interface GuideDataModel : NSObject

@property (nonatomic,strong) UIImage *iconImage;

@property (nonatomic,strong) NSString *titleString;

@property (nonatomic,assign) GuideType guideType;

@end

NS_ASSUME_NONNULL_END

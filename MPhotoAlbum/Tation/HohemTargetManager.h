//
//  HohemTargetManager.h
//  Hohem Show
//
//  Created by jolly on 2019/8/8.
//  Copyright © 2019 jolly. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//不同target版本
typedef NS_ENUM(NSInteger,HohemTargetManager_CompanyEnum) {
    
    HohemTargetManager_CompanyEnum_Hohem = 3,//Hohem
    HohemTargetManager_CompanyEnum_Factory = 4,//工厂
    HohemTargetManager_CompanyEnum_HohemBeat = 5,
    HohemTargetManager_CompanyEnum_Brica = 6,
    HohemTargetManager_CompanyEnum_HohemJoy = 7,
    HohemTargetManager_CompanyEnum_HohemJoyBeta = 8,
    HohemTargetManager_CompanyEnum_BricaBSteadyQ = 9
};

#define Hohem_kSharedTargetManager [HohemTargetManager sharedTargetManager]
#define Hohem_kNormalColor Hohem_kSharedTargetManager.themeColor

@interface HohemTargetManager : NSObject

@property (nonatomic, assign) HohemTargetManager_CompanyEnum companyType;//公司所属枚举类型(默认为Hohem)
@property (nonatomic, strong) UIColor *themeColor;//UI主题颜色
@property (nonatomic, copy) NSArray *products;//产品型号数组;
@property (nonatomic, copy) NSArray *productImages;//产品图片数组;
@property (nonatomic, copy) NSArray *productTypes;//产品型号名称数组;
@property (nonatomic, copy) NSString *blePreStr;//蓝牙前缀
@property (nonatomic, copy) NSString *appID;

+ (instancetype)sharedTargetManager;
//操作指引视频名
- (NSString *)guideVideoName;

@end

NS_ASSUME_NONNULL_END

//
//  HohemTargetManager.m
//  Hohem Show
//
//  Created by jolly on 2019/8/8.
//  Copyright © 2019 jolly. All rights reserved.
//

#import "HohemTargetManager.h"

@implementation HohemTargetManager

static HohemTargetManager *manager = nil;

+ (instancetype)sharedTargetManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[HohemTargetManager alloc]init];
        [manager initAttribute];
    });
    return manager;
}

//初始化属性
- (void)initAttribute {
    
//    switch (TargetType) {
//        case 3:
//            _companyType = HohemTargetManager_CompanyEnum_Hohem;
//            self.products = @[@(HHProductType_X),@(HHProductType_X2),@(HHProductType_V2)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"iSX-";
//            self.appID = @"1501369521";
//            break;
//        case 4:
//            _companyType = HohemTargetManager_CompanyEnum_Factory;
//            self.products = @[@(HHProductType_X),@(HHProductType_X2),@(HHProductType_V2)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"iSX-";
//            self.appID = @"1501369521";
//            break;
//        case 5:
//            _companyType = HohemTargetManager_CompanyEnum_HohemBeat;
//            self.products = @[@(HHProductType_X),@(HHProductType_X2),@(HHProductType_V2),@(HHProductType_Q),@(HHProductType_M5)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"iSX-";
//            self.appID = @"1501369521";
//            break;
//        case 6:
//            _companyType = HohemTargetManager_CompanyEnum_Brica;
//            self.products = @[@(HHProductType_X)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"BSTEADYXS_";
//            self.appID = @"1501369521";
//            break;
//        case 7:
//            _companyType = HohemTargetManager_CompanyEnum_HohemJoy;
//            self.products = @[@(HHProductType_Q),@(HHProductType_M5)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"iSX-";
//            self.appID = @"1574156865";
//            break;
//        case 8:
//            _companyType = HohemTargetManager_CompanyEnum_HohemJoyBeta;
//            self.products = @[@(HHProductType_X),@(HHProductType_X2),@(HHProductType_V2),@(HHProductType_Q),@(HHProductType_M5)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"iSX-";
//            self.appID = @"1574156865";
//            break;
//        case 9:
//            _companyType = HohemTargetManager_CompanyEnum_BricaBSteadyQ;
//            self.products = @[@(HHProductType_Q)];
//            self.themeColor = [UIColor colorWithHexString:@"#FF6501" alpha:1.0];
//            self.blePreStr = @"B-Steady Q";
//            self.appID = @"1574156865";
//            break;
//        default:
//            break;
//    }
}

//操作指引视频名
- (NSString *)guideVideoName {
    
    NSString *videoName;
    if (Hohem_kSharedTargetManager.companyType == HohemTargetManager_CompanyEnum_Hohem) {
        
        if (Tation_kSharedDeviceManager.languageEnum == TationLanguageEnum_CN || Tation_kSharedDeviceManager.languageEnum == TationLanguageEnum_CN_Hant) {
            
            videoName = @"Hohem.FirstInstall_CH.mp4";
        }else{
            
            videoName = @"Hohem.FirstInstall_EN.mp4";
        }
    }else if (Hohem_kSharedTargetManager.companyType == HohemTargetManager_CompanyEnum_HohemJoy || Hohem_kSharedTargetManager.companyType == HohemTargetManager_CompanyEnum_HohemJoyBeta) {
        
        if (Tation_kSharedDeviceManager.languageEnum == TationLanguageEnum_CN || Tation_kSharedDeviceManager.languageEnum == TationLanguageEnum_CN_Hant) {
            
            videoName = @"HohemJoyFirst_CH.mp4";
        }else{
            
            videoName = @"HohemJoyFirst_EN.mp4";
        }
    }
    return videoName;
}

@end

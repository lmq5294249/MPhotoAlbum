//
//  TationDeviceManager.h
//  Hohem GimSet
//
//  Created by Tation on 2018/5/29.
//  Copyright © 2018年 Hohem. All rights reserved.
//  当前手机设备管理类

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

#define Tation_kSharedDeviceManager [TationDeviceManager sharedTationDeviceManager]
#define Tation_isIPhoneX [TationDeviceManager isIphoneX]
#define Tation_safeArea [TationDeviceManager boundsOfSafeArea]
#define Tation_StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define Tation_BottomSafetyDistance Tation_isIPhoneX ? 34 : 0
#define Tation_AutoFit(length) [TationDeviceManager autoFitLength:length]
#define Tation_kNotificationInterfaceOrientation @"Tation_kNotificationInterfaceOrientation"
#define Tation_kNotificationInterfaceOrientation_Value @"Tation_kNotificationInterfaceOrientation_Value"


typedef NS_ENUM(NSInteger,TationLanguageEnum) {
    
    TationLanguageEnum_CN,//中文简体
    TationLanguageEnum_CN_Hant,//中文繁体
    TationLanguageEnum_EN,//英语
    TationLanguageEnum_EN_CN,//英式英语
    TationLanguageEnum_EN_US,//美式英语
    TationLanguageEnum_EN_CA,//加拿大英语
    TationLanguageEnum_DE,//德语
    TationLanguageEnum_PT,//葡萄牙语
    TationLanguageEnum_PT_BR,//巴西葡萄牙语
    TationLanguageEnum_JA,//日语
    TationLanguageEnum_ES,//西班牙语
    TationLanguageEnum_FR,//法语
    TationLanguageEnum_IT,//意大利语
    TationLanguageEnum_KO,//韩语
    TationLanguageEnum_RU,//俄语
};

@interface TationDeviceManager : NSObject

@property (nonatomic, assign) TationLanguageEnum languageEnum;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) CGFloat curVolume;

//创建单例对象
+ (instancetype)sharedTationDeviceManager;
//判断是否为iphone x系列机型
+ (BOOL)isIphoneX;
//获取布局时安全区域的frame
+ (CGRect)boundsOfSafeArea;
//监听设备方向
- (void)beginMonitorDeviceInterfaceOrientation;

//手机唯一标识
- (NSString *)phoneIdentifier;
//手机用户名
- (NSString *)phoneUserName;
//手机型号
- (NSString *)deviceVersion;
- (NSString *)deviceMachine;
//手机系统版本
- (NSString *)deviceiOSVersion;
//获取语言字符串
- (NSString *)getLanguageStr;
//获取手机电量
- (CGFloat)getPhonePower;
+ (CGFloat)autoFitLength:(CGFloat)length;
//获取App可用存储空间
- (float)inquireAvailableSize;

- (BOOL)isVerticalScreen;

@end

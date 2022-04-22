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

typedef enum{
    
    TationDeviceManager_LanguageEnum_Chinese = 1,//中文简体
    TationDeviceManager_LanguageEnum_Chinese_Hant,//中文繁体
    TationDeviceManager_LanguageEnum_English,//英语
    TationDeviceManager_LanguageEnum_Deutsch,//德语
    TationDeviceManager_LanguageEnum_Portugal,//葡萄牙语
    TationDeviceManager_LanguageEnum_Japanese,//日语
    TationDeviceManager_LanguageEnum_Spanish,//西班牙语
    TationDeviceManager_LanguageEnum_French,//法语
    TationDeviceManager_LanguageEnum_Italy,//意大利语
    TationDeviceManager_LanguageEnum_Korean,//韩语
    TationDeviceManager_LanguageEnum_Russian//俄语
} TationDeviceManager_LanguageEnum;

@interface TationDeviceManager : NSObject

@property (nonatomic, assign) TationDeviceManager_LanguageEnum Tation_LanguageEnum;//当前设备语言类型
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
//手机系统版本
- (NSString *)deviceiOSVersion;
//获取语言字符串
- (NSString *)getLanguageStr;
//获取手机电量
- (CGFloat)getPhonePower;
+ (CGFloat)autoFitLength:(CGFloat)length;
//获取App可用存储空间
- (float)inquireAvailableSize;

@end

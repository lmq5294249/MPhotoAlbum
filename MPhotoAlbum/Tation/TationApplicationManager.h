//
//  TationApplicationManager.h
//  Hohem GimSet
//
//  Created by Tation on 2018/8/16.
//  Copyright © 2018年 Hohem. All rights reserved.
//  当前APP资源管理类

#define Tation_AppVersionKey @"Tation_AppVersionKey" //本地存储的App版本

#import <Foundation/Foundation.h>

#define Tation_kSharedApplicationManager [TationApplicationManager sharedTationApplicationManager]

@interface TationApplicationManager : NSObject

@property (nonatomic, copy) NSString *Tation_ApplicationName;//应用名称
@property (nonatomic, copy) NSString *Tation_ApplicationVersion;//当前应用版本号
@property (nonatomic, copy) NSString *Tation_ApplicationVersionForAPPStore;//APP Store中的应用版本号
@property (nonatomic, copy) NSString *Tation_ApplicationID;//在APPstore中的应用ID
@property (nonatomic, assign) BOOL Tation_IsShowUpdate;//是否有新版本APP可升级
@property (nonatomic, assign) BOOL Tation_IsShowGuide;//是否显示引导页

//创建单例对象
+ (instancetype)sharedTationApplicationManager;
//已完整展示引导页,存储版本信息
- (void)Tation_isFinishShowGuide;
//获取当前13位时间
+ (NSString *)getCurTime;
/**
 跳转到app store指定应用
 */
- (void)goToAppStoreWithAppID:(NSString *)appId;

@end

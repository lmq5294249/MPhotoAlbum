//
//  TationApplicationManager.m
//  Hohem GimSet
//
//  Created by Tation on 2018/8/16.
//  Copyright © 2018年 Hohem. All rights reserved.
//

#import "TationApplicationManager.h"

@implementation TationApplicationManager

//创建单例对象
+ (instancetype)sharedTationApplicationManager {
    
    static TationApplicationManager *instanceType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instanceType = [[TationApplicationManager alloc]init];
        [instanceType initAttribute];
    });
    
    return instanceType;
}

//初始化各项属性
- (void)initAttribute {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    _Tation_ApplicationName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    _Tation_ApplicationVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    _Tation_IsShowGuide = [self isShowGuide];
}

/*
 1.是否为第一次安装
 2.是否为更新后第一次打开
 3.是否需要提示更新
 */
//判断是否安装或更新后第一次启动程序
- (BOOL)isShowGuide {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:Tation_AppVersionKey] && [[[NSUserDefaults standardUserDefaults] objectForKey:Tation_AppVersionKey] isEqual:_Tation_ApplicationVersion]) {//有存储版本且当前版本等于存储版本,则不显示导航页
        
        return NO;
    }else{
        
        return  YES;
    }
}

//已完整展示引导页,存储版本信息
- (void)Tation_isFinishShowGuide {
    
    [[NSUserDefaults standardUserDefaults] setValue:_Tation_ApplicationVersion forKey:Tation_AppVersionKey];
}

//通过赋值APPID获取APPSTORE的版本
- (void)setTation_ApplicationID:(NSString *)Tation_ApplicationID {
    
    _Tation_ApplicationID = Tation_ApplicationID;
    [self getApplicationVersionForAppStoreWithAPPID:Tation_ApplicationID];
}

//获取在APP Store中的应用版本号
- (void)getApplicationVersionForAppStoreWithAPPID:(NSString *)APPID {
    
//    NSString *urlStr = [NSString stringWithFormat:@"https://itunes.apple.com//lookup?id=%@",APPID];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSURLRequest *req = [NSURLRequest requestWithURL:url];
//    [NSURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSError *error;
    //解析最新版本号
    NSDictionary *appInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSArray *infoContent = [appInfo objectForKey:@"results"];
    NSString *version = [[infoContent objectAtIndex:0] objectForKey:@"version"];
    self.Tation_ApplicationVersionForAPPStore = version;
    
    _Tation_IsShowUpdate = ([_Tation_ApplicationVersionForAPPStore compare:_Tation_ApplicationVersion options:NSNumericSearch] == NSOrderedDescending) ? YES : NO;
}

/**
 跳转到app store指定应用
 */
- (void)goToAppStoreWithAppID:(NSString *)appId {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/%@",appId]] options:@{} completionHandler:nil];
}

//获取当前13位时间
+ (NSString *)getCurTime {
    
    return [NSString stringWithFormat:@"%ld",(long)([[NSDate date] timeIntervalSince1970]*1000)];
}

@end

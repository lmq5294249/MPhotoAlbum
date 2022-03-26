// 
//  TationAuthorityManager.m
//  Hohem Pro
//
//  Created by jolly on 2020/4/10.
//  Copyright © 2020 jolly. All rights reserved.
//

#import "TationAuthorityManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation TationAuthorityManager

//检测摄像头权限
+ (void)checkCameraService:(void(^)(BOOL isOpen))block {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        block(granted);
    }];
}

//检测麦克风权限
+ (void)checkMikeService:(void(^)(BOOL isOpen))block {
    
     [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
         
         block(granted);
    }];
}

//检测相册权限
+ (void)checkAlbumService:(void(^)(BOOL isOpen))block {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        block(status == PHAuthorizationStatusAuthorized);
    }];
}

//定位权限检测
+ (void)checkLocalitionService:(void(^)(BOOL isOpen))block {
    
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        
        block(YES);
    }else{
        
        block(NO);
    }
}

//权限申请提示
+ (void)showAlertRequestAuthority:(nullable NSString *)title message:(NSString *)message agreeStr:(nullable NSString *)agreeStr agree:(nullable void(^)(void))agree cancelStr:(nullable NSString *)cancelStr cancel:(nullable void(^)(void))cancel {
    
    title = title ? title : @"Hohem.Authority.Title";
    agreeStr = agreeStr ? agreeStr : @"Hohem.Authority.Agree";
    cancelStr = cancelStr ? cancelStr : @"Hohem.Authority.Cancel";
    [Tation_kSharedToolsManager showAlertVc:title message:message confirm:agreeStr cancel:cancelStr showCancel:YES confirmBlock:^{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        if (agree) agree();
    } cancelBlock:^{
        
        if (cancel) cancel();
    }];
}

@end

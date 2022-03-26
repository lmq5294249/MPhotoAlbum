//
//  TationToolsManager.m
//  Hohem Pro
//
//  Created by jolly on 2019/11/4.
//  Copyright © 2019 jolly. All rights reserved.
//

#import "TationToolsManager.h"
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "NSString+HHFormat.h"
#import <Photos/Photos.h>

@interface TationToolsManager()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation TationToolsManager

+ (instancetype )sharedToolsManager {
    
    static TationToolsManager *instanceType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instanceType = [[TationToolsManager alloc]init];
        [instanceType initAttribute];
    });
    
    return instanceType;
}

- (void)initAttribute {
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // 设置过滤器为无
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.geocoder = [[CLGeocoder alloc]init];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    
    CLLocation * location = locations.lastObject;
    // 纬度
    self.latitude = location.coordinate.latitude;
    // 经度
    self.longitude = location.coordinate.longitude;
    
//    NSLog(@"经度：%f,纬度：%f,海拔：%f,航向：%f,行走速度：%f", location.coordinate.longitude, location.coordinate.latitude,location.altitude,location.course,location.speed);
//    NSLog(@"经度 : %f ,维度 : %f",location.coordinate.longitude,location.coordinate.latitude);
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if (placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
//            NSLog(@"%@",placemark.name);
            //获取城市
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            // 位置名
//    　　NSLog(@"name,%@",placemark.name);
//    　　// 街道
//    　　NSLog(@"thoroughfare,%@",placemark.thoroughfare);
//    　　// 子街道
//    　　NSLog(@"subThoroughfare,%@",placemark.subThoroughfare);
//    　　// 市
//    　　NSLog(@"locality,%@",placemark.locality);
//    　　// 区
//    　　NSLog(@"subLocality,%@",placemark.subLocality);
//    　　// 国家
//    　　NSLog(@"country,%@",placemark.country);
            
            self.address = [NSString stringWithFormat:@"%@%@%@",placemark.country,placemark.locality,placemark.subLocality];
//            NSLog(@"%@",self.address);
        }else if (error == nil && [placemarks count] == 0) {
            NSLog(@"No results were returned.");
        } else if (error != nil){
//            NSLog(@"An error occurred = %@", error);
        }
    }];
//    [manager stopUpdatingLocation];不用的时候关闭更新位置服务
    
}

//显示提示信息
- (void)showAlertVc:(nullable NSString *)title message:(NSString *)message confirm:(nullable NSString *)confirm cancel:(nullable NSString *)cancel showCancel:(BOOL)showCancel confirmBlock:(nullable void(^)(void))confirmBlock cancelBlock:(nullable void(^)(void))cancelBlock {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        TationReminderView *reminderView = [[TationReminderView alloc] initWithTitle:title message:message confirm:confirm cancel:cancel showCancel:showCancel confirmBlock:confirmBlock cancelBlock:cancelBlock];
        
        [[UIApplication sharedApplication].keyWindow addSubview:reminderView];
        reminderView.frame = [UIScreen mainScreen].bounds;
    });
    
}

#pragma mark - int类型转十六进制形式
//int数据类型转换为四位数的十六进制形式的字符串
- (NSString *)getFourLengthStrWithNum:(NSInteger)num{
    
    NSString *numStr = [self ToHex:num];
    NSString *resultStr;
    
    switch (numStr.length) {
        case 0:
            resultStr = @"0000";
            break;
        case 1:
            resultStr = [NSString stringWithFormat:@"000%@",numStr];
            break;
        case 2:
            resultStr = [NSString stringWithFormat:@"00%@",numStr];
            break;
        case 3:
            resultStr = [NSString stringWithFormat:@"0%@",numStr];
            break;
        case 4:
            resultStr = numStr;
            break;
        default:
            break;
    }
    return resultStr;
}

//int转16进制字符串
- (NSString *)ToHex:(uint16_t)tmpid
{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
        
    }
    return str;
}

//nsdata数据转换成十六进制数据
- (NSString *)convertDataToHexStr:(NSData *)data
{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

//字符串转l十六进制
- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}

//转换录制时间格式
- (NSString *)timeFormatWithSecond:(NSInteger)time {
    
    NSInteger second = time % 60;
    NSInteger minute = time % 3600 / 60;
    NSInteger hour = time / 3600;
    
    return [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)hour,(long)minute,(long)second];
}

- (UIViewController *)getCurViewController {
    
    [NSThread mainThread];
    UIViewController *currentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else {
            if ([currentViewController isKindOfClass:[UINavigationController class]]) {
                currentViewController = ((UINavigationController *)currentViewController).visibleViewController;
            } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
                currentViewController = ((UITabBarController* )currentViewController).selectedViewController;
            } else {
                break;
            }
        }
    }
    
    return currentViewController;
}

//校验字符串是否全是数字
- (BOOL)checkIsNumStr:(NSString *)numStr {
    
    if (numStr.length == 0) return NO;
    
    numStr = [numStr stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(numStr.length > 0) return NO;
    
    return YES;
}

//获取纯色图片
- (UIImage *)imageWithColor:(UIColor *)color {
   
    CGRect rect = CGRectMake(0.0f,0.0f, 1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (NSInteger)compareCurVersion:(NSString *)curVersion targetVersion:(NSString *)targetVersion {
    
    NSArray *curArr = [curVersion componentsSeparatedByString:@"."];
    NSMutableArray <NSString *>*curMtArr = [NSMutableArray array];
    for (NSString *tmp in curArr) {
        
        [curMtArr addObject:[NSString getFixedLengthStr:tmp fillStr:@"0" length:3]];
    }
    NSMutableString *curMtStr = [NSMutableString string];
    for (NSString *tmp in curMtArr) {
        
        [curMtStr appendString:tmp];
    }
    
    NSArray *targetArr = [targetVersion componentsSeparatedByString:@"."];
    NSMutableArray <NSString *>*targetMtArr = [NSMutableArray array];
    for (NSString *tmp in targetArr) {
        
        [targetMtArr addObject:[NSString getFixedLengthStr:tmp fillStr:@"0" length:3]];
    }
    NSMutableString *targetMtStr = [NSMutableString string];
    for (NSString *tmp in targetMtArr) {
        
        [targetMtStr appendString:tmp];
    }
    
    return [curMtStr compare:targetMtStr];
}

#pragma mark - 分享
//分享图片
- (void)shareImageWithImage:(UIImage *)image completeHandler:(nullable void(^)(BOOL result))completeHandler {
    
    if (!image) return;
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
    [[self getCurViewController] presentViewController:activityVC animated:YES completion:nil];
    
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        
        if (completeHandler) completeHandler(completed);
    };
}

//分享视频
- (void)shareVideoWithUrl:(NSURL *)url completeHandler:(nullable void(^)(BOOL result))completeHandler {
    
    if (!url) return;
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    [[self getCurViewController] presentViewController:activityVC animated:YES completion:nil];
    
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError){
        
        if (completeHandler) completeHandler(completed);
    };
}

//分享视频
- (void)shareVideoWithAsset:(PHAsset *)asset completeHandler:(nullable void(^)(BOOL result))completeHandler {
    
    if (!asset) return;
    
    //解析数据
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    for (PHAssetResource *assetRes in assetResources) {
        
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            
            resource = assetRes;
        }
    }
    
    //获取存储地址
    NSString *fileName = @"tempAssetVideo.mp4";
    if (resource.originalFilename) {
        
        fileName = resource.originalFilename;
    }
    NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    if ([XCFileManager isExistsAtPath:PATH_MOVIE_FILE]) {
        
        [XCFileManager removeItemAtPath:PATH_MOVIE_FILE];
    }
    
    //存储到沙盒
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE] options:nil completionHandler:^(NSError * _Nullable error){
        
        if (error) {
            
            NSLog(@"%@",error);
        } else {
            
            NSArray *activityItems = @[[NSURL fileURLWithPath:PATH_MOVIE_FILE]];
            //分享同步到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
                //不出现在活动项目
                activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
                [[self getCurViewController] presentViewController:activityVC animated:YES completion:nil];
                
                // 分享之后的回调
                activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                    
                    if (completed) {
                        
                        NSLog(@"completed");
                    } else  {
                        
                        NSLog(@"cancled");
                    }
                    
                    //分享之后删除原地址信息
//                    [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE  error:nil];
                };
            });
        }
    }];
}

@end

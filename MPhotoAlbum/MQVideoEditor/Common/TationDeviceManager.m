//
//  TationDeviceManager.m
//  Hohem GimSet
//
//  Created by Tation on 2018/5/29.
//  Copyright © 2018年 Hohem. All rights reserved.
//

#import "TationDeviceManager.h"
#import "sys/utsname.h"

@interface TationDeviceManager ()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation TationDeviceManager

//创建单例对象
+ (instancetype)sharedTationDeviceManager {
    
    static TationDeviceManager *instanceType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instanceType = [[TationDeviceManager alloc]init];
        [instanceType initAttribute];
    });
    
    return instanceType;
}

/**
 ja = 日语
 zh = 中文
 de = 德语
 pt = 葡萄牙
 es = 西班牙语
 fr = 法语
 it = 意大利
 ko = 韩文
 ru = 俄语
 en = 英语
 */
//初始化各类属性
- (void)initAttribute {

    self.Tation_LanguageEnum = [self getDeviceLanguageEnum];
    self.interfaceOrientation = UIInterfaceOrientationPortrait;
    [self beginMonitorDeviceInterfaceOrientation];
    [self customVolume];
}

//获取设备语言
- (TationDeviceManager_LanguageEnum)getDeviceLanguageEnum {
    
    NSString *languageStr = [self preferredLanguage];
    NSLog(@"preferred Language = %@",languageStr);
    NSString *languagePre = [languageStr substringToIndex:2];
    
    //默认英语
    TationDeviceManager_LanguageEnum languageEnum = TationDeviceManager_LanguageEnum_English;
    if ([languagePre isEqualToString:@"zh"]) {
        
        if ([languageStr hasPrefix:@"zh-Hans"]) {//中文简体
            
            languageEnum = TationDeviceManager_LanguageEnum_Chinese;
        }else{//中文繁体
            
            languageEnum = TationDeviceManager_LanguageEnum_Chinese_Hant;
        }
    }else if([languagePre isEqualToString:@"de"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Deutsch;
    }else if([languagePre isEqualToString:@"pt"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Portugal;
    }else if([languagePre isEqualToString:@"ja"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Japanese;
    }else if([languagePre isEqualToString:@"es"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Spanish;
    }else if([languagePre isEqualToString:@"fr"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_French;
    }else if([languagePre isEqualToString:@"it"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Italy;
    }else if([languagePre isEqualToString:@"ko"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Korean;
    }else if([languagePre isEqualToString:@"ru"]){
        
        languageEnum = TationDeviceManager_LanguageEnum_Russian;
    }

    return languageEnum;
}

//监听设备方向
- (void)beginMonitorDeviceInterfaceOrientation {
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 if (!error) {
                                                     [self updateAccelertionData:accelerometerData.acceleration];
                                                 }
                                                 else{
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
}

//监听音量变化
- (void)customVolume {
    
//    NSError *error;
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryAmbient error:&error];
//    [session setActive:YES error:&error];
    //iOS9以上加上这句
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    /**
     NSError *error;
         AVAudioSession *session = [AVAudioSession sharedInstance];
         if (@available(iOS 10.0, *)) {
     
             [session setCategory: AVAudioSessionCategoryPlayAndRecord
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetoothA2DP
                            error:&error];
         } else {
     
             [session setCategory: AVAudioSessionCategoryPlayAndRecord
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&error];
         }
         [session setPreferredSampleRate:48000 error:&error];
         [session setActive:YES error:&error];
     
         [session setCategory: AVAudioSessionCategoryPlayAndRecord
         withOptions:AVAudioSessionCategoryOptionMixWithOthers
               error:&error];
         [session setActive:YES error:&error];
     */
            
    //监听系统音量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChangeNotification:)name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

//系统音量回调
- (void)volumeChangeNotification:(NSNotification *)noti {
    
    float volume = [[[noti userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.curVolume = volume;
    NSLog(@"%f",volume);
}

- (void)updateAccelertionData:(CMAcceleration)acceleration{
    UIInterfaceOrientation orientationNew;
    
    if (acceleration.x >= 0.75) {
        orientationNew = UIInterfaceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        orientationNew = UIInterfaceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        orientationNew = UIInterfaceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        orientationNew = UIInterfaceOrientationPortraitUpsideDown;
    }
    else {
        // Consider same as last time
        return;
    }
    
    if (orientationNew == self.interfaceOrientation)
        return;
    self.interfaceOrientation = orientationNew;
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Tation_kNotificationInterfaceOrientation object:nil userInfo:@{
                                                                                                                     Tation_kNotificationInterfaceOrientation_Value:[NSNumber numberWithInteger:orientationNew]                                                                                                }];
}

//判断是否为iphoneX系列机型
+ (BOOL)isIphoneX {
    
    if (@available(iOS 11.0,*))
    {
        return [UIApplication sharedApplication].delegate.window.safeAreaInsets.top > 20 ? YES : NO;
    }
    else
    {
        return NO;
    }
}

//获取手机电量
- (CGFloat)getPhonePower {
    
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    double deviceLevel = [UIDevice currentDevice].batteryLevel;
    
    return deviceLevel;
}

//获取布局时安全区域的frame
+ (CGRect)boundsOfSafeArea {
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0,*)) {
        
        safeAreaInsets = [UIApplication sharedApplication].delegate.window.safeAreaInsets;
    }
    CGRect boundsOfSafeArea = UIEdgeInsetsInsetRect(bounds, safeAreaInsets);
    return boundsOfSafeArea;
}

//获取语言字符串
- (NSString *)getLanguageStr {
    
    NSString *languageStr = @"EN_US";
    switch (Tation_kSharedDeviceManager.Tation_LanguageEnum) {
        case TationDeviceManager_LanguageEnum_Chinese:
            languageStr = @"ZH_CN";
            break;
        case TationDeviceManager_LanguageEnum_Chinese_Hant:
            languageStr = @"ZH_HANT";
            break;
        case TationDeviceManager_LanguageEnum_English:
            languageStr = @"EN_US";
            break;
        case TationDeviceManager_LanguageEnum_Deutsch:
            languageStr = @"DE";
            break;
        case TationDeviceManager_LanguageEnum_Portugal:
            languageStr = @"PT";
            break;
        case TationDeviceManager_LanguageEnum_Japanese:
            languageStr = @"JA";
            break;
        case TationDeviceManager_LanguageEnum_Spanish:
            languageStr = @"ES";
            break;
        case TationDeviceManager_LanguageEnum_French:
            languageStr = @"FR";
            break;
        case TationDeviceManager_LanguageEnum_Italy:
            languageStr = @"IT";
            break;
        case TationDeviceManager_LanguageEnum_Korean:
            languageStr = @"KO";
            break;
        case TationDeviceManager_LanguageEnum_Russian:
            languageStr = @"RU";
            break;
            
        default:
            break;
    }
    
    return languageStr;
}

//手机当前语言
- (NSString *)preferredLanguage {
    
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
}

//手机唯一标识
- (NSString *)phoneIdentifier {
    
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

//手机用户名
- (NSString *)phoneUserName {
    
    return [[UIDevice currentDevice] name];
}

//手机系统版本
- (NSString *)deviceiOSVersion {
    
    return [NSString stringWithFormat:@"%@ - %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
}

//手机型号
- (NSString *)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4 Verizon";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8 Global";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus Global";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X Global";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8 GSM";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus GSM";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X GSM";
    
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max (China)";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator 32";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator 64";
    
    if ([deviceString isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"] ||
        [deviceString isEqualToString:@"iPad2,2"] ||
        [deviceString isEqualToString:@"iPad2,3"] ||
        [deviceString isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad3,1"] ||
        [deviceString isEqualToString:@"iPad3,2"] ||
        [deviceString isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"] ||
        [deviceString isEqualToString:@"iPad3,5"] ||
        [deviceString isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad4,1"] ||
        [deviceString isEqualToString:@"iPad4,2"] ||
        [deviceString isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"] ||
        [deviceString isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"] ||
        [deviceString isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([deviceString isEqualToString:@"iPad6,7"] ||
        [deviceString isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([deviceString isEqualToString:@"iPad6,11"] ||
        [deviceString isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([deviceString isEqualToString:@"iPad7,1"] ||
        [deviceString isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([deviceString isEqualToString:@"iPad7,3"] ||
        [deviceString isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    
    if ([deviceString isEqualToString:@"iPad2,5"] ||
        [deviceString isEqualToString:@"iPad2,6"] ||
        [deviceString isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([deviceString isEqualToString:@"iPad4,4"] ||
        [deviceString isEqualToString:@"iPad4,5"] ||
        [deviceString isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"] ||
        [deviceString isEqualToString:@"iPad4,8"] ||
        [deviceString isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"] ||
        [deviceString isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    
    if ([deviceString isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([deviceString isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([deviceString isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([deviceString isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([deviceString isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([deviceString isEqualToString:@"iPod7,1"]) return @"iTouch6";
    
    return deviceString;
}

+ (CGFloat)autoFitLength:(CGFloat)length {
    
   
    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return length * (min / 375.0);
}

//获取App可用存储空间
- (float)inquireAvailableSize {
    
    float totalSize = 0.0;
    float freeSize = 0.0;
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error:&error];
    if (dict) {
        
        NSNumber *total = [dict objectForKey:NSFileSystemSize];
        totalSize = [total unsignedLongLongValue] * 1.0 / 1024 / 1024 / 1024;
        
        NSNumber *free = [dict objectForKey:NSFileSystemFreeSize];
        freeSize = [free unsignedLongLongValue] * 1.0 / 1024 / 1024 / 1024;
    }else{
        
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return freeSize;
}

@end

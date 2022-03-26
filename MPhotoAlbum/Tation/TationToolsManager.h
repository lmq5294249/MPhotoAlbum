//
//  TationToolsManager.h
//  Hohem Pro
//
//  Created by jolly on 2019/11/4.
//  Copyright © 2019 jolly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

#define Tation_kSharedToolsManager [TationToolsManager sharedToolsManager]

@interface TationToolsManager : NSObject

@property (nonatomic, copy) NSString *address;//地址
@property (nonatomic, assign) double latitude;//维度
@property (nonatomic, assign) double longitude;//经度

+ (instancetype)sharedToolsManager;

//将int数据转换成长度为4的字符串,不够前面补0
- (NSString *)getFourLengthStrWithNum:(NSInteger)num;
//nsdata数据转换成十六进制数据
- (NSString *)convertDataToHexStr:(NSData *)data;
//字符串转l十六进制
- (NSInteger)numberWithHexString:(NSString *)hexString;
//显示提示信息
- (void)showAlertVc:(nullable NSString *)title message:(NSString *)message confirm:(nullable NSString *)confirm cancel:(nullable NSString *)cancel showCancel:(BOOL)showCancel confirmBlock:(nullable void(^)(void))confirmBlock cancelBlock:(nullable void(^)(void))cancelBlock;
- (UIViewController *)getCurViewController ;
//转换录制时间格式
- (NSString *)timeFormatWithSecond:(NSInteger)time;
//校验字符串是否全是数字
- (BOOL)checkIsNumStr:(NSString *)numStr;
//获取纯色图片
- (UIImage *)imageWithColor:(UIColor *)color;

//比对版本号
/**
 比对版本号
 -1代表 curVersion < targetVersion
 0代表 curVersion = targetVersion
 1代表 curVersion > targetVersion
 */
- (NSInteger)compareCurVersion:(NSString *)curVersion targetVersion:(NSString *)targetVersion;

#pragma mark - 分享
//分享图片
- (void)shareImageWithImage:(UIImage *)image completeHandler:(nullable void(^)(BOOL result))completeHandler;
//分享视频
- (void)shareVideoWithUrl:(NSURL *)url completeHandler:(nullable void(^)(BOOL result))completeHandler;
//分享视频
- (void)shareVideoWithAsset:(PHAsset *)asset completeHandler:(nullable void(^)(BOOL result))completeHandler;

@end

NS_ASSUME_NONNULL_END

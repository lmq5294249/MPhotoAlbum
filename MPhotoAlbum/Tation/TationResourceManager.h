//
//  TationResourceManager.h
//  Hohem GimSet
//
//  Created by Tation on 2018/5/28.
//  Copyright © 2018年 Hohem. All rights reserved.
//  资源管理类

#import <UIKit/UIKit.h>

#define Tation_Resource_Str(A) [Tation_kSharedResourceManager TationResourceManagerWithString:A]
#define Tation_Resource_Image(A) [Tation_kSharedResourceManager TationResourceManagerWithImageStr:A]
#define Tation_Resource_Path(A) [Tation_kSharedResourceManager TationResourceManagerWithFilePathStr:A]

typedef enum{
    
    TationResourceManager_ResourceEnum_Location = 1,//本地资源
    TationResourceManager_ResourceEnum_Bundle//SDK的bundle资源
    
} TationResourceManager_ResourceEnum;

#define Tation_kSharedResourceManager [TationResourceManager sharedTationResourceManager]

@interface TationResourceManager : NSObject

//标示加载不同的资源
@property (nonatomic, assign) TationResourceManager_ResourceEnum Tation_ResourceEnum;

//初始化创建单例
+ (instancetype)sharedTationResourceManager;
//语言文字适配
- (NSString *)TationResourceManagerWithString:(NSString *)str;
//图片适配
- (UIImage *)TationResourceManagerWithImageStr:(NSString *)str;
//文件路径适配
- (NSString *)TationResourceManagerWithFilePathStr:(NSString *)str;

//保存图片到沙盒
- (NSString *)saveImage:(UIImage *)image imageName:(NSString *)name;
- (UIImage *)getImageWithFilePath:(NSString *)filePath;

@end

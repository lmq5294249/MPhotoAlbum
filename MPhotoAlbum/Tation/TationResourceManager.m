//
//  TationResourceManager.m
//  Hohem GimSet
//
//  Created by Tation on 2018/5/28.
//  Copyright © 2018年 Hohem. All rights reserved.
//

#import "TationResourceManager.h"

@interface TationResourceManager()

@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation TationResourceManager

//初始化创建单例
+ (instancetype)sharedTationResourceManager {
    
    static TationResourceManager *instanceType;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instanceType = [[TationResourceManager alloc]init];
        [instanceType initAttribute];
    });
    
    return instanceType;
}

//初始化各类参数
- (void)initAttribute {
    
    //初始化bundle
    NSString *bundleName = @"HohemFrameworksBundle.bundle";
    _bundle = [[NSBundle alloc]initWithPath:[[NSBundle mainBundle] pathForResource:bundleName ofType:nil]];
}

//语言文字适配
- (NSString *)TationResourceManagerWithString:(NSString *)str {
    
    NSString *resultStr;
    if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Location) {
        
        resultStr = NSLocalizedString(str, nil);
    }else if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Bundle) {
        
         resultStr = NSLocalizedStringFromTableInBundle(str, nil, _bundle, nil);
    }else{
        
        resultStr = NSLocalizedString(str, nil);
    }
    
    return resultStr;
}

//图片适配
- (UIImage *)TationResourceManagerWithImageStr:(NSString *)str {
    
    UIImage *resultImage = [[UIImage alloc]init];
    if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Location) {
        
        resultImage = [UIImage imageNamed:str];
    }else if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Bundle) {
        
        resultImage = [UIImage imageNamed:str inBundle:_bundle compatibleWithTraitCollection:nil];
    }else{
        
        resultImage = [UIImage imageNamed:str];
    }
    
    return resultImage;
}

//文件路径适配
- (NSString *)TationResourceManagerWithFilePathStr:(NSString *)str {
    
    NSString *resultStr;
    if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Location) {
        
        resultStr = [[NSBundle mainBundle] pathForResource:str ofType:nil];
    }else if (_Tation_ResourceEnum == TationResourceManager_ResourceEnum_Bundle) {
        
        resultStr = [_bundle pathForResource:str ofType:nil];
    }else{
        
        resultStr = [[NSBundle mainBundle] pathForResource:str ofType:nil];
    }
    
    return resultStr;
}

//保存图片到沙盒
- (NSString *)saveImage:(UIImage *)image imageName:(NSString *)name {
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *fileName = [self getSaveFile:name];
    
    if ([data writeToFile:fileName atomically:YES]) {
        
        return fileName;
    }
    
    return nil;
}

- (UIImage *)getImageWithFilePath:(NSString *)filePath {
    
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    
    return [[UIImage alloc]initWithData:data];
}

- (NSString *)getSaveFile:(NSString *)fileName {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
}

@end

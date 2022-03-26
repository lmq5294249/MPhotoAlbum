//
//  HohemCrashManager.h
//  Hohem Pro
//
//  Created by jolly on 2020/4/3.
//  Copyright © 2020 jolly. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdUncaughtExceptionHandler : NSObject

+ (void)setDefaultHandler;
+ (NSUncaughtExceptionHandler*)getHandler;

@end

NS_ASSUME_NONNULL_END

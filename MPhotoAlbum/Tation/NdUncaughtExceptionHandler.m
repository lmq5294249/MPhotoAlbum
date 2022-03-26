

#import "NdUncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>

NSString *applicationDocumentsDirectory() {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSString *strSysVersion = [[UIDevice currentDevice] systemVersion];
    NSString *phoneModel = [Tation_kSharedDeviceManager deviceVersion];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSString *timeBug = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *url = [NSString stringWithFormat:@"=============异常崩溃报告=============\n时间：%@\n手机型号: %@\n系统版本号：%@\nAPP名称及版本号:%@ Version：%@ \nname:%@\nreason:\n%@\ncallStackSymbols:\n%@",timeBug,phoneModel,strSysVersion,appName,currentVersion,
                     name,reason,[arr componentsJoinedByString:@"\n"]];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"HohemPro.ErrorIndex"];
    [[NSUserDefaults standardUserDefaults] setValue:url forKey:@"HohemPro.ErrorMessage"];
    NSString *path = [applicationDocumentsDirectory() stringByAppendingPathComponent:@"Exception.txt"];
    [url writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@implementation NdUncaughtExceptionHandler

-(NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void)setDefaultHandler
{
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

+ (NSUncaughtExceptionHandler*)getHandler
{
    return NSGetUncaughtExceptionHandler();
}

@end

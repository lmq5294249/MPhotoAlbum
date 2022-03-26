//
//  ContactDataModel.h
//
//  Created by lin on 2021/8/4.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ContactType) {
    OnlineContactType, //在线客服
    ServiceHotlineContactType, //客服热线
    MailboxContactType, //企业邮箱
    WeChatContactType, //微信公众号
    FaceBookContactType, //FaceBook
    EnterpriseWechatContactType, //企业微信客服
};

NS_ASSUME_NONNULL_BEGIN

@interface ContactDataModel : NSObject

@property (nonatomic,strong) UIImage *iconImage;

@property (nonatomic,strong) NSString *titleString;

@property (nonatomic,strong) NSString *firstDetailsString;

@property (nonatomic,strong) NSString *SecondDetailsString;

@property (nonatomic,strong) NSString *contentStr;

@property (nonatomic,assign) ContactType contactType;

@end

NS_ASSUME_NONNULL_END

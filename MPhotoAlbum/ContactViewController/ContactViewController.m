//
//  ContactViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/17.
//

#import "ContactViewController.h"
#import "ContactTableViewCell.h"
#import "GuideTableViewCell.h"
#import "GuideDataModel.h"
#import "ContactDataModel.h"
//#import "HHOnlineServiceVC.h"
#import "TationDeviceManager.h"

static NSString *GuideCellIdentifier = @"GuideCellIdentifier";
static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";

@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *firstSectionArray;
@property (nonatomic, strong) NSMutableArray *secondSectionArray;
@property (nonatomic, strong) UIImageView *qrCodeImageVIew;
@property (nonatomic, strong) UILabel *qrlabel;
@property (nonatomic, strong) UIImage *indicatorImg;
@property (nonatomic, assign) CGFloat fitRatio;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) NSInteger lineParam;
@property (nonatomic, assign) CGFloat firstSLHeight;
@property (nonatomic, assign) CGFloat secondSLHeight;
@property (nonatomic, strong) UIView *blackView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadData];
    [self setUpUI];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];

    CGFloat margin = 16;
    CGFloat w = 44;
    CGFloat h = 44;
    CGFloat btnMarginHeight = 4;
    CGFloat tableViewMarginHeight = 68;
    if (Tation_isIPhoneX) {
        self.firstSLHeight = 64;
        self.secondSLHeight = 103;
    }
    else{
        if (self.fitRatio < 0.98) {
            self.firstSLHeight = 55;
            btnMarginHeight = 4;
            tableViewMarginHeight = 55;
            self.secondSLHeight = 90;
        }
        else{
            self.firstSLHeight = 64;
            self.secondSLHeight = 103;
        }
    }

    self.backBtn.frame = CGRectMake(32 * self.fitRatio, CGRectGetMinY(Tation_safeArea) + btnMarginHeight, w, h);
    self.searchBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 32 * self.fitRatio, CGRectGetMinY(Tation_safeArea) + btnMarginHeight, w, h);

    w = 180;
    h = 44;
    self.titleLab.frame = CGRectMake((self.view.bounds.size.width - w) / 2, CGRectGetMinY(self.backBtn.frame), w, h);
    
    CGFloat labelLineHeight = 20;
    CGFloat defaultCellHeight = 90;
    
    self.tableView.frame = CGRectMake(margin*self.fitRatio, CGRectGetMinY(Tation_safeArea) + tableViewMarginHeight, CGRectGetWidth(self.view.frame) - 32*self.fitRatio, CGRectGetHeight(self.view.frame) - CGRectGetMinY(Tation_safeArea) - tableViewMarginHeight);
}

- (void)setUpUI
{
    self.view.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];;
    
    self.titleLab = [[UILabel alloc] init];
    self.titleLab.textColor = [UIColor blackColor];
    self.titleLab.font = [UIFont systemFontOfSize:18.0 weight:UIFontWeightBold];
    self.titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab.text = Tation_Resource_Str(@"HH.Function.Support");
    [self.view addSubview:self.titleLab];
    
    //左边->返回按钮
    self.backBtn = [[UIButton alloc]init];
    self.backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.backBtn addTarget:self action:@selector(didBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.backBtn setImage:[UIImage imageNamed:@"Hohem_Contact_back"] forState:UIControlStateNormal];
    [self.view addSubview:self.backBtn];
    
    //右边->搜索按钮（暂时未设置）
    self.searchBtn = [[UIButton alloc]init];
    self.searchBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //[self.searchBtn addTarget:self action:@selector(didBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.searchBtn setImage:[UIImage imageNamed:@"Hohem_Contact_search"] forState:UIControlStateNormal];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height*2/3) style:UITableViewStyleGrouped];
    self.tableView.scrollEnabled = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
    
    
    self.fitRatio = [self getFitLengthRatio];
    
    self.cellHeight = 90.0 * self.fitRatio;
    //测试计算UILabel的行数
    NSInteger lineNum = 2;//默认两层高度
    self.lineParam = 0;
    for (ContactDataModel *dataModel in self.secondSectionArray) {
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(96, 0, 235*self.fitRatio, 20)];
        testLabel.textColor = [UIColor blackColor];
        testLabel.font = [UIFont systemFontOfSize:14.0];
        testLabel.textAlignment = NSTextAlignmentLeft;
        testLabel.numberOfLines = 0;
        testLabel.text = dataModel.firstDetailsString;
        [testLabel sizeToFit];
        NSInteger num = ceilf(CGRectGetHeight(testLabel.frame) / (20.0*_fitRatio));
        self.lineParam = self.lineParam + (num -2);
        if (num > lineNum) {
            lineNum = num;
        }
    }
    self.cellHeight = 90.0 * _fitRatio  + (lineNum - 2)* 20.0;
}

- (void)loadData
{
    self.indicatorImg = [UIImage imageNamed:@"Hohem_Contact_skip"];
    //MARK:第一数组
    self.firstSectionArray = [[NSMutableArray alloc] init];
    GuideDataModel *produceModel = [[GuideDataModel alloc] init];
    produceModel.guideType = ProductManualGuideType;
    produceModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_manual"];
    produceModel.titleString = @"产品手册";
    [self.firstSectionArray addObject:produceModel];
    
    GuideDataModel *questionModel = [[GuideDataModel alloc] init];
    questionModel.guideType = FAQGuideType;
    questionModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_question"];
    questionModel.titleString = @"常见问题";
    [self.firstSectionArray addObject:questionModel];
    
    //MARK:第二数组
    self.secondSectionArray = [[NSMutableArray alloc] init];
    
    ContactDataModel *onlineModel = [[ContactDataModel alloc] init];
    onlineModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_Online"];
    onlineModel.titleString = Tation_Resource_Str(@"HH.Contact.Online.Title");
    onlineModel.firstDetailsString = Tation_Resource_Str(@"HH.Contact.Online.Des");
    onlineModel.contactType = OnlineContactType;
    onlineModel.contentStr = @"";
    
    NSString *serviceNumber;
    NSString *phoneNumber;
    NSString *serviceTime;
    switch (Tation_kSharedDeviceManager.languageEnum) {
        case TationLanguageEnum_CN:
        case TationLanguageEnum_CN_Hant:
            serviceNumber = @"400 960 9206";
            phoneNumber = @"4009609206";
            serviceTime = @"9:00 - 21:00(GMT+8)";
            break;
            
        case TationLanguageEnum_EN_US:
            serviceNumber = @"+1(888)9658512";
            phoneNumber = @"+1(888)9658512";
            serviceTime = @"9:00AM - 5:00PM(EST)";
            break;
            
        case TationLanguageEnum_EN_CN:
            serviceNumber = @"+44(0)808 2737578";
            phoneNumber = @"+44(0)8082737578";
            serviceTime = @"2:00PM - 10:00PM(GMT+0)";
            break;

        case TationLanguageEnum_EN_CA:
            serviceNumber = @"+1(855)758-8939";
            phoneNumber = @"+1(855)758-8939";
            serviceTime = @"9:00AM - 5:00PM(EST)";
            break;
            
        case TationLanguageEnum_PT_BR:
            serviceNumber = @"+55(0)800 5911897";
            phoneNumber = @"+55(0)800 5911897";
            serviceTime = @"10:00AM - 6:00PM(GMT-3)";
            break;
        default:
            break;
    }
    
    ContactDataModel *serviceModel = [[ContactDataModel alloc] init];
    serviceModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_servicePhone"];
    serviceModel.titleString = Tation_Resource_Str(@"HH.Contact.ServicePhone.Title");
    serviceModel.firstDetailsString = [NSString stringWithFormat:@"%@\n%@",serviceNumber,serviceTime];
    serviceModel.contactType = ServiceHotlineContactType;
    serviceModel.contentStr = phoneNumber;
    
    ContactDataModel *mailboxModel = [[ContactDataModel alloc] init];
    mailboxModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_Mailbox"];
    mailboxModel.titleString = Tation_Resource_Str(@"HH.Contact.Mailbox.Title");
    mailboxModel.firstDetailsString = [NSString stringWithFormat:@"service@hohem.com\n%@",Tation_Resource_Str(@"HH.Contact.Mailbox.Des")];
    mailboxModel.contactType = MailboxContactType;
    mailboxModel.contentStr = @"service@hohem.com";
    
    //微信公众号
    ContactDataModel *weChatModel = [[ContactDataModel alloc] init];
    weChatModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_Wechat"];
    weChatModel.titleString = Tation_Resource_Str(@"HH.Contact.Wechat.Title");
    weChatModel.firstDetailsString = [NSString stringWithFormat:@"浩瀚稳定器\n%@",Tation_Resource_Str(@"HH.Contact.Wechat.Des")];
    weChatModel.contactType = WeChatContactType;
    weChatModel.contentStr = @"浩瀚稳定器";
    
    ContactDataModel *faceBookModel = [[ContactDataModel alloc] init];
    faceBookModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_Facebook"];
    faceBookModel.titleString = Tation_Resource_Str(@"HH.Contact.Facebook.Title");
    faceBookModel.firstDetailsString = [NSString stringWithFormat:@"Hohem\n%@",Tation_Resource_Str(@"HH.Contact.Facebook.Des")];
    faceBookModel.contactType = FaceBookContactType;
    faceBookModel.contentStr = @"Hohem";
    
    //企业微信客服
    ContactDataModel *enterpriseWCModel = [[ContactDataModel alloc] init];
    enterpriseWCModel.iconImage = [UIImage imageNamed:@"Hohem_Contact_EnterpriseWeChat"];
    enterpriseWCModel.titleString = Tation_Resource_Str(@"HH.Contact.Wechat.Title");
    enterpriseWCModel.firstDetailsString = [NSString stringWithFormat:@"点击查看二维码\n%@",Tation_Resource_Str(@"HH.Contact.Wechat.Des")];
    enterpriseWCModel.contactType = EnterpriseWechatContactType;
    enterpriseWCModel.contentStr = @"浩瀚稳定器";
    
    //MARK:中英文判断加载不同的cell
//    if (self.onlineUrlStr && self.onlineUrlStr.length > 0) {
        
        [self.secondSectionArray addObject:onlineModel];
//    }
    
    if (serviceNumber) {
        
        [self.secondSectionArray addObject:serviceModel];
    }
    
    [self.secondSectionArray addObject:enterpriseWCModel];
    
    [self.secondSectionArray addObject:mailboxModel];

    if ([self isCurrentLanguageCN]) {
        
        [self.secondSectionArray addObject:weChatModel];
    }
    else{
        
        [self.secondSectionArray addObject:faceBookModel];
    }
}

- (BOOL)isCurrentLanguageCN
{
    return Tation_kSharedDeviceManager.languageEnum == TationLanguageEnum_CN;
}

- (CGFloat)getFitLengthRatio{

    CGFloat min = Tation_safeArea.size.width < Tation_safeArea.size.height ? Tation_safeArea.size.width : Tation_safeArea.size.height;
    
    return min / 390.0;
}

#pragma mark - 事件处理
- (void)dealWithGuideDataModel:(GuideDataModel *)dataModel
{
    switch (dataModel.guideType) {
        case ProductManualGuideType:
        {
            //MARK:产品手册
            
        }
            break;
            
        case FAQGuideType:
        {
            //MARK:常见问题
            
        }
            break;
            
        default:
            break;
    }
}

- (void)dealWithContactDataModel:(ContactDataModel *)dataModel
{
    switch (dataModel.contactType) {
        case OnlineContactType:
            //MARK:在线客服
//            if (self.onlineUrlStr) {
//                //跳转到客服网页
//                if (Hohem_kSharedUserInfoManager.isLogin) {
//
//                    HHOnlineServiceVC *vc = [[HHOnlineServiceVC alloc] init];
//                    vc.onlineUrlstr = self.onlineUrlStr;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }else{
//
//                    HohemLoginController *loginVC = [[HohemLoginController alloc]init];
//                    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:loginVC];
//                    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
//                    navVC.navigationBar.hidden = YES;
//                    [self presentViewController:navVC animated:YES completion:nil];
//                }
//            }
            break;
            
        case ServiceHotlineContactType:
            //MARK:客服热线
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",dataModel.contentStr]]]) {
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",dataModel.contentStr]] options:@{} completionHandler:nil];
            }else{
                
                NSLog(@"无法访问");
            }
            break;
            
        case MailboxContactType:
        {
            //MARK:邮箱
            [UIPasteboard generalPasteboard].string = dataModel.contentStr;
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.CopySuccess") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertVC addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"点击确认");
            }]];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
            break;
            
        case WeChatContactType:
        {
            //MARK:微信公众号
            [UIPasteboard generalPasteboard].string = dataModel.contentStr;
            NSString *wechatStr = @"weixin://";
            NSURL *wechatUrl = [NSURL URLWithString:wechatStr];
            if ([[UIApplication sharedApplication] canOpenURL:wechatUrl]) {
             
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.GotoWeChat.Title") message:Tation_Resource_Str(@"HH.GotoWeChat.Des") preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alertVc animated:YES completion:nil];
                
                [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"HH.GoToOtherApp") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if ([[UIApplication sharedApplication] canOpenURL:wechatUrl]) {
                        [[UIApplication sharedApplication] openURL:wechatUrl options:@{} completionHandler:nil];
                    }
                }]];
                
                [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
            }else{
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.CopySuccess") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
            
        case FaceBookContactType:
        {
            //MARK:FaceBook
            [UIPasteboard generalPasteboard].string = dataModel.contentStr;
            NSString *facebookStr = @"fb://";
            NSURL *facebookuUrl = [NSURL URLWithString:facebookStr];
            if ([[UIApplication sharedApplication] canOpenURL:facebookuUrl]) {
             
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.GotoFacebook.Title") message:Tation_Resource_Str(@"HH.GotoFacebook.Des") preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alertVc animated:YES completion:nil];
                
                [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"HH.GoToOtherApp") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if ([[UIApplication sharedApplication] canOpenURL:facebookuUrl]) {
                        [[UIApplication sharedApplication] openURL:facebookuUrl options:@{} completionHandler:nil];
                    }
                }]];
                
                [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
            }else{
                
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.CopySuccess") message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
            break;
            
        case EnterpriseWechatContactType:
        {
            //MARK:企业微信客服
            [self loadTheQRCodeView:dataModel];
        }
            break;
            
        default:
            break;
    }

}


- (void)loadTheQRCodeView:(ContactDataModel *)dataModel
{
    //黑色透明背景
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = CGRectGetHeight(self.view.frame);
    
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:_blackView];
    //白色内容背景
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(16*self.fitRatio, h + w - 32*self.fitRatio, w - 32*self.fitRatio, w - 32*self.fitRatio)];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 31.0;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [_blackView addSubview:self.contentView];
    
    NSString *titleString;
    UIImage *qrImage;
    NSString *qrString;
    NSString *btnString;
    //微信公众号 和 企业微信
    if (dataModel.contactType == WeChatContactType) {
        titleString = [NSString stringWithFormat:@"企业微信客服二维码"];
        qrImage = [UIImage imageNamed:@"HH.Joy.ServiceQR"];
        qrString = [NSString stringWithFormat:@"截图后用微信扫描二维码\n添加 hohem浩瀚 企业微信专属客服\n即可享受一对一答疑解惑"];
        btnString = [NSString stringWithFormat:@"已截图，前往微信"];
    }
    else if (dataModel.contactType == EnterpriseWechatContactType){
        titleString = [NSString stringWithFormat:@"企业微信客服二维码"];
        qrImage = [UIImage imageNamed:@"HH.Joy.ServiceQR"];
        qrString = [NSString stringWithFormat:@"截图后用微信扫描二维码\n添加 hohem浩瀚 企业微信专属客服\n即可享受一对一答疑解惑"];
        btnString = [NSString stringWithFormat:@"已截图，前往微信"];
    }
    
    //保存图片
    UIImageWriteToSavedPhotosAlbum(qrImage, nil, nil, nil);
    
    w = CGRectGetWidth(self.contentView.frame);
    h = CGRectGetHeight(self.contentView.frame);
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((w - 180*self.fitRatio)/2, 23*self.fitRatio, 180*self.fitRatio, 22*self.fitRatio)];
    titleLabel.text = titleString;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    [self.contentView addSubview:titleLabel];
    //二维码
    UIImageView *enterpriseWCView = [[UIImageView alloc] initWithFrame:
                                    CGRectMake((w - 128*self.fitRatio)/2, 61*self.fitRatio, 128*self.fitRatio, 128*self.fitRatio)];
    [enterpriseWCView setImage:qrImage];
    [self.contentView addSubview:enterpriseWCView];
    //详细介绍
    self.qrlabel = [[UILabel alloc] init];
    self.qrlabel.frame = CGRectMake((w - 240*self.fitRatio)/2,197*self.fitRatio,240*self.fitRatio,60*self.fitRatio);
    self.qrlabel.numberOfLines = 3;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:qrString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14], NSForegroundColorAttributeName: [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0]}];
    self.qrlabel.attributedText = string;
    self.qrlabel.textAlignment = NSTextAlignmentCenter;
    self.qrlabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    self.qrlabel.alpha = 1.0;
    [self.contentView addSubview:self.qrlabel];
    //按钮
    UIButton *weChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    weChatBtn.frame = CGRectMake((w - 194*self.fitRatio)/2, 273*self.fitRatio, 194*self.fitRatio, 38*self.fitRatio);
    weChatBtn.backgroundColor = [UIColor orangeColor];
    [weChatBtn setTitle:btnString forState:UIControlStateNormal];
    weChatBtn.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    weChatBtn.layer.masksToBounds = YES;
    weChatBtn.layer.cornerRadius = 19.f;
    [weChatBtn addTarget:self action:@selector(goToWeChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:weChatBtn];
    
    w = CGRectGetWidth(self.view.frame);
    h = CGRectGetHeight(self.view.frame);
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.frame = CGRectMake(16*self.fitRatio, h - 16*self.fitRatio - (w - 32*self.fitRatio), w - 32*self.fitRatio, w - 32*self.fitRatio);
    }];
}

- (void)goToWeChat:(id)btn
{
    [self.blackView removeFromSuperview];
    self.blackView = nil;
    //实现跳转
    //[UIPasteboard generalPasteboard].string = dataModel.contentStr;
    NSString *wechatStr = @"weixin://";
    NSURL *wechatUrl = [NSURL URLWithString:wechatStr];
    if ([[UIApplication sharedApplication] canOpenURL:wechatUrl]) {
     
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.GotoWeChat.Title") message:Tation_Resource_Str(@"HH.GotoWeChat.Des") preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVc animated:YES completion:nil];
        
        [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"HH.GoToOtherApp") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([[UIApplication sharedApplication] canOpenURL:wechatUrl]) {
                [[UIApplication sharedApplication] openURL:wechatUrl options:@{} completionHandler:nil];
            }
        }]];
        
        [alertVc addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
    }else{
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Tation_Resource_Str(@"HH.CopySuccess") message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addAction:[UIAlertAction actionWithTitle:Tation_Resource_Str(@"Hohem.Alert.Confirm") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertVC animated:YES completion:nil];
    }

}

- (void)didBackBtn:(UIButton *)btn {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if (self.blackView) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self.blackView];
        if (!CGRectContainsPoint(self.contentView.frame, point)) {
            [self.blackView removeFromSuperview];
            self.blackView = nil;
        }
    }
}

#pragma mark - UITableViewDelegate
//返回列表显示行数
//返回列表中Section的数量，默认返回1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.firstSectionArray.count;
    }
    return self.secondSectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GuideDataModel *dataModel = self.firstSectionArray[indexPath.row];
        GuideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GuideCellIdentifier];;
        
        if (cell == nil) {
            cell = [[GuideTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GuideCellIdentifier];
        }
        [cell.iconImageView setImage:dataModel.iconImage];
        cell.titleLabel.text = dataModel.titleString;
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
        cell.titleLabel.textAlignment = NSTextAlignmentLeft;
        [cell.chooseImageView setImage:self.indicatorImg];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if (indexPath.row == 0) {
            cell.SeparatorLine.hidden = YES;
        }
        return cell;
    }
    
    //section 2 的cell初始化
    ContactDataModel *dataModel = self.secondSectionArray[indexPath.row];
    
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CheckMarkCellIdentifier];;
    
    if (cell == nil) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier];
    }
    
    [cell.iconImageView setImage:dataModel.iconImage];
    
    cell.titleLabel.text = dataModel.titleString;
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
    cell.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:dataModel.firstDetailsString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 12], NSForegroundColorAttributeName: [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]}];
    cell.detailsLable.attributedText = string;
    cell.detailsLable.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0];
    cell.detailsLable.textAlignment = NSTextAlignmentLeft;
    [cell.detailsLable sizeToFit];
    NSInteger lineNum = ceilf(CGRectGetHeight(cell.detailsLable.frame) / (20.0*_fitRatio));
    [cell setDetailLabeFrame:lineNum];
    NSInteger defaultNum = 2;//默认两层高度
    CGFloat defaultCellHeight = 90;
    if (lineNum > defaultNum) {
        self.cellHeight = defaultCellHeight * _fitRatio  + (lineNum - defaultNum)* 20.0;
    }
    else{
        self.cellHeight = defaultCellHeight * _fitRatio;
    }
    
    [cell.chooseImageView setImage:self.indicatorImg];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if (indexPath.row == 0) {
        cell.SeparatorLine.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        [self dealWithGuideDataModel:self.firstSectionArray[indexPath.row]];
    }
    else{
        [self dealWithContactDataModel:self.secondSectionArray[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.firstSLHeight;
    }
    else{
        if (self.cellHeight > self.secondSLHeight) {
            return self.cellHeight;
        }
        return self.secondSLHeight;
    }
}

//设置tableVIew的section间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 16.0 * self.fitRatio;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 圆角角度
    CGFloat radius = 10.f;
    // 设置cell 背景色为透明
    cell.backgroundColor = UIColor.clearColor;
    // 创建两个layer
    CAShapeLayer *normalLayer = [[CAShapeLayer alloc] init];
    CAShapeLayer *selectLayer = [[CAShapeLayer alloc] init];
    // 获取显示区域大小
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    // cell的backgroundView
    UIView *normalBgView = [[UIView alloc] initWithFrame:bounds];
    // 获取每组行数
    NSInteger rowNum = [tableView numberOfRowsInSection:indexPath.section];
    // 贝塞尔曲线
    UIBezierPath *bezierPath = nil;
    
    if (rowNum == 1) {
        // 一组只有一行（四个角全部为圆角）
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
        normalBgView.clipsToBounds = NO;
    }else {
        normalBgView.clipsToBounds = YES;
        if (indexPath.row == 0) {
            normalBgView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 0, 0));
            CGRect rect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 0, 0));
            // 每组第一行（添加左上和右上的圆角）
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(radius, radius)];
        }else if (indexPath.row == rowNum - 1) {
            normalBgView.frame = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 0, 0));
            CGRect rect = UIEdgeInsetsInsetRect(bounds, UIEdgeInsetsMake(0, 0, 0, 0));
            // 每组最后一行（添加左下和右下的圆角）
            bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCornerBottomLeft|UIRectCornerBottomRight) cornerRadii:CGSizeMake(radius, radius)];
        }else {
            // 每组不是首位的行不设置圆角
            bezierPath = [UIBezierPath bezierPathWithRect:bounds];
        }
    }
    
    // 阴影
    //normalLayer.shadowColor = [UIColor blackColor].CGColor;
    //normalLayer.shadowOpacity = 0.2;
    //normalLayer.shadowOffset = CGSizeMake(0, 0);
    //normalLayer.path = bezierPath.CGPath;
    //normalLayer.shadowPath = bezierPath.CGPath;
    
    // 把已经绘制好的贝塞尔曲线路径赋值给图层，然后图层根据path进行图像渲染render
    normalLayer.path = bezierPath.CGPath;
    selectLayer.path = bezierPath.CGPath;
    
    // 设置填充颜色
    normalLayer.fillColor = [UIColor whiteColor].CGColor;
    // 添加图层到nomarBgView中
    [normalBgView.layer insertSublayer:normalLayer atIndex:0];
    normalBgView.backgroundColor = UIColor.clearColor;
    cell.backgroundView = normalBgView;
    
    // 替换cell点击效果
    UIView *selectBgView = [[UIView alloc] initWithFrame:bounds];
    selectLayer.fillColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
    [selectBgView.layer insertSublayer:selectLayer atIndex:0];
    selectBgView.backgroundColor = UIColor.clearColor;
    cell.selectedBackgroundView = selectBgView;
}

@end

//
//  ViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/14.
//

#import "ViewController.h"
#import "HohemAlbumViewController.h"
#import "ContactViewController.h"
#import "TemplatesViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *shadeImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.shadeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.shadeImageView.backgroundColor = [UIColor clearColor];
    [self.shadeImageView setImage:[UIImage imageNamed:@"13"]];
    [self.view addSubview:self.shadeImageView];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blur];

    visualEffectView.frame = CGRectMake(0, 0, CGRectGetWidth(self.shadeImageView.frame), CGRectGetHeight(self.shadeImageView.frame));
    visualEffectView.alpha = 1.0;
    [self.shadeImageView addSubview:visualEffectView];
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.colors = @[(__bridge id)[[UIColor whiteColor] colorWithAlphaComponent:0].CGColor, (__bridge id)[UIColor whiteColor].CGColor];
    layer.locations = @[@0.0, @1.0];
    //上下渐变
    layer.startPoint = CGPointMake(0.5, 0);
    layer.endPoint = CGPointMake(0.5, 1);
    layer.frame = self.shadeImageView.frame;
    
    UIView *effectShadowView = [[UIView alloc] init];
    effectShadowView.frame = self.shadeImageView.frame;
    effectShadowView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.24];
    [effectShadowView.layer addSublayer:layer];
    [self.shadeImageView addSubview:effectShadowView];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn setFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200)];
    [albumBtn setTitle:@"剪辑模板" forState:UIControlStateNormal];
    [albumBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [albumBtn setBackgroundColor:[UIColor whiteColor]];
    albumBtn.layer.masksToBounds = YES;
    albumBtn.layer.cornerRadius = 10;
    [albumBtn addTarget:self action:@selector(btnEnterPhotoAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:albumBtn];
    // Do any additional setup after loading the view.
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setFrame:CGRectMake(0, 400, CGRectGetWidth(self.view.frame), 200)];
    [helpBtn setTitle:@"技术支持" forState:UIControlStateNormal];
    [helpBtn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [helpBtn setBackgroundColor:[UIColor whiteColor]];
    helpBtn.layer.masksToBounds = YES;
    helpBtn.layer.cornerRadius = 10;
    [helpBtn addTarget:self action:@selector(btnEnterHelpView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpBtn];
}


- (void)btnEnterPhotoAlbum:(id)sender
{
    NSLog(@"进入相册");
    
//    HohemAlbumViewController *albumController = [[HohemAlbumViewController alloc] init];
//    albumController.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:albumController animated:YES completion:nil];
    
    TemplatesViewController *templateController = [[TemplatesViewController alloc] init];
    UINavigationController* navVC = [[UINavigationController alloc] initWithRootViewController:templateController];
    navVC.navigationBarHidden = YES;
    navVC.toolbarHidden = YES;
    navVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)btnEnterHelpView:(id)sender
{
    ContactViewController *helpViewController = [[ContactViewController alloc] init];
    helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:helpViewController animated:YES completion:nil];
}

@end

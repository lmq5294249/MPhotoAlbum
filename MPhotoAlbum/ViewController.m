//
//  ViewController.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/14.
//

#import "ViewController.h"
#import "HohemAlbumViewController.h"
#import "ContactViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    
    UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn setFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 200)];
    [albumBtn setTitle:@"相册" forState:UIControlStateNormal];
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
    
    HohemAlbumViewController *albumController = [[HohemAlbumViewController alloc] init];
    albumController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:albumController animated:YES completion:nil];
    
}

- (void)btnEnterHelpView:(id)sender
{
    ContactViewController *helpViewController = [[ContactViewController alloc] init];
    helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:helpViewController animated:YES completion:nil];
}

@end

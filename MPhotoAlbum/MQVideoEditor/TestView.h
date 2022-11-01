//
//  TestView.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/9.
//

#import <UIKit/UIKit.h>

/*
 目前在这个项目要father如果使用strong的话就会造成其他地方资源不释放PlayerView
 */

@interface TestView : UIView

@property (nonatomic, strong) UIView *father;

@property (nonatomic, strong) UIView *subtestView;

- (void)removeAllSubView;

@end

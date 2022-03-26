//
//  HohemShowAlbumViewController.h
//  Hohem Pro
//
//  Created by jolly on 2019/11/25.
//  Copyright © 2019 jolly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HohemAlbumViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScrollToCurrenIndexPathBlock)(NSInteger curIndex);
typedef void(^DeleteItemBlock)(NSInteger curIndex);

@interface HohemShowAlbumViewController : UIViewController

@property (nonatomic, strong) UIImage *firstImage;
@property (nonatomic, copy) ScrollToCurrenIndexPathBlock scrollToCurrenIndexPathBlock;
@property (nonatomic, copy) DeleteItemBlock deleteItemBlock;

- (instancetype)initWithDataFetchResult:(NSArray *)array selectedIndex:(NSInteger)selectedIndex showType:(HohemAlbumViewController_ShowType)showType;
@end

NS_ASSUME_NONNULL_END

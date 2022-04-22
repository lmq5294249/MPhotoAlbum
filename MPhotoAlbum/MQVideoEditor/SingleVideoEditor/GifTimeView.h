//
//  GifTimeView.h
//  VideoEdite
//
//  Created by WDeng on 2017/11/7.
//  Copyright © 2017年 WDeng. All rights reserved.
//

#import <UIKit/UIKit.h>

//  动画起始 持续 时间
typedef  struct  TimeRange{
    CGFloat beginPercent;
    CGFloat endPercent;
}TimeRange;


@interface GifTimeView : UIImageView

@property (nonatomic,copy) void(^blockValue)(CGFloat leftPercent, CGFloat rightPercent,BOOL finish);
@property (nonatomic,assign, readonly) CGFloat leftPercent;
@property (nonatomic,assign, readonly) CGFloat rightPercent;
@property (nonatomic,assign) BOOL panStateEnded;
@property (nonatomic,assign) CGFloat frameBarWidth;
@property (nonatomic,assign) CGFloat limitingPercent; //限制最小的百分比长度

- (void)currentLeft:(CGFloat)leftPercent rightPercent:(CGFloat)rightPercent;

@end

//
//  VideoFrameBar.h
//  ancda
//
//  Created by WDeng on 16/12/22.
//  Copyright © 2016年 WDeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoFrameBarDelegate <NSObject>

- (void)dragHandleViewWithPercent:(CGFloat)percent;

@end
 
typedef void(^LongPressHandleBlock)(NSInteger index);

@interface VideoFrameBar : UIView

@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) CGFloat percent;
@property(nonatomic, assign) BOOL hiddenHandle;
@property(nonatomic, assign) BOOL isSelected;
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, copy) LongPressHandleBlock longPressHandleBlock;

//新增用来裁剪缩略图
@property (nonatomic, assign) NSTimeInterval playDrutation;
@property (nonatomic, assign) NSTimeInterval startPlayTime;

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url startTime:(NSTimeInterval)startValue duration:(NSTimeInterval)duraValue;

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url screenCapturePerSecond:(BOOL)flag;

@end


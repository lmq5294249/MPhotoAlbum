//
//  GifTimeView.m
//  VideoEdite
//
//  Created by WDeng on 2017/11/7.
//  Copyright © 2017年 WDeng. All rights reserved.
//

#import "GifTimeView.h"
#import "UIView+Frame.h"

@interface GifTimeView ()

@property (nonatomic, weak) UIView *rightView;
@property (nonatomic, weak) UIView *leftView;

@end

@implementation GifTimeView

static NSInteger Handle_W = 25;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        UIImage *orginImage = [UIImage imageNamed:@"video_edite_range"];
        self.image = [orginImage resizableImageWithCapInsets:UIEdgeInsetsMake(39, 30, 39, 30) resizingMode:UIImageResizingModeTile];
        [self configure];
    }
    return self;
}

- (void)configure {
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(self.width - Handle_W, 0, Handle_W, self.height)];
    rightView.tag = 1000;
    [self addSubview:rightView];
    UIPanGestureRecognizer *panR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    [rightView addGestureRecognizer:panR];
    self.rightView = rightView;
    
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.width - rightView.width, self.height)];
    [self addSubview:leftView];
    leftView.tag = 1001;
    UIPanGestureRecognizer *panL = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveView:)];
    [leftView addGestureRecognizer:panL];
    self.leftView = leftView;
    
}

- (void)moveView:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self];
    //NSLog(@"打印移动时在父View的x位置 = %f",point.x);
    CGRect frame = self.frame;
    if (pan.view.tag == 1000) { // right
        CGFloat value = point.x + frame.size.width;
        if (value <= Handle_W *2) {
            value = Handle_W *2;
        }
        frame.size.width = value;
    } else if ( pan.view.tag == 1001) { // left
        
        CGFloat value = point.x + frame.origin.x;
        
        if (_frameBarWidth - value  <= Handle_W *2) {
            value = _frameBarWidth - Handle_W *2;
        }
        frame.origin.x =value;
    }
    
    CGFloat lastViewFrameWidth = frame.origin.x + frame.size.width;
    if (lastViewFrameWidth > _frameBarWidth) {
        frame.size.width= _frameBarWidth - frame.origin.x;

    }
    if (frame.origin.x < 0) {
       frame.origin.x = 0;
    }
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _panStateEnded = NO;
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        _panStateEnded = YES;
    }
    
    self.frame = frame;
    [self updateLayout];
    [pan setTranslation:CGPointZero inView:self];
    
}

- (void)updateLayout {
    self.leftView.frame = CGRectMake(0, 0, self.width - Handle_W , self.height);
    self.rightView.frame = CGRectMake(self.width - Handle_W, 0, Handle_W, self.height);
    _leftPercent = self.x / _frameBarWidth;
    _rightPercent =  self.width  / _frameBarWidth;
    
    if (self.blockValue) {
        self.blockValue(_leftPercent, _rightPercent,_panStateEnded);
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.rightView.width = Handle_W;
    self.rightView.right = self.width;
    self.leftView.left = 0;
    self.leftView.right = self.rightView.left;
}

- (void)currentLeft:(CGFloat)leftPercent rightPercent:(CGFloat)rightPercent {
     self.x = leftPercent * _frameBarWidth ;
     self.width = rightPercent * _frameBarWidth;
    if (self.right >= _frameBarWidth) {
        self.right = _frameBarWidth;
    }
    
    
}
 
@end

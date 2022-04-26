//
//  MSlidePageView.m
//  GANBAN
//
//  Created by 林漫钦 on 2022/3/11.
//

#import "MSlidePageView.h"

@implementation WaveSlideView

- (instancetype)initWithFrame:(CGRect)frame
            layoutHeightValue:(CGFloat)height
                 cornerRadius:(CGFloat)radiusValue
                  marginValue:(CGFloat)margin
                  layoutColor:(UIColor *)color
          supportShadowBounds:(BOOL)enableShadow
{
    if (self = [super initWithFrame:frame]) {
        
        self.widthValue = CGRectGetWidth(self.frame);
        self.viewHeight = CGRectGetHeight(self.frame);
        
        self.heightValue = height;
        self.cornerRadius = radiusValue;
        self.marginValue = margin;
        self.fillColor = color;
        self.shadowBounds = enableShadow;
        [self setUpSlideViewControlUI];
    }
    return self;
}

- (void)setUpSlideViewControlUI
{
    //设置圆角率
    
//    CGFloat widthValue = 120;
//    CGFloat heightValue = 40;
//    CGFloat cornerRadius = 15;
//    CGFloat marginValue = 10;
    
    //计算的layer距离顶部位置
    CGFloat topValue;
    if (_viewHeight > _heightValue) {
        topValue = _viewHeight - _heightValue;
    }
    else{
        topValue = 0;
    }
    
    //UIView *slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _widthValue, _viewHeight)];
    self.backgroundColor = [UIColor clearColor];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, _viewHeight)];
    [path addLineToPoint:CGPointMake(_marginValue, _viewHeight)];
    [path addQuadCurveToPoint:CGPointMake(_marginValue + _cornerRadius, _viewHeight - _cornerRadius) controlPoint:CGPointMake(_marginValue + _cornerRadius, _viewHeight)];
    [path addLineToPoint:CGPointMake(_marginValue +_cornerRadius, _cornerRadius + topValue)];
    [path addQuadCurveToPoint:CGPointMake(_marginValue + _cornerRadius * 2, topValue) controlPoint:CGPointMake(_marginValue + _cornerRadius, topValue)];
    [path addLineToPoint:CGPointMake(_widthValue - _marginValue - _cornerRadius * 2, topValue)];
    [path addQuadCurveToPoint:CGPointMake(_widthValue - _marginValue - _cornerRadius, _cornerRadius + topValue) controlPoint:CGPointMake(_widthValue - _marginValue - _cornerRadius, topValue)];
    [path addLineToPoint:CGPointMake(_widthValue - _marginValue - _cornerRadius, _viewHeight - _cornerRadius)];
    [path addQuadCurveToPoint:CGPointMake(_widthValue - _marginValue, _viewHeight) controlPoint:CGPointMake(_widthValue - _marginValue - _cornerRadius, _viewHeight)];
    [path addLineToPoint:CGPointMake(_widthValue, _viewHeight)];
    [path addLineToPoint:CGPointMake(0, _viewHeight)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.frame = CGRectMake(0, 0, _widthValue, _viewHeight);
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = _fillColor.CGColor;
    if (self.shadowBounds) {
        layer.shadowColor = [UIColor darkGrayColor].CGColor;
        layer.masksToBounds = YES;
        layer.shadowRadius = _cornerRadius/2;
        layer.shadowOffset = CGSizeMake(0.0f,0.0f);
        layer.shadowOpacity = 0.2f;
    }
    [self.layer addSublayer:layer];
}


@end


@implementation ViewConfig

- (instancetype)init
{
    if (self = [super init]) {
        //部分参数默认设置
        self.buttonLayoutType = ButtonLayoutTypeCustom;
        self.selectIndex = 0;
        self.normalTextColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        self.selectTextColor = [UIColor colorWithRed:255.0/255.0 green:101.0/255.0 blue:1.0/255.0 alpha:1.0];
        self.textFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
        self.cornerRadius = 0;
        self.marginOfBtnValue = 0;
        self.shadowBounds = YES;
    }
    return self;
}

@end



@interface MSlidePageView ()

@property (nonatomic, assign) BOOL supportSlide;

@property (nonatomic, strong) NSMutableArray <UIButton*>*btnsArray; //存放按钮的数组

@property (nonatomic, strong) NSMutableArray <UILabel*>*labelsArray;

@property (nonatomic, strong) NSMutableArray <NSString*>*titlesArray; //存放文字数组

@property (nonatomic) CGSize singleBtnSize; //单个按钮的大小

@property (nonatomic, strong) WaveSlideView *waveView;

@property (nonatomic, assign) NSInteger currentIndex; //当前的按钮位置

@end

@implementation MSlidePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0]];
        
        [self addSubview:self.scrollView];
        
        self.currentIndex = 0;
        
        self.normalTextColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
        self.selectTextColor = [UIColor colorWithRed:255.0/255.0 green:101.0/255.0 blue:1.0/255.0 alpha:1.0];
        self.textFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightBold];
        
    }
    
    return self;
}

- (void)setUpUIForView
{
    
    for (int i = 0; i < _viewConfig.numberOfBtns; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(_viewConfig.marginOfBtnValue + self.singleBtnSize.width * i, 0, self.singleBtnSize.width, CGRectGetHeight(self.frame))]; //按钮的实际高度是跟整个frame一直，因为涉及到阴影的大小
        btn.tag = i;
        
        [btn setTitleColor:self.normalTextColor forState:UIControlStateNormal];
        [btn setTitleColor:self.selectTextColor forState:UIControlStateSelected];
        
        [btn addTarget:self action:@selector(btnTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - _viewConfig.realBtnHeight, self.singleBtnSize.width, _viewConfig.realBtnHeight)];
        if (_viewConfig.stringArray.count) {
            label.text = [NSString stringWithFormat:@"%@",_viewConfig.stringArray[i]];
        }
        else{
            label.text = [NSString stringWithFormat:@"单位%d",i];
        }
        if (_currentIndex == i) {
            label.textColor = self.selectTextColor;
        }
        else{
            label.textColor = self.normalTextColor;
        }
        label.font = _viewConfig.textFont;
        label.textAlignment = NSTextAlignmentCenter;
        [btn addSubview:label];
        [self.scrollView addSubview:btn];
        [self.btnsArray addObject:btn];
        [self.labelsArray addObject:label];
    }
    
}

- (void)setUpWaveSlideViewForButton
{
    self.waveView = [[WaveSlideView alloc] initWithFrame:CGRectMake(0, 0, _viewConfig.waveWidth, CGRectGetHeight(self.frame))
                                       layoutHeightValue:_viewConfig.realBtnHeight
                                            cornerRadius:_viewConfig.cornerRadius
                                             marginValue:_viewConfig.marginOfBtnValue
                                             layoutColor:_viewConfig.sliderFillColor
                                     supportShadowBounds:_viewConfig.shadowBounds];
    
    [self.scrollView insertSubview:self.waveView atIndex:0];
}

//MARK:布局设置
- (void)setViewConfig:(ViewConfig *)viewConfig
{
    if (_viewConfig) {
        //删除原有布局
        if (self.btnsArray.count > 0) {
            for (UIButton *btn in self.btnsArray) {
                [btn removeFromSuperview];
            }
            for (UILabel *label in self.labelsArray) {
                [label removeFromSuperview];
            }
        }
        [self.btnsArray removeAllObjects];
        [self.labelsArray removeAllObjects];
        [self.waveView removeFromSuperview];
    }
    _viewConfig = viewConfig;
    
    //布局类型-- 设计到scrollview是否可以滑动增加内容大小

    self.singleBtnSize = _viewConfig.btnSize;
    _currentIndex = _viewConfig.selectIndex;
    if (_viewConfig.normalTextColor) {
        self.normalTextColor = _viewConfig.normalTextColor;
    }
    if (_viewConfig.selectTextColor) {
        self.selectTextColor = _viewConfig.selectTextColor;
    }
    if (_viewConfig.textFont) {
        self.textFont = _viewConfig.textFont;
    }
    
    if (_viewConfig.numberOfBtns != _viewConfig.stringArray.count) {
        NSLog(@"当前按钮数量和文字数组不一致!!!");
        _viewConfig.numberOfBtns = (int)_viewConfig.stringArray.count;
    }
    
    if (viewConfig.buttonLayoutType == ButtonLayoutTypeCustom) {
        //固定大小的话，按照给出按钮的大小来计算看是否重新设置scrollview的ContentSize
        CGFloat btnContentWidth =  _viewConfig.numberOfBtns * _singleBtnSize.width;
        if (btnContentWidth > CGRectGetWidth(self.frame)) {
            //重新设置
            self.scrollView.contentSize = CGSizeMake(btnContentWidth, CGRectGetHeight(self.frame));
            self.supportSlide = YES;
        }
        else{
            self.supportSlide = NO;
        }
    }
    
    //view布局设置生效
    if (_viewConfig) {
        
        [self setUpUIForView];
        
        [self setUpWaveSlideViewForButton];
    }
    
    if (self.btnsArray.count <= 0) {
        self.waveView.hidden = YES;
        return;
    }
    
    //设置滑动到某个位置
//    if (_currentIndex != 0) {
        //CGFloat slideDistance = self.singleBtnSize.width * _currentIndex;
        UIButton *button = (UIButton *)self.btnsArray[_currentIndex];
        [self.waveView setCenter:button.center];
//    }
    [self showOrHiddenPartOfLabel];
    if (self.supportSlide) {
        [self viewDidScrollToCenterOfScreen];
    }
}


#pragma mark - 懒加载

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    return _scrollView;
}

- (NSMutableArray <UIButton*>*)btnsArray
{
    if (!_btnsArray) {
        _btnsArray = [NSMutableArray array];
    }
    return _btnsArray;
}

- (NSMutableArray <UILabel*>*)labelsArray
{
    if (!_labelsArray) {
        _labelsArray = [NSMutableArray array];
    }
    return _labelsArray;
}

- (NSMutableArray <NSString*>*)titlesArray
{
    if (!_titlesArray) {
        _titlesArray = [NSMutableArray array];
    }
    return _titlesArray;
}


#pragma mark - 按钮
- (IBAction)btnTouchDown:(id)sender
{
    UIButton *btn = sender;
    
    int i = 0;
    for (UIButton *button in self.btnsArray) {

        if (button.tag == btn.tag) {
            UILabel *label = self.labelsArray[i];
            label.textColor = self.selectTextColor;
        }
        else{
            UILabel *label = self.labelsArray[i];
            label.textColor = self.normalTextColor;
        }
        i++;
    }
    
    //获取当前按钮的位置，然后移动滑动块到达相应位置
    if (_currentIndex != btn.tag) {
        
        _currentIndex = (int)btn.tag;
//        //移动滑动块
//        CGFloat slideDistance = self.singleBtnSize.width * _currentIndex;
        //UIButton *btn = (UIButton *)self.btnsArray[_currentIndex];
        CGFloat slideDistance = CGRectGetMinX(btn.frame);
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
//            weakSelf.waveView.frame = CGRectMake(slideDistance, 0, CGRectGetWidth(weakSelf.waveView.frame), CGRectGetHeight(weakSelf.waveView.frame));
            [weakSelf.waveView setCenter:btn.center];
        }];
        
    }
    
    if (self.supportSlide) {
        
        [self viewDidScrollToCenterOfScreen];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(slidePageViewDidSelecetedIndex:)]) {
        [self.delegate slidePageViewDidSelecetedIndex:_currentIndex];
    }
}

- (void)viewDidScrollToCenterOfScreen
{
    //支持滑动情况下考虑到按钮偏移的位置，需要调整下显示位置
    NSInteger showCount = floorf(self.scrollView.frame.size.width / self.singleBtnSize.width);
    if (_currentIndex+1 >= showCount && _viewConfig.numberOfBtns > showCount) {
        NSInteger offsetIndexValue = _currentIndex+1 - showCount;
        if (_currentIndex+1 == _viewConfig.numberOfBtns) {
            [self.scrollView setContentOffset:CGPointMake(self.singleBtnSize.width * offsetIndexValue, 0) animated:YES];
        }
        else{
            offsetIndexValue ++;
            [self.scrollView setContentOffset:CGPointMake(self.singleBtnSize.width * offsetIndexValue, 0) animated:YES];
        }
    }
    else if (_currentIndex == 0 || _currentIndex == 1)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (_currentIndex == 2 && _viewConfig.numberOfBtns > showCount+3)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

#pragma mark - scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    int i = 0;
    for (UILabel *label in self.labelsArray) {
        label.text = _viewConfig.stringArray[i];
        i++;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
{
    [self showOrHiddenPartOfLabel];
}

- (void)showOrHiddenPartOfLabel
{
    NSInteger showCount = floorf((self.scrollView.contentOffset.x + self.scrollView.frame.size.width) / self.singleBtnSize.width);
    NSInteger numBtnsOfScreen = floorf(self.scrollView.frame.size.width / self.singleBtnSize.width);
    if (showCount == numBtnsOfScreen && numBtnsOfScreen < _viewConfig.numberOfBtns) {
        int i = 0;
        for (UILabel *label in self.labelsArray) {
            label.text = _viewConfig.stringArray[i];
            if ( showCount-1 == i) {
                label.text = @"...";
            }
            else{
                label.text = _viewConfig.stringArray[i];
            }
            i++;
        }
    }
    else{
        if (showCount > _currentIndex+1 && showCount < _viewConfig.numberOfBtns) {
            //界面显示的最后一个btn显示省略号...
            int i = 0;
            for (UILabel *label in self.labelsArray) {
                label.text = _viewConfig.stringArray[i];
                
                if ((_currentIndex+1) <= i) {
                    label.text = @"...";
                }
                else{
                    label.text = _viewConfig.stringArray[i];
                }
                i++;
            }
        }
        else
        {
            int i = 0;
            for (UILabel *label in self.labelsArray) {
                label.text = _viewConfig.stringArray[i];
                i++;
            }
        }
    }
}

- (void)resetStringsArray:(NSMutableArray *)array
{
    if (array.count >= self.labelsArray.count) {
        int i = 0;
        for (UILabel *label in self.labelsArray) {
            label.text = (NSString *)array[i];
            i++;
        }
    }
    else{
        NSLog(@"字符串数组的赋值出错误，数量不对!");
    }
    _viewConfig.stringArray = array;
}

@end

//
//  MSlidePageView.h
//  GANBAN
//
//  Created by 林漫钦 on 2022/3/11.
//

#import <UIKit/UIKit.h>

@interface  WaveSlideView: UIView

@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;
//定义基本参数
@property (nonatomic, assign) CGFloat widthValue;  //等同于实际的viewWidth，这个并不受影响，因为有marginValue存在
@property (nonatomic, assign) CGFloat heightValue; //实际的高度涉及到阴影位置的所以预留上面一部分
@property (nonatomic, assign) CGFloat cornerRadius; //边圆角率
@property (nonatomic, assign) CGFloat marginValue; //左右边距
@property (nonatomic, strong) UIColor *fillColor; //填充颜色
@property (nonatomic, assign) BOOL shadowBounds;

- (instancetype)initWithFrame:(CGRect)frame
            layoutHeightValue:(CGFloat)height
                 cornerRadius:(CGFloat)radiusValue
                  marginValue:(CGFloat)margin
                  layoutColor:(UIColor *)color
          supportShadowBounds:(BOOL)enableShadow;

- (void)setUpSlideViewControlUI;

@end



typedef NS_ENUM(NSUInteger, ButtonLayoutType) {
    ButtonLayoutTypeCustom,  //自定义
    ButtonLayoutTypeAverage, //等分
    ButtonLayoutTypeFixed,  //固定
};


@interface ViewConfig : NSObject

@property (nonatomic, strong) NSMutableArray *stringArray;

@property (nonatomic, assign) ButtonLayoutType buttonLayoutType;

@property (nonatomic, assign) NSInteger numberOfBtns;

@property (nonatomic) CGSize btnSize; //实际有用的是宽度，基本高低是跟父view保持一致，这个用到计算位置

@property (nonatomic, assign) CGFloat realBtnHeight; //看到的真是高度。需要排除掉阴影的面积

@property (nonatomic, assign) CGFloat marginOfBtnValue; //左右边距

@property (nonatomic, assign) CGFloat cornerRadius; //边圆角率

@property (nonatomic, strong) UIColor *sliderFillColor; //填充颜色

@property (nonatomic, assign) BOOL shadowBounds; //是否支持阴影

@property (nonatomic, assign) NSInteger selectIndex; //选中位置

@property (nonatomic, strong) UIColor *normalTextColor; //正常显示文字颜色

@property (nonatomic, strong) UIColor *selectTextColor;

@property (nonatomic, strong) UIFont *textFont; //选项的字体大小

@property (nonatomic, assign) CGFloat waveWidth;

@end



@protocol MSlidePageDelegate <NSObject>

@optional
- (void)slidePageViewDidSelecetedIndex:(NSInteger)index;

@end

@interface MSlidePageView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<MSlidePageDelegate> delegate;

@property (nonatomic, strong) UIButton *btn;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIColor *normalTextColor;

@property (nonatomic, strong) UIColor *selectTextColor;

@property (nonatomic, strong) UIFont *textFont;

@property (nonatomic, strong) ViewConfig *viewConfig; //设置

- (instancetype)initWithFrame:(CGRect)frame;

@end



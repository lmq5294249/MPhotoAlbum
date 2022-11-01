//
//  MVideoFrameDisplayer.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/14.
//

#import <UIKit/UIKit.h>

@interface MVideoFrameDisplayer : UIView

@property (nonatomic, assign) NSTimeInterval startPointTime; //初始化的时间起点位置

@property (nonatomic,copy) void(^videoRePlayBlock)(NSTimeInterval start, NSTimeInterval duration, BOOL finish);

- (instancetype)initWithFrame:(CGRect)frame url:(NSURL *)url videoFragmentDur:(NSTimeInterval)time;

@end


@interface FrameCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *frameImageView;

@end

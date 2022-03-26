//
//  HHMediaCell.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/15.
//

#import "HHMediaCell.h"
#import <Photos/PHFetchResult.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/PHImageManager.h>

@implementation HHMediaCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.thumbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.thumbImageView.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.thumbImageView];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, frame.size.height - 24 - 4, 43, 24)];
        self.timeLabel.text = @"00:00";
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:self.timeLabel];
        self.timeLabel.hidden = YES;
        
        self.selectStateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 22, 0, 22, 22)];
        [self.contentView addSubview:self.selectStateImageView];
        self.selectStateImageView.hidden = YES;
        
        /* 添加长按手势*/
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlelongGesture:)];
        /*定义按的时间*/
        longPress.minimumPressDuration = 0.8;
        [self addGestureRecognizer:longPress];
    }
    return self;
}

- (void)layoutSubviews
{
    //加载UI效果
    self.thumbImageView.layer.masksToBounds = YES;
    self.thumbImageView.layer.cornerRadius = 8;
    self.thumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

- (void)displayModelDataWithModel:(LocalAssetModel *)model
{
    /*
     PHAssetMediaTypeImage >图片,
     PHAssetMediaTypeVideo >视频,
     */
    if(model.propertyType == PHAssetMediaTypeImage)
    {
        self.playImageView.hidden = YES;
        self.timeLabel.hidden = YES;
    }else
    {
        //self.playImageView.hidden = NO;
        //self.playImageView.image = [UIImage imageNamed:@"videoPlay_FD"];
        
        self.timeLabel.text = [self durationString:model.asset.duration];
        self.timeLabel.hidden = NO;
    }
    if(model.isSelect == YES)
    {
        self.selectStateImageView.image = [UIImage imageNamed:@"Hohem_Album_selectedCell"];
        self.contentView.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:101.0/255.0 blue:1/255.0 alpha:1.0].CGColor;
        self.contentView.layer.borderWidth = 2;
        self.contentView.layer.cornerRadius = 8;
    }else
    {
        self.selectStateImageView.image = nil;
        self.contentView.layer.borderColor = nil;
        self.contentView.layer.borderWidth = 0;
        self.contentView.layer.cornerRadius = 0;
    }
    
    if (!model.propertyThumbImage) {
        __weak typeof(self) weakSelf = self;
        PHImageManager *manager = [PHImageManager defaultManager];
        PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.synchronous = YES;
        [manager requestImageForAsset:model.asset
                           targetSize:CGSizeMake(200, 200)
                          contentMode:PHImageContentModeAspectFit
                              options:options
                        resultHandler:^(UIImage *result, NSDictionary *info) {
            
            weakSelf.thumbImageView.image = result;
            model.propertyThumbImage = result;

            }];
    }
    else{
        //节省频繁来回获取图片步骤
        self.thumbImageView.image = model.propertyThumbImage;
    }
    
}

-(NSString *)durationString:(double)duration
{
    NSString *str;
    if (duration >= 0 && duration < 60) {
        int sec = (int)duration % 60;
        str = [NSString stringWithFormat:@"00:%02d", sec];
    }else if (duration >= 60 && duration <= 3600) {
        int min = duration/60;
        int sec = (int)duration%60;
        str = [NSString stringWithFormat:@"%02d:%02d", min, sec];
    }else {
        int hour = (int)duration/3600;
        int min = ((int)duration%3600)/60;
        int sec = ((int)duration%3600)%60;
        str = [NSString stringWithFormat:@"%d:%02d:%02d", hour, min, sec];
    }
    return str;
}

/*实现长按手势方法*/
#pragma mark - 长按手势
- (void)handlelongGesture:(UILongPressGestureRecognizer *)longPress
{
    self.gestureBlock(YES);
}

@end

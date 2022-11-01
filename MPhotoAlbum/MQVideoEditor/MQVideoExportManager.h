//
//  MQVideoExportManager.h
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/6/17.
//

#import <Foundation/Foundation.h>
#import "EditTemplateModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MQVideoExportManager : NSObject

@property (nonatomic, copy) NSArray<AVURLAsset *> *clips;
@property (nonatomic, copy) NSArray *clipTimeRanges;
@property (nonatomic) CMTime transitionDuration;

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) EditTemplateModel *templateModel;

@property (nonatomic, strong) NSMutableArray *paramModelArray;
@property (nonatomic, strong) NSMutableArray *transTimeArray;

- (void)exporeResultVideo:(NSString *)videoName completionHandler:(void(^)(NSURL *))block;

@end

NS_ASSUME_NONNULL_END

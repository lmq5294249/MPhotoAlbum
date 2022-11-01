//
//  EditTemplateModel.h
//  GANBAN
//
//  Created by 林漫钦 on 2022/3/7.
//

#import <Foundation/Foundation.h>
#import "VideoEditorParamTypeHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditTemplateModel : NSObject

@property (nonatomic, copy) NSString *storyId;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSString *demoVideo;
@property (nonatomic, copy) NSString *music;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, copy) NSString *maskVideoName;
@property (nonatomic, copy)   NSArray *scripts;

@end

@interface EditUnitModel : NSObject

@property (nonatomic, assign) MQMediaType mediaType;
@property (nonatomic, assign) float mediaDuration;
@property (nonatomic, assign) float audioStartOffset;
@property (nonatomic, assign) float startTime;
@property (nonatomic, assign) int filterType;
@property (nonatomic, assign) MQTransitionType transitionsType;
@property (nonatomic, assign) float transDuration;
@property (nonatomic, strong) UIImage *image;


@end


NS_ASSUME_NONNULL_END

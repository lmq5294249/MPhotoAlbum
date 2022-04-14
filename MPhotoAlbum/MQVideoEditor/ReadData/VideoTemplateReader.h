//
//  VideoTemplateReader.h
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/3/28.
//

#import <Foundation/Foundation.h>
#import "EditTemplateModel.h"

typedef NS_ENUM(NSUInteger, CustomVideoTemplateType) {
    CustomVideoTemplateType_StoryA,
};



@interface VideoTemplateReader : NSObject

- (EditTemplateModel *)getVideoTemplateParameter:(CustomVideoTemplateType)type;

@end


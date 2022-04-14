//
//  VideoTemplateReader.m
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/3/28.
//

#import "VideoTemplateReader.h"

NSString * const StoryId = @"storyId";
NSString * const Thumbnail = @"thumbnail";
NSString * const DemoVideo = @"demoVideo";
NSString * const BGMusic = @"backgroundMusic";
NSString * const TemplateTitle = @"templateTitle";
NSString * const Description = @"description";
NSString * const Amount = @"amount";
NSString * const Scripts = @"scripts";

@implementation VideoTemplateReader

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (EditTemplateModel *)getVideoTemplateParameter:(CustomVideoTemplateType)type
{
    //测试加载本地的JSON文件获取数据
    NSString *mainBundleDirectory=[[NSBundle mainBundle] bundlePath];
    NSString *path=[mainBundleDirectory stringByAppendingPathComponent:@"template.json"];
    NSURL *url=[NSURL fileURLWithPath:path];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    EditTemplateModel *templateModel = [[EditTemplateModel alloc] init];
    templateModel.storyId = [dic objectForKey:StoryId];
    templateModel.thumbnail = [dic objectForKey:Thumbnail];
    templateModel.demoVideo = [dic objectForKey:DemoVideo];
    templateModel.music = [dic objectForKey:BGMusic];
    templateModel.title = [dic objectForKey:TemplateTitle];
    templateModel.desc = [dic objectForKey:Description];
    templateModel.amount = [[dic objectForKey:Amount] integerValue];
    //templateModel.scripts = [dic objectForKey:@"desc"];
    NSArray *array = [dic objectForKey:Scripts];
    NSMutableArray *editUnitArray = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        EditUnitModel *editUnitModel = [[EditUnitModel alloc] init];
        NSDictionary *dicTemp = array[i];
        editUnitModel.mediaType = [[dicTemp objectForKey:@"mediaType"] integerValue];
        editUnitModel.mediaDuration = [[dicTemp objectForKey:@"mediaDuration"] floatValue];
        editUnitModel.audioStartOffset = [[dicTemp objectForKey:@"audioStartOffset"] floatValue];
        editUnitModel.startTime = [[dicTemp objectForKey:@"startTime"] floatValue];
        editUnitModel.filterType = [[dicTemp objectForKey:@"filterType"] intValue];
        editUnitModel.transitionsType = [[dicTemp objectForKey:@"transitionsType"] integerValue];
        editUnitModel.transDuration = [[dicTemp objectForKey:@"transitionsDuration"] floatValue];
        [editUnitArray addObject:editUnitModel];
    }
    templateModel.scripts = [editUnitArray copy];
    NSLog(@"打印最后生成数据类型:%@",templateModel);
    return templateModel;
}



@end

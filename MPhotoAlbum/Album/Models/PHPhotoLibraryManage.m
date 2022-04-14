//
//  PHPhotoLibraryManage.m
//  MPhotoAlbum
//
//  Created by 林漫钦 on 2022/3/15.
//

#import "PHPhotoLibraryManage.h"
#import "LocalAssetModel.h"

@implementation PHPhotoLibraryManage

/**
 *  遍历相册
 *
 *  @param photoName      相册名
 */
- (void)ergodicPhotoAlbumWithPhotoName:(NSString *)photoName
{


    PHFetchResult *assetsFetchResult = nil;
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.fetchLimit = 0;
    //直接通过PHAsset获得相机胶卷中的所有图片
    assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
    
    if (!assetsFetchResult) {
        self.dic = nil;
        return;
    }

    __block NSMutableDictionary * assetTypePhotoDic = [NSMutableDictionary dictionary];
    __block NSMutableDictionary * assetTypeVideoDic = [NSMutableDictionary dictionary];
    [assetsFetchResult enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        PHAsset *asset = obj;
        LocalAssetModel * assetModel = [[LocalAssetModel alloc]init];
        assetModel.asset=asset;
        assetModel.propertyType = asset.mediaType;
        NSDate * date =[asset valueForKey:@"creationDate"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy.MM.dd"];
        assetModel.propertyDate = [dateFormatter stringFromDate:date];
        assetModel.propertyLocation = [asset valueForKey:@"location"];
        assetModel.propertyName = [asset valueForKey:@"filename"];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
           assetTypePhotoDic = [self divideIntoGroups:assetTypePhotoDic WithAssetModel:assetModel];
        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
            assetModel.propertyDuration = asset.duration;
            assetTypeVideoDic = [self divideIntoGroups:assetTypeVideoDic WithAssetModel:assetModel];
        }

    }];
    
    _dic = @{@"photo":assetTypePhotoDic,
             @"video":assetTypeVideoDic
            };
}


/**
 按照日期归纳文件
 */
-(NSMutableDictionary * )divideIntoGroups:(NSMutableDictionary *)dic WithAssetModel:(LocalAssetModel*)assetModel
{
    NSMutableArray * assetTypePhotoArr = [NSMutableArray array];
    if (dic.count == 0) {
        [assetTypePhotoArr addObject:assetModel];
        [dic setObject:assetTypePhotoArr forKey:assetModel.propertyDate];
    }else{
        NSArray * keyArr = [dic allKeys];
        BOOL isExist = YES;
        for (NSString * date in keyArr) {
            if ([assetModel.propertyDate isEqualToString:date]) {
                isExist = YES;
                break;
            }else{
                isExist = NO;
            }
        }
        if (isExist) {
            NSMutableArray * arr = [NSMutableArray arrayWithArray:[dic objectForKey:assetModel.propertyDate]];
            [arr addObject:assetModel];
            [dic setObject:arr forKey:assetModel.propertyDate];
        }else{
            [assetTypePhotoArr addObject:assetModel];
            [dic setObject:assetTypePhotoArr forKey:assetModel.propertyDate];
        }
    }
    return dic;
}

@end

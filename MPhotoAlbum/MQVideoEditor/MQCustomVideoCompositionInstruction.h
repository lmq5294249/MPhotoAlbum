//
//  MQCustomVideoCompositionInstruction.h
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface MQCustomVideoCompositionInstruction : NSObject <AVVideoCompositionInstruction>

@property CMPersistentTrackID foregroundTrackID;
@property CMPersistentTrackID backgroundTrackID;
@property CMPersistentTrackID maskVideoTrackID;
@property int type;
@property NSArray *paramArray;

- (id)initWithSourceTrackIDs:(NSArray *)sourceTrackIDs paramArray:(NSArray *)array forTimeRange:(CMTimeRange)timeRange;
- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange;
- (id)initTransitionWithSourceTrackIDs:(NSArray*)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange;

@end


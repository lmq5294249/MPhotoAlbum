//
//  MQCustomVideoCompositionInstruction.m
//  GIFPlayDemo
//
//  Created by 林漫钦 on 2022/1/4.
//

#import "MQCustomVideoCompositionInstruction.h"

@implementation MQCustomVideoCompositionInstruction

@synthesize timeRange = _timeRange;
@synthesize enablePostProcessing = _enablePostProcessing;
@synthesize containsTweening = _containsTweening;
@synthesize requiredSourceTrackIDs = _requiredSourceTrackIDs;
@synthesize passthroughTrackID = _passthroughTrackID;

@synthesize paramArray = _paramArray;
@synthesize foregroundTrackID = _foregroundTrackID;
@synthesize backgroundTrackID = _backgroundTrackID;
@synthesize maskVideoTrackID = _maskVideoTrackID;

- (id)initWithSourceTrackIDs:(NSArray *)sourceTrackIDs paramArray:(NSArray *)array forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _requiredSourceTrackIDs = sourceTrackIDs;
        _timeRange = timeRange;
        _containsTweening = FALSE;
        _enablePostProcessing = FALSE;
        _paramArray = array;
    }
    
    return self;
}

- (id)initPassThroughTrackID:(CMPersistentTrackID)passthroughTrackID forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _passthroughTrackID = passthroughTrackID;
        _requiredSourceTrackIDs = nil;
        _timeRange = timeRange;
        _containsTweening = FALSE;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}

- (id)initTransitionWithSourceTrackIDs:(NSArray *)sourceTrackIDs forTimeRange:(CMTimeRange)timeRange
{
    self = [super init];
    if (self) {
        _requiredSourceTrackIDs = sourceTrackIDs;
        _passthroughTrackID = kCMPersistentTrackID_Invalid;
        _timeRange = timeRange;
        _containsTweening = TRUE;
        _enablePostProcessing = FALSE;
    }
    
    return self;
}


@end

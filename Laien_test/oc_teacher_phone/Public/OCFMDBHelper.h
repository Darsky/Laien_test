//
//  OCFMDBHelper.h
//  oc_teacher_phone
//
//  Created by 朱伟铭 on 2021/1/13.
//  Copyright © 2021 朱伟铭. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class OCWhiteBoardSceneModel, ClockInRecordModel;
@interface OCFMDBHelper : NSObject
+ (instancetype)shareFMDBHelper;


+ (NSMutableArray*)queryDateRecordsWithDate:(NSDate*)date;


+ (void)addRecordToTableWithDate:(NSDate*)date
                 andSuccessBlock:(void(^)(ClockInRecordModel *recordModel,
                         NSInteger totalCount,
                         NSInteger totatDayCount,
                         NSInteger continuousDay,
                         NSInteger maxContinuousDay))successBlock
                   andErrorBlock:(void(^)(NSString *errorString))errorBlock;


+ (void)deleteRecordWithModel:(ClockInRecordModel*)model
              andSuccessBlock:(void(^)(NSInteger totalCount,
                                       NSInteger totatDayCount,
                                       NSInteger continuousDay,
                                       NSInteger maxContinuousDay))successBlock
                andErrorBlock:(void(^)(NSString *errorString))errorBlock;


+ (NSString*)dateStringFromDate:(NSDate*)date;

+ (NSDictionary*)clockInStatistics;


//+ (NSMutableArray*)queryAllLiveRoomlLog;
//+ (NSMutableArray*)queryLiveRoomlLogWithLiveId:(NSInteger)liveId;
//+ (BOOL)insertOpreationRecordToDbWithModel:(OCTeacherOpreationRecordModel*)model;
//+ (BOOL)deleteLiveRoomLogDataWithLiveId:(NSInteger)liveId;
//+ (BOOL)deleteLiveRoomAllDataWithLiveId:(NSInteger)liveId;
//+ (NSMutableArray*)queryLiveRoomlSnapshotWithLiveId:(NSInteger)liveId;
//+ (BOOL)insertLiveSnapshotToDbWithModel:(OCLiveSnapshotModel*)model;
//+ (BOOL)cleanLiveSnapshotFromDbWithLiveId:(NSInteger)liveId;
//
//+ (NSMutableArray*)queryLiveRoomlWhiteBoardScenesLiveId:(NSInteger)liveId;
//+ (long)insertWhiteBoardSceneToDbWithModel:(OCWhiteBoardSceneModel*)model;
//+ (BOOL)updateToDbWithModel:(OCWhiteBoardSceneModel*)model;
//+ (BOOL)cleanWhiteBoardScenesFromDbWithLiveId:(NSInteger)liveId;
//+ (long long)getDataBaseFileSize;
//+ (BOOL)cleanAllSnapshotData;
//
//#pragma mark - 新的操作记录机制
//+ (NSMutableArray*)queryLiveRoomlRecordWithLiveId:(NSInteger)liveId;
//+ (BOOL)insertNewOpreationRecordToDbWithModel:(OCTeacherOpreationRecordModel*)model;
//+ (BOOL)deleteLiveRoomRecordDataWithLiveId:(NSInteger)liveId;

@end

NS_ASSUME_NONNULL_END

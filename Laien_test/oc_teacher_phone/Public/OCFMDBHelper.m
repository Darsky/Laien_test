//
//  OCFMDBHelper.m
//  oc_teacher_phone
//
//  Created by 朱伟铭 on 2021/1/13.
//  Copyright © 2021 朱伟铭. All rights reserved.
//

#import "OCFMDBHelper.h"
#import <FMDatabase.h>
#import "ClockInRecordModel.h"

@interface OCFMDBHelper () {
    
}

@property (strong, nonatomic) FMDatabase *db;

@end

@implementation OCFMDBHelper

+ (instancetype)shareFMDBHelper {
    static OCFMDBHelper *fmdbHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fmdbHelper = [[OCFMDBHelper alloc] init];
    });
    return fmdbHelper;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"temp_clock_in_record2.db"];
        FMDatabase *db = [FMDatabase databaseWithPath:path];
        if (![db open]) {
            self.db = nil;
        }
        else {
            self.db = db;
            BOOL shouldRollBack = NO;
            @try {
                [self.db beginTransaction];
                NSString *sql1 = @"create table if not exists date_record ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'record_date' TEXT NOT NULL,'record_continuous' INTEGER NOT NULL)";
                BOOL result1 = [self.db executeUpdate:sql1];
                if (result1) {
                    NSLog(@"create date_record success");
                } else {
                    shouldRollBack = YES;
                }
                NSString *sql2 = @"create table if not exists date_clockin_record ('ID' INTEGER PRIMARY KEY AUTOINCREMENT,'record_date' INTEGER NOT NULL,'timestamp' TEXT NOT NULL)";
                BOOL result2 = [self.db executeUpdate:sql2];
                if (result2) {
                    NSLog(@"create date_clockin_record success");
                } else {
                    shouldRollBack = YES;
                }
            } @catch (NSException *exception) {
                shouldRollBack = YES;
            } @finally {
                if (shouldRollBack) {
                    [self.db rollback];
                } else {
                    [self.db commit];
                }
            }
          
            [self.db close];
        }
    }
    return self;
}

+ (NSMutableArray*)queryDateRecordsWithDate:(NSDate*)date {
    return [[OCFMDBHelper shareFMDBHelper] queryDateRecordsWithDate:date];
}

- (NSMutableArray*)queryDateRecordsWithDate:(NSDate*)date {
    if (!date) {
        return [NSMutableArray array];
    } else {
        [self.db open];
        NSString *dateString = [self dateStringFromDate:date];
        NSMutableArray *resultArray = [NSMutableArray array];
        FMResultSet *recordQueryResult = [self.db executeQuery:@"select * from 'date_clockin_record' where record_date = ? order by ID desc" withArgumentsInArray:@[dateString]];
        while ([recordQueryResult next]) {
            ClockInRecordModel *model = [[ClockInRecordModel alloc] init];
            model.recordId = [recordQueryResult intForColumn:@"ID"];
            model.timestampFormatterString = [recordQueryResult stringForColumn:@"timestamp"];
            [resultArray addObject:model];
        }
        [self.db close];
        return resultArray;
    }
}

#pragma mark - OpreationOpreationRecord Method

+ (void)addRecordToTableWithDate:(NSDate*)date
andSuccessBlock:(void(^)(ClockInRecordModel *recordModel, NSInteger totalCount, NSInteger totatDayCount, NSInteger continuousDay, NSInteger maxContinuousDay))successBlock
                   andErrorBlock:(void(^)(NSString *errorString))errorBlock {
    [[OCFMDBHelper shareFMDBHelper] addRecordToTableWithDate:date
                                             andSuccessBlock:^(ClockInRecordModel *recordModel,
                                                               NSInteger totalCount,
                                                               NSInteger totalDayCount,
                                                               NSInteger continuousDay,
                                                               NSInteger maxContinuousDay) {
        successBlock(recordModel, totalCount, totalDayCount, continuousDay, maxContinuousDay);
        }
                                               andErrorBlock:^(NSString *errorString) {
        errorBlock(errorString);
        }];
}

- (void)addRecordToTableWithDate:(NSDate*)date
                 andSuccessBlock:(void(^)(ClockInRecordModel *recordModel,
                                          NSInteger totalCount,
                                          NSInteger totalDayCount,
                                          NSInteger continuousDay,
                                          NSInteger maxContinuousDay))successBlock
                   andErrorBlock:(void(^)(NSString *errorString))errorBlock {
    [self.db open];
    
    NSString *errorString = nil;
    ClockInRecordModel *recordModel = nil;
    
    NSString *dateString = [self dateStringFromDate:date];
    NSString *timestampString = [self dateRecordStringFromDate:date];
    
    BOOL shouldRollBack = NO;
    @try {
        [self.db beginTransaction];
        
        //1.计算连续打卡天数
        NSInteger recordContinuous = 0; //是今天默认计数+1， 补卡不管
        NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        if([today day] == [otherDay day] && [today month] == [otherDay month] && [today year] == [otherDay year]) {
            recordContinuous = 1;
        }
        if (recordContinuous > 0) {
            NSTimeInterval lastDatTime = 24 * 60 * 60;//一年的秒数
            NSDate *lastDate = [date dateByAddingTimeInterval:-lastDatTime];
            NSString *lastDateString = [self dateStringFromDate:lastDate];
            FMResultSet *lastDateResult = [self.db executeQuery:@"select * from 'date_record' where record_date = ?" withArgumentsInArray:@[lastDateString]];
            while ([lastDateResult next]) {
                recordContinuous += [lastDateResult intForColumn:@"record_continuous"];
            }
        }

        
        NSInteger dateId = NSNotFound;
        FMResultSet *dateCheckResult = [self.db executeQuery:@"select * from 'date_record' where record_date = ?" withArgumentsInArray:@[dateString]];
        while ([dateCheckResult next]) {
            dateId = [dateCheckResult intForColumn:@"ID"];
        }
        
        if (dateId == NSNotFound) {
            BOOL insertDateResult = [self.db executeUpdate:@"insert into 'date_record'(record_date,record_continuous) values(?,?)" withArgumentsInArray:@[dateString,@(recordContinuous)]];
            if (!insertDateResult) {
                errorString = @"创建日期数据失败";
                shouldRollBack = YES;
            }
        } //存在就不管
        
        //1.插入打卡数据
        BOOL insertRecordResult = [self.db executeUpdate:@"insert into 'date_clockin_record' (record_date,timestamp) values(?,?)" withArgumentsInArray:@[dateString,timestampString]];
        if (!insertRecordResult) {
            errorString = @"创建打卡数据失败";
            shouldRollBack = YES;
        } else {

        }

    } @catch (NSException *exception) {
        shouldRollBack = YES;
        errorString = [NSString stringWithFormat:@"异常： %@", [exception description]];
    } @finally {
        if (shouldRollBack) {
            [self.db rollback];
        } else {
            [self.db commit];
            recordModel = [[ClockInRecordModel alloc] init];
            recordModel.recordId = [self.db lastInsertRowId];
            recordModel.recordDateString = dateString;
            recordModel.timestampFormatterString = timestampString;
            //重新统计
        }
    }
  
    if (errorString == nil) {
        NSDictionary *statistics = [self clockInStatisticsShouldClose:NO];
        [self.db close];
        successBlock(recordModel, [statistics[@"totalCount"] integerValue], [statistics[@"totalDayCount"] integerValue], [statistics[@"continuousDay"] integerValue], [statistics[@"maxContinuousDay"] integerValue]);
    } else {
        [self.db close];
        errorBlock(errorString);
    }
}

+ (NSDictionary*)clockInStatistics {
    return [[OCFMDBHelper shareFMDBHelper] clockInStatisticsShouldClose:YES];
}

- (NSDictionary*)clockInStatisticsShouldClose:(BOOL)shouldClose {
    
    NSInteger totalCount = 0;
    NSInteger totalDayCount = 0;
    NSInteger continuousDay = 0;
    NSInteger maxContinuousDay = 0;
    
    if (![self.db isOpen]) {
        [self.db open];
    }
    
    //1.总打卡次数
    FMResultSet *totalCountResult = [self.db executeQuery:@"select count(*) as totalCount from 'date_clockin_record'"];
    while ([totalCountResult next]) {
        totalCount = [totalCountResult intForColumn:@"totalCount"];
    }
    
    //2.总打卡天数
    FMResultSet *totalDayResult = [self.db executeQuery:@"select count(*) as totalDayCount from 'date_record'"];
    while ([totalDayResult next]) {
        totalDayCount = [totalDayResult intForColumn:@"totalDayCount"];
    }
    
    //3.当前连续打卡天数,有今天就显示今天，有昨天就显示昨天，超过一天作废
    NSDate *todayDate = [NSDate date];
    NSString *todayDateString = [self dateStringFromDate:todayDate];
    FMResultSet *dateCheckResult = [self.db executeQuery:@"select * from 'date_record' where record_date = ?" withArgumentsInArray:@[todayDateString]];
    while ([dateCheckResult next]) {
        continuousDay = [dateCheckResult intForColumn:@"record_continuous"];
    }
    
    if (continuousDay == 0) {
        NSTimeInterval lastDatTime = 24 * 60 * 60;//一年的秒数
        NSDate *lastDate = [todayDate dateByAddingTimeInterval:-lastDatTime];
        NSString *lastDateString = [self dateStringFromDate:lastDate];
        FMResultSet *lastDateResult = [self.db executeQuery:@"select * from 'date_record' where record_date = ?" withArgumentsInArray:@[lastDateString]];
        while ([lastDateResult next]) {
            continuousDay = [lastDateResult intForColumn:@"record_continuous"];
        }
    }
    
    //4.历史最高连续打卡天数
    FMResultSet *maxContinuousResult = [self.db executeQuery:@"select max(record_continuous) as maxContinuous from 'date_record'"];
    while ([maxContinuousResult next]) {
        maxContinuousDay = [maxContinuousResult intForColumn:@"maxContinuous"];
    }
    
    if (shouldClose && [self.db isOpen]) {
        [self.db close];
    }
    
    NSDictionary *resultDic = @{@"totalCount":@(totalCount),
                                @"totalDayCount":@(totalDayCount),
                                @"continuousDay":@(continuousDay),
                                @"maxContinuousDay":@(maxContinuousDay)};
    return resultDic;
}


+ (void)deleteRecordWithModel:(ClockInRecordModel*)model
              andSuccessBlock:(void(^)(NSInteger totalCount,
                                       NSInteger totatDayCount,
                                       NSInteger continuousDay,
                                       NSInteger maxContinuousDay))successBlock
                andErrorBlock:(void(^)(NSString *errorString))errorBlock {
    [[OCFMDBHelper shareFMDBHelper] deleteRecordWithModel:model
                                          andSuccessBlock:^(NSInteger totalCount,
                                                            NSInteger totatDayCount,
                                                            NSInteger continuousDay,
                                                            NSInteger maxContinuousDay) {
        successBlock(totalCount, totatDayCount, continuousDay, maxContinuousDay);
        } andErrorBlock:^(NSString *errorString) {
            errorBlock(errorString);
        }];
}

- (void)deleteRecordWithModel:(ClockInRecordModel*)model
              andSuccessBlock:(void(^)(NSInteger totalCount,
                                       NSInteger totatDayCount,
                                       NSInteger continuousDay,
                                       NSInteger maxContinuousDay))successBlock
                     andErrorBlock:(void(^)(NSString *errorString))errorBlock {
    if ([model isKindOfClass:[ClockInRecordModel class]]) {
        [self.db open];
        BOOL result = [self.db executeUpdate:@"delete from 'date_clockin_record' where ID = ?" withArgumentsInArray:@[@(model.recordId)]];
        if (result) {
            NSDictionary *statistics = [self clockInStatisticsShouldClose:NO];
            [self.db close];
            successBlock([statistics[@"totalCount"] integerValue], [statistics[@"totalDayCount"] integerValue], [statistics[@"continuousDay"] integerValue], [statistics[@"maxContinuousDay"] integerValue]);
        } else {
            [self.db close];
                        errorBlock( @"数据删除失败");
        }
    } else {
        errorBlock( @"无效的数据类型");
    }
}

+ (NSString*)dateStringFromDate:(NSDate*)date {
    return [[OCFMDBHelper shareFMDBHelper] dateStringFromDate:date];
}

- (NSString*)dateStringFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *timestampString = [dateFormatter stringFromDate:date];
    return timestampString;
}

- (NSString*)dateRecordStringFromDate:(NSDate*)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss 打卡"];
    NSString *timestampString = [dateFormatter stringFromDate:date];
    
    return timestampString;
}



@end

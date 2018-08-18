//
//  JusikRecord.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 25..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JusikDayRecord : NSObject {
    @private
    NSDate *_date;
    double _startTime;
    double _period;
    
    NSMutableArray *_values;
    double _startValue;
    double _endValue;
    
    BOOL _hasEndValue;
    BOOL _isRecording;
}
@property (nonatomic, readonly, retain) NSDate *date;
@property (nonatomic, readonly) double startTime;
@property (nonatomic, readonly) double period;

@property (nonatomic, readonly) NSArray *values;
@property (nonatomic, readonly) double startValue;
@property (nonatomic, readonly) double endValue;

@property (nonatomic, readonly) BOOL hasEndValue;
@property (nonatomic, readonly) BOOL isRecording;

- (id)initWithDate: (NSDate *)date
         startTime: (double)startTime
            period: (double)period
            values: (NSArray *)values
       hasEndValue: (BOOL)hasEndValue;

@end

@interface JusikRecord : NSObject {
    @private
    NSMutableArray *_records;
    JusikDayRecord *_currentDayRecord;
    
    // for JusikDayRecord
    NSDate *_currentDate;
    double _startTime;
    double _period;
    BOOL _hasEndValue;
    double _endValue;
    BOOL _isRecording;
}

@property (nonatomic, readonly) NSMutableArray *records;
@property (nonatomic, readonly) JusikDayRecord *currentDayRecord;

@property (nonatomic, retain) NSDate *currentDate;
@property double startTime;
@property double period;
@property BOOL hasEndValue;
@property double endValue;

@property (nonatomic, readonly) BOOL isRecording;

- (void)replaceDayRecordHistories: (NSArray *)records;

- (void)startRecording;
- (void)endRecording;

- (void)recordValue: (double)value;

@end

@interface JusikRecord (MovingAverage)

- (NSArray *)fiveDayMovingAverageOfDays: (NSUInteger)days;
- (NSArray *)twentyDayMovingAverageOfDays: (NSUInteger)days;
- (NSArray *)thirtyFourDayMovingAverageOfDays: (NSUInteger)days;

@end

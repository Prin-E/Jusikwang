//
//  JusikRecord.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 25..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikRecord.h"

#pragma mark - JusikDayRecord 정의 코드
@interface JusikDayRecord () 

@property (nonatomic, readwrite, retain) NSDate *date;
@property (nonatomic, readwrite) double startTime;
@property (nonatomic, readwrite) double period;

@property (nonatomic, readwrite) double startValue;
@property (nonatomic, readwrite) double endValue;

@property (nonatomic, readwrite) BOOL hasEndValue;

- (void)startRecording;
- (void)endRecording;

- (void)recordValue: (double)value;

@end

#pragma mark - JusikDayRecord 구현 코드
@implementation JusikDayRecord
@synthesize date = _date;
@synthesize startTime = _startTime;
@synthesize period = _period;
@synthesize values = _values;
@synthesize startValue = _startValue;
@synthesize endValue = _endValue;
@synthesize hasEndValue = _hasEndValue;
@synthesize isRecording = _isRecording;

#pragma mark - 초기화 메서드
- (id)init {
    self = [super init];
    if(self) {
        _values = [NSMutableArray new];
    }
    return self;
}

#pragma mark - 레코딩
- (void)startRecording {
    if(_isRecording) return;
    
    _isRecording = YES;
}

- (void)endRecording {
    if(_isRecording == NO) return;
    _isRecording = NO;
    
    if(self.hasEndValue) {
        [self recordValue: self.endValue];
    }
}

- (void)recordValue:(double)value {
    NSNumber *n = [NSNumber numberWithDouble: value];
    
    if(!_values.count)
        _startValue = value;
    [_values addObject: n];
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_date release];
    [_values release];
    [super dealloc];
}

@end

#pragma mark - JusikRecord 구현 코드
@interface JusikRecord (Private)
- (NSArray *)_movingAverageOfDay: (NSUInteger)day ofDays: (NSUInteger)days;
@end

@implementation JusikRecord
@synthesize records = _records;
@synthesize currentDayRecord = _currentDayRecord;
@synthesize isRecording = _isRecording;

@synthesize currentDate = _currentDate;
@synthesize startTime = _startTime;
@synthesize period = _period;
@synthesize hasEndValue = _hasEndValue;
@synthesize endValue = _endValue;

#pragma mark - 초기화 메서드
- (id)init {
    self = [super init];
    if(self) {
        _records = [NSMutableArray new];
        _currentDate = [[NSDate alloc] init];
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (void)setCurrentDate:(NSDate *)currentDate {
    // nil 은 무시.
    if(currentDate == nil)
        return;
    
    [currentDate retain];
    [_currentDate release];
    _currentDate = currentDate;
}

- (void)setStartTime:(double)startTime {
    // 음수값은 0으로 치환
    if(startTime < 0)
        startTime = 0.0f;
    _startTime = startTime;
}

- (double)startTime {
    return _startTime;
}

- (void)setPeriod:(double)period {
    // 음수값은 0.1으로 치환
    if(period < 0)
        period = 0.1;
    _period = period;
}

- (double)period {
    return _period;
}

#pragma mark - 레코딩
- (void)startRecording {
    JusikDayRecord *newRecord = [[JusikDayRecord alloc] init];
    newRecord.date = self.currentDate;
    newRecord.startTime = self.startTime;
    newRecord.period = self.period;
    newRecord.hasEndValue = self.hasEndValue;
    newRecord.endValue = self.endValue;
    
    [newRecord startRecording];
    _isRecording = YES;
    
    [_records addObject: newRecord];
    _currentDayRecord = newRecord;
}

- (void)endRecording {
    [_currentDayRecord endRecording];
    _isRecording = NO;
}

- (void)recordValue: (double)value {
    [_currentDayRecord recordValue: value];
}

#pragma mark - 5, 20, 34일선
- (NSArray *)fiveDayMovingAverageOfDays:(NSUInteger)days {
    return [self _movingAverageOfDay: 5 ofDays: days];
}

- (NSArray *)twentyDayMovingAverageOfDays:(NSUInteger)days {
    return [self _movingAverageOfDay: 20 ofDays: days];
    
}

- (NSArray *)thirtyFourDayMovingAverageOfDays:(NSUInteger)days {
    return [self _movingAverageOfDay: 34 ofDays: days];
    
}

- (NSArray *)_movingAverageOfDay: (NSUInteger)day ofDays:(NSUInteger)days {
    NSUInteger count = [_records count];
    if(count < day)
        return nil;
    
    NSMutableArray *a = [NSMutableArray array];
    for(NSUInteger i = MAX(count-days-1, day-1); i < count; i++) {
        double ev_sum = 0.0;
        for(NSUInteger j = 0; j < day; j++) {
            JusikDayRecord *d = [self.records objectAtIndex: i + j + 1 - day];
            ev_sum += d.endValue;
        }
        ev_sum /= (double)day;
        NSNumber *n = [NSNumber numberWithDouble: ev_sum];
        [a addObject: n];
    }
    return a;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_records release];
    [_currentDayRecord release];
    [_currentDate release];
    
    [super dealloc];
}

@end

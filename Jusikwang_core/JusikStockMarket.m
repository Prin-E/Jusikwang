//
//  JusikStockMarket.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikStockMarket.h"
#import "JusikCompanyInfo.h"
#import "JusikStock.h"
#import "JusikStockFunction.h"
#import "JusikRecord.h"

NSString *JusikStockMarketNameKospi = @"com.jusikwang.stock_market.kospi";
NSString *JusikStockMarketNameDow = @"com.jusikwang.stock_market.dow";

@interface JusikStockMarket (Private)
- (void)_initObjects;

- (void)_setInitialDateWithYear: (NSUInteger)year month: (NSUInteger)month day: (NSUInteger)day;
- (void)_setInitialDate: (NSDate *)date;

- (void)_addStock: (JusikStock *)stock;
- (void)_removeStock: (JusikStock *)stock;

- (void)_processWaitingJusikEvents;
- (void)_calculateNextDayStockMarketPrice;
- (void)_prepareStocks;
- (void)_calculateNextPeriodOfStockPrices;
@end

@implementation JusikStockMarket
@synthesize combinedPrice = _combinedPrice;
@synthesize exchangeRate = _exchangeRate;
@synthesize USStockPrice = _USStockPrice;

@synthesize combinedPriceRecord = _combinedPriceRecord;
@synthesize exchangeRateRecord = _exchangeRateRecord;
@synthesize USStockPriceRecord = _USStockPriceRecord;

@synthesize currentDate = _currentDate;

@synthesize duration = _duration;
@synthesize period = _period;

@synthesize turn = _turn;
@synthesize openedCount = _openedCount;

#pragma mark - 초기화 메서드
- (id)init {
    return [self initWithInitialDateWithYear: 2011 month: 11 day: 11];
}

- (id)initWithInitialDateWithYear: (NSUInteger)year month: (NSUInteger)month day: (NSUInteger)day {
    self = [super init];
    if(self) {
        [self _initObjects];
        [self _setInitialDateWithYear: year month: month day: day];
        
        // 초기 환율은 1060원/1달러
        _exchangeRate = 1060;
        
        // 초기 코스피 주가 지수는 1920
        _combinedPrice = 1820;
        
        // 초기 미국 주가 지수는 11000
        _USStockPrice = 11000;
        
        // 지속 시간은 3분(180초)
        _duration = 180;
        
        // 주가는 한 턴당 총 18번 움직인다. 따라서 변화 시간은 10초
        _period = 10;
    }
    return self;
}

#pragma mark - 개장/폐장
- (void)open {
    if(_state == JusikStockMarketStateOpen) return;
    
    _openedCount++;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *weekday = [gregorian components: NSWeekdayCalendarUnit fromDate: _currentDate];
    
    NSDateComponents *comp = [NSDateComponents new];
    // 토요일/일요일은 개장하지 않으므로 금요일 다음으로 바로 월요일로 넘긴다.
    if(weekday.weekday >= 6) {
        comp.day = 3;
        _turn += 3;
    }
    else {
        comp.day = 1;
        _turn += 1;
    }
    
    NSDate *newDate = [[gregorian dateByAddingComponents: comp toDate: _currentDate options: 0] retain];
    
    if(_currentDate) {
        [_currentDate release];
        _currentDate = nil;
    }
    _currentDate = newDate;
    
    [_combinedPriceRecord setCurrentDate: _currentDate];
    [_USStockPriceRecord setCurrentDate: _currentDate];
    [_exchangeRateRecord setCurrentDate: _currentDate];
    
    [_combinedPriceRecord startRecording];
    [_USStockPriceRecord startRecording];
    [_exchangeRateRecord startRecording];
    
    [self _processWaitingJusikEvents];
    [self _calculateNextDayStockMarketPrice];
    [self _prepareStocks];
    
    // 대기중인 이벤트를 미리 적용시킨다.
    _state = JusikStockMarketStateOpen;
    NSLog(@"%s, turn:%d", __PRETTY_FUNCTION__, _turn);
}

- (void)close {
    if(_state == JusikStockMarketStateClose) return;
    
    [_combinedPriceRecord endRecording];
    [_USStockPriceRecord endRecording];
    [_exchangeRateRecord endRecording];
    
    [_stocks enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                     usingBlock: ^(NSString *key, JusikStock *stock, BOOL *stop)
     {
         [stock.record endRecording];
         stock.price = stock.record.endValue;
     }];
    
    _currentTime = 0;
    
    _state = JusikStockMarketStateClose;
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nextPeriod {
    if(_state == JusikStockMarketStateClose) return;
    
    _currentTime += self.period;
    if(_currentTime + 0.00001 >= _duration) {
        [self close];
    }
    else {
        [self _calculateNextPeriodOfStockPrices];
    }
    //NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - 기업 추가/삭제
- (void)addCompany: (JusikCompanyInfo *)info initialPrice: (double)price {
    if(info == nil) {
        NSLog(@"%s - 회사 정보가 nil입니다.", __PRETTY_FUNCTION__);
        return;
    }
    
    NSString *name = info.name;
    if([_stocks objectForKey: name] != nil) {
        NSLog(@"%s - (%@)이름을 가진 회사가 이미 존재합니다.", __PRETTY_FUNCTION__, name);
        return;
    }
    
    JusikStock *stock = [[JusikStock alloc] initWithCompanyInfo: info price: price];
    [self _addStock: stock];
    [stock release];
}

- (void)removeCompanyWithName: (NSString *)name {
    JusikStock *stock = [_stocks objectForKey: name];
    if(stock) {
        // doesn't do anything
    }
    else {
        NSLog(@"%s - 이름(%@)으로 회사를 찾을 수 없습니다.", __PRETTY_FUNCTION__, name);
        return;
    }
    
    [self _removeStock: stock];
}

- (void)removeCompanyWithIdentifier: (NSUInteger)identifier {
    __block JusikStock *stock = nil;
    [_stocks enumerateKeysAndObjectsUsingBlock: ^(NSString *key, JusikStock *s, BOOL *stop) {
        if(s.info.identifier == identifier) {
            stock = s;
            *stop = YES;
        }
    }];
    
    if(stock == nil) {
        NSLog(@"%s - 식별자(%d)로 회사를 찾을 수 없습니다.", __PRETTY_FUNCTION__, identifier);
        return;
    }
    
    [self _removeStock: stock];
}

#pragma mark -
- (JusikStock *)stockOfCompanyWithName: (NSString *)name {
    JusikStock *stock = [_stocks objectForKey: name];
    return stock;
}

#pragma mark - 주식 이벤트 처리
- (void)processJusikEvents:(NSArray *)events {
    /*
     주식 시장이 이미 개장된 상태라면
     입력된 모든 이벤트를 무시한다.
     */
    if(_state == JusikStockMarketStateOpen)
        return;
    
    [_waitingEvents addObjectsFromArray: events];
}

#pragma mark -
#pragma mark 비공개 메서드
- (void)_initObjects {
    if(_combinedPriceRecord == nil)
        _combinedPriceRecord = [[JusikRecord alloc] init];
    if(_USStockPriceRecord == nil)
        _USStockPriceRecord = [[JusikRecord alloc] init];
    if(_exchangeRateRecord == nil)
        _exchangeRateRecord = [[JusikRecord alloc] init];
    
    _combinedPriceRecord.startTime = 0;
    _combinedPriceRecord.period = 1.0;
    _combinedPriceRecord.hasEndValue = NO;
    
    _USStockPriceRecord.startTime = 0;
    _USStockPriceRecord.period = 1.0;
    _USStockPriceRecord.hasEndValue = NO;
    
    _exchangeRateRecord.startTime = 0;
    _exchangeRateRecord.period = 1.0;
    _exchangeRateRecord.hasEndValue = NO;
    
    if(_stocks == nil)
        _stocks = [NSMutableDictionary new];
    if(_stockFunctions == nil)
        _stockFunctions = [NSMutableDictionary new];
    
    _waitingEvents = [NSMutableArray new];
    _waitingStockMarketEvents = [NSMutableArray new];
}

- (void)_setInitialDateWithYear: (NSUInteger)year month: (NSUInteger)month day: (NSUInteger)day {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *comp = [NSDateComponents new];
    comp.year = year;
    comp.month = month;
    comp.day = day;
    comp.hour = 9;
    comp.minute = 0;
    comp.second = 0;
    NSDate *date = [[gregorian dateFromComponents: comp] retain];
    [gregorian release];
    
    [self _setInitialDate: date];
}

- (void)_setInitialDate: (NSDate *)date {
    _currentDate = date;
}

- (void)_addStock: (JusikStock *)stock {
    NSString *name = stock.info.name;
    [_stocks setObject: stock forKey: name];
    
    // 주식 함수 생성
    JusikStockFunction *stockFunction = [JusikStockFunction functionWithStock: stock];
    stockFunction.combinedPriceRecord = _combinedPriceRecord;
    stockFunction.exchangeRateRecord = _exchangeRateRecord;
    stockFunction.market = self;
    
    [_stockFunctions setObject: stockFunction forKey: name];
}

- (void)_removeStock:(JusikStock *)stock {
    NSString *name = stock.info.name;
    
    [_stocks removeObjectForKey: name];
    [_stockFunctions removeObjectForKey: name];
}

- (void)_processWaitingJusikEvents {
    NSMutableArray *reservedRemovingEvents = [NSMutableArray new];
    for(JusikEvent *e in _waitingEvents) {
        if(e.isEffective == NO) {
            if(self.turn >= e.startTurn)
                e.effective = YES;
        }
        
        if(e.isEffective) {
            switch(e.type) {
                case JusikEventTypeStockMarket:
                    [_waitingStockMarketEvents addObject: e];
                    break;
                case JusikEventTypeBusinessType:
                    [_stockFunctions enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                                             usingBlock: ^(id key, id obj, BOOL *stop)
                     {
                         JusikStockFunction *f = (JusikStockFunction *)obj;
                         JusikStock *stock = f.stock;
                         for(NSString *businessType in e.targets) {
                             if([stock.info.businessType.name isEqualToString: businessType]) {
                                 [f processJusikEvents: [NSArray arrayWithObject: e]];
                                 break;
                             }
                         }
                     }];
                    break;
                case JusikEventTypeCompany:
                    for(NSString *companyName in e.targets) {
                        JusikStockFunction *f = [_stockFunctions objectForKey: companyName];
                        [f processJusikEvents: [NSArray arrayWithObject: e]];
                    }
                    break;
            }
            e.remainingTurn--;
            if(e.remainingTurn < 1) {
                [reservedRemovingEvents addObject: e];
            }
        }
    }
    
    for(JusikEvent *e in reservedRemovingEvents)
        [_waitingEvents removeObject: e];
    [reservedRemovingEvents release];
}

- (void)_calculateNextDayStockMarketPrice {
    double combinedPriceOffset = 0.0;
    double exchangeRateOffset = 0.0;
    double USStockPriceOffset = 0.0;
    
    if(self.turn > 55) {
        NSLog(@"============");
    }
    
    // 처음 실행했을 때는 기본 값 그대로 간다.
    if(_openedCount > 1) {
        combinedPriceOffset = JusikGetRandomValue(-0.09, 0.09);
        exchangeRateOffset = JusikGetRandomValue(-0.05, 0.05);
        
        // 이벤트 처리
        for(JusikEvent *e in _waitingStockMarketEvents) {
            for(NSString *target in e.targets) {
                JusikRange r = e.change;
                double randomValue = (double)arc4random() / (double)ARC4RANDOM_MAX;
                double newOffset = randomValue * (r.e - r.s) + r.s;
                
                if([target isEqualToString: JusikStockMarketNameKospi]) {
                    switch(e.changeWay) {
                        case JusikEventChangeWayRateRelative:
                            combinedPriceOffset += newOffset;
                            break;
                        case JusikEventChangeWayRateAbsolute:
                            combinedPriceOffset = newOffset;
                            break;
                        case JusikEventChangeWayValueRelative:
                            _combinedPrice += newOffset;
                            break;
                        case JusikEventChangeWayValueAbsolute:
                            _combinedPrice = newOffset;
                            combinedPriceOffset = 0;
                            break;
                    }
                }
                else if([target isEqualToString: JusikStockMarketNameDow]) {
                    switch(e.changeWay) {
                        case JusikEventChangeWayRateRelative:
                            USStockPriceOffset += newOffset;
                            break;
                        case JusikEventChangeWayRateAbsolute:
                            USStockPriceOffset = newOffset;
                            break;
                        case JusikEventChangeWayValueRelative:
                            _USStockPrice += newOffset;
                            break;
                        case JusikEventChangeWayValueAbsolute:
                            _USStockPrice = newOffset;
                            USStockPriceOffset = 0;
                            break;
                    }
                }
            }
        }
        // 미국주가 -> 코스피 -> 환율로 차례대로 영향을 준다. 따라서
        // 영향을 준 이후의 값도 구해야 한다.
        combinedPriceOffset += USStockPriceOffset * 0.5;
        exchangeRateOffset -= combinedPriceOffset * 0.4;
        
        // 새 주가, 환율을 구한다.
        [self willChangeValueForKey: @"combinedPrice"];
        [self willChangeValueForKey: @"exchangeRate"];
        [self willChangeValueForKey: @"USStockPrice"];
        
        _combinedPrice = _combinedPrice * (1.0 + combinedPriceOffset);
        _exchangeRate = _exchangeRate * (1.0 + exchangeRateOffset);
        _USStockPrice = _USStockPrice * (1.0 + USStockPriceOffset);
        
        [self didChangeValueForKey: @"combinedPrice"];
        [self didChangeValueForKey: @"exchangeRate"];
        [self didChangeValueForKey: @"USStockPrice"];
        
        //NSLog(@"\n주가 : %.f\n미국 주가 : %.f\n환율 : %.2f원/달러", _combinedPrice, _USStockPrice, _exchangeRate);
    }
    
    [_combinedPriceRecord recordValue: _combinedPrice];
    [_exchangeRateRecord recordValue: _exchangeRate];
    [_USStockPriceRecord recordValue: _USStockPrice];
    
    [_waitingStockMarketEvents removeAllObjects];
}

- (void)_prepareStocks {
    void (^stockFunctionEnumerateBlock)(id, JusikStockFunction*, BOOL*) = 
    ^(id key, JusikStockFunction *f, BOOL *stop) {
        [f.stock.record setCurrentDate: _currentDate];
        [f setTurn: self.turn];
        [f calculateNextDayStockPrice];
    };
    [_stockFunctions enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                             usingBlock: stockFunctionEnumerateBlock];
}

- (void)_calculateNextPeriodOfStockPrices {
    double T = _currentTime / _duration;
    void (^stockFunctionEnumerateBlock)(id, JusikStockFunction*, BOOL*) = 
    ^(id key, JusikStockFunction *f, BOOL *stop) {
        [f calculateStockPriceOfT: T];
    };
    [_stockFunctions enumerateKeysAndObjectsWithOptions: NSEnumerationConcurrent
                                             usingBlock: stockFunctionEnumerateBlock];
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_stocks release];
    [_stockFunctions release];
    
    [_combinedPriceRecord release];
    [_USStockPriceRecord release];
    [_exchangeRateRecord release];
    
    [_currentDate release];
    
    [_waitingEvents release];
    [_waitingStockMarketEvents release];
    
    [super dealloc];
}

@end

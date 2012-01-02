//
//  JusikStockFunction.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 14..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikStockFunction.h"
#import "JusikStock.h"
#import "JusikStockDataType.h"
#import "JusikRecord.h"
#import "JusikCompanyInfo.h"
#import "JusikEvent.h"
#import "JusikStockMarket.h"

@interface JusikStockFunction (Private)
- (void)_addEventInWaitingEventQueue: (JusikEvent *)e;
- (double)_calculatedOpenPriceRate;
- (double)_calculatedClosedPriceRate;

- (void)_processWaitingStockFunctionEvents;
- (void)_processEvents;
@end

@implementation JusikStockFunction
@synthesize stock = _stock;
@synthesize combinedPriceRecord = _combinedPriceRecord;
@synthesize exchangeRateRecord = _exchangeRateRecord;
@synthesize turn = _turn;
@synthesize market = _market;

#pragma mark - 초기화 메서드
- (id)initWithStock: (JusikStock *)stock {
    return [self initWithStock: stock
           combinedPriceRecord: nil
            exchangeRateRecord: nil];
}

- (id)initWithStock: (JusikStock *)stock
combinedPriceRecord:(JusikRecord *)combinedPriceRecord 
 exchangeRateRecord:(JusikRecord *)exchangeRateRecord {
    self = [super init];
    if(self) {
        self.stock = stock;
        self.combinedPriceRecord = combinedPriceRecord;
        self.exchangeRateRecord = exchangeRateRecord;
        
        _events = [NSMutableArray new];
        _waitingStockFunctionEvents = [NSMutableArray new];
    }
    return self;
}

+ (id)functionWithStock: (JusikStock *)stock {
    return [[[self alloc] initWithStock: stock] autorelease];
}

+ (id)functionWithStock: (JusikStock *)stock
    combinedPriceRecord:(JusikRecord *)combinedPriceRecord 
     exchangeRateRecord:(JusikRecord *)exchangeRateRecord {
    return [[[self alloc] initWithStock: stock
                    combinedPriceRecord: combinedPriceRecord
                     exchangeRateRecord: exchangeRateRecord] autorelease];
}

#pragma mark - 프로퍼티 메서드
- (void)setStock:(JusikStock *)stock {
    [stock retain];
    [_stock release];
    _stock = stock;
}

#pragma mark - 이벤트 처리
- (void)addEventInWaitingEventQueue:(JusikEvent *)event {
    if([_waitingStockFunctionEvents containsObject: event]) return;
    
    [_waitingStockFunctionEvents addObject: event];
}

- (void)processJusikEvents:(NSArray *)events {
    for(JusikEvent *event in events) {
        if([_events containsObject: event]) return;
    
        [_events addObject: event];
    }
}

- (void)_processWaitingStockFunctionEvents {
    NSMutableArray *reservedRemovingEvents = [NSMutableArray new];
    
    for(JusikEvent *e in _waitingStockFunctionEvents) {
        if(e.isEffective == NO) {
            if(self.turn >= e.startTurn)
                e.effective = YES;
        }
        
        if(e.isEffective) {
            if([e.value isEqualToString: JusikEventValueCrossEffect]) {
                switch(e.changeWay) {
                    case JusikEventChangeWayRateRelative:
                    case JusikEventChangeWayValueRelative:
                        _G += JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                    case JusikEventChangeWayRateAbsolute:
                    case JusikEventChangeWayValueAbsolute:
                        _G = JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                }
            }
            else if([e.value isEqualToString: JusikEventValueArrangementEffect]) {
                switch(e.changeWay) {
                    case JusikEventChangeWayRateRelative:
                    case JusikEventChangeWayValueRelative:
                        _H += JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                    case JusikEventChangeWayRateAbsolute:
                    case JusikEventChangeWayValueAbsolute:
                        _H = JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                }
            }
            else if([e.value isEqualToString: JusikEventValueRSIEffect]) {
                switch(e.changeWay) {
                    case JusikEventChangeWayRateRelative:
                    case JusikEventChangeWayValueRelative:
                        _I += JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                    case JusikEventChangeWayRateAbsolute:
                    case JusikEventChangeWayValueAbsolute:
                        _I = JusikGetRandomValue(e.change.s, e.change.e);
                        break;
                }
            }
        }
        
        e.remainingTurn--;
        if(e.remainingTurn < 1) {
            if([reservedRemovingEvents containsObject: e] == NO)
                [reservedRemovingEvents addObject: e];
        }
    }

    for(JusikEvent *e in reservedRemovingEvents)
        [_waitingStockFunctionEvents removeObject: e];
    [reservedRemovingEvents release];
}

- (void)_processEvents {
    for(JusikEvent *e in _events) {
        if([e.value isEqualToString: JusikEventValuePrice] || e.value == nil) {
            switch(e.changeWay) {
                case JusikEventChangeWayRateRelative:
                    _J += JusikGetRandomValue(e.change.s, e.change.e);
                    break;
                case JusikEventChangeWayRateAbsolute:
                    _J = JusikGetRandomValue(e.change.s, e.change.e);
                    break;
                case JusikEventChangeWayValueRelative:
                    // 아무 일도 수행하지 않는다.
                    /*
                    _closingPrice += JusikGetRandomValue(e.change.s, e.change.e);
                     */
                    break;
                case JusikEventChangeWayValueAbsolute:
                    // 아무 일도 수행하지 않는다.
                    /*
                    _closingPrice = JusikGetRandomValue(e.change.s, e.change.e);
                    _J = 0;
                     */
                    break;
            }
        }
    }
        
    // 외부로부터 들어온 이벤트를 먼저 처리한다.
    [_events removeAllObjects];
}

#pragma mark - 함수 값 계산
- (void)calculateNextDayStockPrice {
    _x = 1.0;
    _y = 1.0;
    
    /*
     주식 영향 변수들
     순서대로
     
     A : 기업 크기별 코스피 지수 영향
     B : 원/달러 환율
     C : PER 영향
     D : ROE 영향
     E : BPS 영향
     F : PBR 영향
     G : 크로스 영향
     H : 배열 영향
     I : RSI 영향
     J : 이벤트 영향
     */
    _A = 0.0;
    _B = 0.0;
    _C = 0.0;
    _D = 0.0;
    _E = 0.0;
    _F = 0.0;
    _G = 0.0;
    _H = 0.0;
    _I = 0.0;
    _J = 0.0;
    
    double prevDayClosingPrice;
    
    _openingPrice = 0.0;
    _closingPrice = 0.0;
    
    JusikStock *stock = self.stock;
    JusikCompanyInfo *info = stock.info;
    JusikRecord *record = stock.record;
    
    NSUInteger count;
    
    // 코스피 지수 영향 계산
    count = self.combinedPriceRecord.records.count;
    if(count < 2)
        _A = 0.0;
    else {
        JusikDayRecord *prevDay = [self.combinedPriceRecord.records objectAtIndex: count - 2];
        JusikDayRecord *today = self.combinedPriceRecord.currentDayRecord;
        double prevCombinedPrice = prevDay.startValue;
        double currentCombinedPrice = today.startValue;
        double rate = currentCombinedPrice / prevCombinedPrice - 1.0;
        
        JusikCapitalStock c = info.capitalStock;
        JusikRange r;
        switch(c) {
            case JusikCapitalStockSmall:
                r.s = 0.005;
                r.e = 0.015;
                break;
            case JusikCapitalStockMedium:
                r.s = 0.01;
                r.e = 0.025;
                break;
            case JusikCapitalStockLarge:
                r.s = 0.02;
                r.e = 0.03;
                break;
        }
        _A = JusikGetRandomValue(r.s, r.e) * rate * 100.0;
    }
    
    // 원/달러 환율 계산
    count = self.exchangeRateRecord.records.count;
    if(count < 2)
        _B = 0.0;
    else {
        JusikDayRecord *prevDay = [self.combinedPriceRecord.records objectAtIndex: count - 2];
        JusikDayRecord *today = self.combinedPriceRecord.currentDayRecord;
        double prevCombinedPrice = prevDay.startValue;
        double currentCombinedPrice = today.startValue;
        double rate = currentCombinedPrice / prevCombinedPrice - 1.0;
        
        JusikBusinessType *b = info.businessType;
        double e = b.exchangeRateEffect;
        _B = e * rate * 100.0;
    }
    
    // PER 영향
    double EPS = info.EPS;
    if(EPS < 0.0)
        _C = -0.006;
    else {
        double bPER = info.businessType.PER;
        double PER = stock.PER;
        if(bPER > PER)
            _C = 0.006;
        else if(bPER < PER)
            _C = -0.01;
        else
            _C = -0.006;
    }
    
    // ROE 영향
    JusikRange ROE = stock.info.ROE;
    if(ROE.s > 0.0 && ROE.e > 0.0)
        _D = 0.002;
    else if(ROE.s < 0.0 && ROE.e < 0.0)
        _D = -0.006;
    else
        _D = 0.0;
    
    // BPS 영향
    double BPS = stock.info.BPS;
    if(stock.price * 0.85 <= BPS && BPS <= stock.price * 1.15)
        _E = 0.003;
    else
        _E = 0.0;
    
    // PBR 영향
    double PBR = stock.info.PBR;
    if(PBR < 1) {
        if(self.turn >= 120)
            _F = 0.005;
    }
    else if(PBR > 1) {
        if(self.turn >= 120)
            _F = -0.006;
    }
    
    // 크로스, 정배열/역배열 영향
    NSArray *fiveDay = [record fiveDayMovingAverageOfDays: 2];
    NSArray *twentyDay = [record twentyDayMovingAverageOfDays: 2];
    NSArray *thirtyFourDay = [record thirtyFourDayMovingAverageOfDays: 2];
    
    // 크로스 영향
    if(twentyDay != nil) {
        double fiveDayVal = [[fiveDay lastObject] doubleValue];
        double twentyDayVal = [[twentyDay lastObject] doubleValue];
        
        if(twentyDay.count > 1) {
            double prevFiveDayVal = [[fiveDay objectAtIndex: fiveDay.count - 2] doubleValue];
            double prevTwentyDayVal = [[twentyDay objectAtIndex: twentyDay.count - 2] doubleValue];
            
            // 골든 크로스
            if(prevFiveDayVal <= prevTwentyDayVal && fiveDayVal > twentyDayVal) {
                JusikEvent *e = [[JusikEvent alloc] init];
                e.type = JusikEventTypeCompany;
                e.targets = [NSArray arrayWithObject: self.stock.info.name];
                e.value = JusikEventValueCrossEffect;
                
                e.startTurn = self.turn;
                e.persistTurn = 7;
                e.change = JusikRangeMake(0.013, 0.013);
                e.changeWay = JusikEventChangeWayRateAbsolute;
                
                [self addEventInWaitingEventQueue: e];
                [e release];
            }
            // 데드 크로스
            else if(prevFiveDayVal >= prevTwentyDayVal && fiveDayVal < twentyDayVal) {
                JusikEvent *e = [[JusikEvent alloc] init];
                e.type = JusikEventTypeCompany;
                e.targets = [NSArray arrayWithObject: self.stock.info.name];
                e.value = JusikEventValueCrossEffect;
                
                e.startTurn = self.turn;
                e.persistTurn = 7;
                e.change = JusikRangeMake(-0.015, -0.015);
                e.changeWay = JusikEventChangeWayRateAbsolute;
                
                [self addEventInWaitingEventQueue: e];
                [e release];
            }
        }
    }
    
    // 정배열/역배열 영향
    if(thirtyFourDay != nil) {
        double fiveDayVal = [[fiveDay lastObject] doubleValue];
        double twentyDayVal = [[twentyDay lastObject] doubleValue];
        double thirtyFourDayVal = [[thirtyFourDay lastObject] doubleValue];
        
        if(fiveDayVal > twentyDayVal && twentyDayVal > thirtyFourDayVal) {
            JusikEvent *e = [[JusikEvent alloc] init];
            e.type = JusikEventTypeCompany;
            e.targets = [NSArray arrayWithObject: self.stock.info.name];
            e.value = JusikEventValueArrangementEffect;
            
            e.startTurn = self.turn;
            e.persistTurn = 10;
            e.change = JusikRangeMake(0.008, 0.008);
            e.changeWay = JusikEventChangeWayRateAbsolute;
            
            [self addEventInWaitingEventQueue: e];
            [e release];
        }
        else if(fiveDayVal < twentyDayVal && twentyDayVal < thirtyFourDayVal) {
            JusikEvent *e = [[JusikEvent alloc] init];
            e.type = JusikEventTypeCompany;
            e.targets = [NSArray arrayWithObject: self.stock.info.name];
            e.value = JusikEventValueArrangementEffect;
            
            e.startTurn = self.turn;
            e.persistTurn = 10;
            e.change = JusikRangeMake(-0.008, -0.008);
            e.changeWay = JusikEventChangeWayRateAbsolute;
            
            [self addEventInWaitingEventQueue: e];
            [e release];
        }
    }
    
    // RSI 영향
    if(record.records.count > 13) {
        double raise = 0.0, fall = 0.0;
        
        for(NSUInteger i = 0; i < 14; i++) {
            JusikDayRecord *d = [record.records objectAtIndex: record.records.count - 14 + i];
            double rate = (d.endValue / d.startValue) - 1.0;
            if(rate > 0) {
                raise += rate;
            }
            else {
                fall += rate;
            }
        }
        
        // RSI = 100 * 14일간 상승폭 합 / (14일간 상승폭 합 + 14일간 하락폭 합)
        double RSI = 100.0 * raise / (raise - fall);
        if(RSI < 30) {
            JusikEvent *e = [[JusikEvent alloc] init];
            e.type = JusikEventTypeCompany;
            e.targets = [NSArray arrayWithObject: self.stock.info.name];
            e.value = JusikEventValueRSIEffect;
            
            e.startTurn = self.turn + 1;
            e.persistTurn = 1;
            e.change = JusikRangeMake(0.013, 0.013);
            e.changeWay = JusikEventChangeWayRateAbsolute;
            
            [self addEventInWaitingEventQueue: e];
            [e release];
        }
        else if(RSI > 70) {
            JusikEvent *e = [[JusikEvent alloc] init];
            e.type = JusikEventTypeCompany;
            e.targets = [NSArray arrayWithObject: self.stock.info.name];
            e.value = JusikEventValueRSIEffect;
            
            e.startTurn = self.turn + 1;
            e.persistTurn = 1;
            e.change = JusikRangeMake(-0.023, -0.023);
            e.changeWay = JusikEventChangeWayRateAbsolute;
            
            [self addEventInWaitingEventQueue: e];
            [e release];
        }
    }
    
    // 크로스, 배열, RSI 영향으로 발생된 내부 이벤트를 처리한다.
    // G~I 변수는 여기서 처리한다.
    [self _processWaitingStockFunctionEvents];
    
    // 기업크기둔감, 환율민감함수, PBR영향 판별
    // 환율
    switch(info.sensitiveToExchangeRate) {
        case JusikSensitiveValueNormal:
            _y = 1.0;
            break;
        case JusikSensitiveValueSensitive:
            _y = 2.0;
            break;
        case JusikSensitiveValueInsensitive:
            _y = 0.5;
            break;
    }
    
    // 기업크기
    switch(info.sensitiveToBusinessScale) {
        case JusikSensitiveValueNormal:
            _x = 1.0;
            break;
        case JusikSensitiveValueSensitive:
            _x = 2.0;
            break;
        case JusikSensitiveValueInsensitive:
            _x = 0.5;
            break;
    }
    
    // PBR 무영향
    switch(info.sensitiveToPBR) {
        case JusikSensitiveValueInsensitive:
            _F = 0.0;
            break;
        default:
            break;
    }
    
    // 외부에서 온 이벤트를 여기서 처리.
    // J 변수는 여기서 산출한다.
    [self _processEvents];
    
    // 함수 값 계산
    count = record.records.count;
    if(count < 1) {
        _openingPrice = stock.price;
        _closingPrice = stock.price * [self _calculatedClosedPriceRate];
    }
    else {
        prevDayClosingPrice = [record currentDayRecord].endValue;
        _openingPrice = prevDayClosingPrice * [self _calculatedOpenPriceRate];
        _closingPrice = prevDayClosingPrice * [self _calculatedClosedPriceRate];
        
    }
    
    // 레코드에 기록한다.
    record.hasEndValue = YES;
    record.endValue = _closingPrice;
    [record startRecording];
    [record recordValue: _openingPrice];
    
    // 주가 지수 갱신.
    stock.price = _openingPrice;
}

/*- (void)calculateNextPeriodStockPrice {
    JusikRecord *record = self.stock.record;
    if(record.isRecording) {
        [record recordValue: record.currentDayRecord.startValue + 0.1];
    }
}
*/

- (void)calculateStockPriceOfT: (double)t {
    JusikRecord *record = self.stock.record;
    double value = record.currentDayRecord.startValue * (1.0 - t) + t * record.currentDayRecord.endValue;
    double newValue = 0.0;
    double prevValue = 0.0;
    double r = (double)arc4random() / (double)ARC4RANDOM_MAX;
    double s = 0.0; //(0~1)
    double offset = 0.0;
    if(r < 0.5) {
        s = 0.01;
    }
    else if(r < 0.75) {
        s = 0.02;
    }
    else if(r < 0.875) {
        s = 0.03;
    }
    else if(r < 0.9375) {
        s = 0.05;
    }
    else if(r < 0.96875) {
        s = 0.08;
    }
    else {
        s = 0.10;
    }
    
    r = (double)arc4random() / (double)ARC4RANDOM_MAX - 0.5;
    
    offset = value * r * s;
    newValue = value + offset;
    if(record.records.count < 2) {
        prevValue = record.currentDayRecord.startValue;
    }
    else {
        prevValue = [[record.records objectAtIndex: record.records.count - 2] endValue];
    }
    
    if(newValue < prevValue * 0.85)
        newValue = prevValue * 0.85;
    else if(newValue > prevValue * 1.15)
        newValue = prevValue * 1.15;
    
    if(record.isRecording) {
        [record recordValue: newValue];
    }
    _stock.price = newValue;
}

- (double)_calculatedOpenPriceRate {
    double val = (1.0 + _A) + _J;
    return val;
}

- (double)_calculatedClosedPriceRate {
    double val = pow(1.0+_A, _x) * pow(1.0+_B, _y) * (1.0+_C) * (1.0+_D) * (1.0+_E) * (1.0+_F) + _G + _H + _I + _J;
    NSLog(@"A=%.3f, B=%.3f, C=%.3f, D=%.3f, E=%.3f, F=%.3f, G=%.3f, H=%.3f, I=%.3f", _A, _B, _C, _D, _E, _F, _G, _H, _I);
    return val;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_stock release];
    [_combinedPriceRecord release];
    [_exchangeRateRecord release];
    
    [_events release];
    [_waitingStockFunctionEvents release];
    
    [super dealloc];
}

@end

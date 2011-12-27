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
- (void)addEventInEventQueue:(JusikEvent *)event {
    if([_events containsObject: event]) return;
    
    [_events addObject: event];
}

#pragma mark - 함수 값 계산
- (void)calculateNextDayStockPrice {
    double x = 1.0, y = 1.0;
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
    double A = 0.0, B = 0.0, C = 0.0, D = 0.0, E = 0.0, F = 0.0, G = 0.0, H = 0.0, I = 0.0, J = 0.0;
    
    double prevDayClosingPrice;
    double openingPrice;
    double closingPrice;
    
    JusikStock *stock = self.stock;
    JusikCompanyInfo *info = stock.info;
    JusikRecord *record = stock.record;
    
    NSUInteger count;
    
    // 코스피 지수 영향 계산
    count = self.combinedPriceRecord.records.count;
    if(count < 2)
        A = 0.0;
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
        A = r.s + (r.e - r.s) * (double)arc4random() / (double)ARC4RANDOM_MAX * rate * 100.0;
    }
    
    // 원/달러 환율 계산
    count = self.exchangeRateRecord.records.count;
    if(count < 2)
        B = 0.0;
    else {
        JusikDayRecord *prevDay = [self.combinedPriceRecord.records objectAtIndex: count - 2];
        JusikDayRecord *today = self.combinedPriceRecord.currentDayRecord;
        double prevCombinedPrice = prevDay.startValue;
        double currentCombinedPrice = today.startValue;
        double rate = currentCombinedPrice / prevCombinedPrice - 1.0;
        
        JusikBusinessType *b = info.businessType;
        double e = b.exchangeRateEffect;
        B = e * rate * 100.0;
    }
    
    // PER 영향
    double EPS = info.EPS;
    if(EPS < 0.0)
        C = 0.0;
    else {
        double bPER = info.businessType.PER;
        double PER = info.PER;
        if(bPER > PER)
            C = 0.02;
        else if(bPER < PER)
            C = -0.01;
        else
            C = 0.0;
    }
    
    // ROE 영향
    JusikRange ROE = stock.info.ROE;
    if(ROE.s > 0.0 && ROE.e > 0.0)
        D = 0.003;
    else if(ROE.s < 0.0 && ROE.e < 0.0)
        D = -0.006;
    else
        D = 0.0;
    
    // BPS 영향
    double BPS = stock.info.BPS;
    if(stock.price * 0.85 <= BPS && BPS <= stock.price * 1.15)
        E = 0.003;
    else
        E = 0.0;
    
    // PBR 영향
    double PBR = stock.info.PBR;
    if(PBR < 1) {
        F = 0.007;
    }
    else if(PBR > 1) {
        F = -0.007;
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
                
            }
        }
    }
    
    
    // 기업크기둔감, 환율민감함수, PBR영향 판별
    // 환율
    switch(info.sensitiveToExchangeRate) {
        case JusikSensitiveValueNormal:
            y = 1.0;
            break;
        case JusikSensitiveValueSensitive:
            y = 2.0;
            break;
        case JusikSensitiveValueInsensitive:
            y = 0.5;
            break;
    }
    
    // 기업크기
    switch(info.sensitiveToBusinessScale) {
        case JusikSensitiveValueNormal:
            x = 1.0;
            break;
        case JusikSensitiveValueSensitive:
            x = 2.0;
            break;
        case JusikSensitiveValueInsensitive:
            x = 0.5;
            break;
    }
    
    // PBR 무영향
    switch(info.sensitiveToPBR) {
        case JusikSensitiveValueInsensitive:
            F = 0.0;
            break;
        default:
            break;
    }
    
    // 함수 값 계산
    count = record.records.count;
    if(count < 1) {
        openingPrice = stock.price;
        closingPrice = stock.price * 
        (pow(1.0+A, x) * pow(1.0+B, y) * (1.0+C) * (1.0+D) * (1.0+E) * (1.0+F) + G + H + I + J);
    }
    else {
        prevDayClosingPrice = [record currentDayRecord].endValue;
        openingPrice = prevDayClosingPrice * ((1.0 + A) + J);
        closingPrice = prevDayClosingPrice * 
        (pow(1.0+A, x) * pow(1.0+B, y) * (1.0+C) * (1.0+D) * (1.0+E) * (1.0+F) + G + H + I + J);
        
    }
    record.hasEndValue = YES;
    record.endValue = closingPrice;
    [record startRecording];
    [record recordValue: openingPrice];
    
    stock.price = openingPrice;
    
    // 이벤트 큐의 모든 이벤트 제거
    [_events removeAllObjects];
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

#pragma mark - 메모리 해제
- (void)dealloc {
    [_stock release];
    [_combinedPriceRecord release];
    [_exchangeRateRecord release];
    
    [_events release];
    
    [super dealloc];
}

@end

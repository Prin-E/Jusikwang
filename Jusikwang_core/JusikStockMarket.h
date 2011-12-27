//
//  JusikStockMarket.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JusikEvent.h"

typedef enum {
    JusikStockMarketStateClose = 0,
    JusikStockMarketStateOpen = 1
} JusikStockMarketState;

@class JusikCompanyInfo;
@class JusikRecord;
@class JusikStockFunction;
@class JusikStock;
@interface JusikStockMarket : NSObject <JusikEventProcessing> {
    JusikRecord *_combinedPriceRecord;
    JusikRecord *_USStockPriceRecord;
    
    JusikRecord *_exchangeRateRecord;
    
    double _combinedPrice;  // 종합 주가 지수
    
    double _USStockPrice;   // 미국 주가 지수
    double _exchangeRate;   // 환율
    
    NSDate *_currentDate;   // 현재 날짜
    
    double _duration;       // 지속 시간
    double _period;         // 변화 시간
    double _currentTime;    // 현재 시간
    
    NSUInteger _turn;
    NSUInteger _openedCount;
    
    NSMutableDictionary *_stocks;
    NSMutableDictionary *_stockFunctions;
    
    JusikStockMarketState _state;   // 주식 시장 상태(개장, 폐장)
    
    NSMutableArray *_waitingEvents;
    NSMutableArray *_waitingStockMarketEvents;
}

@property (nonatomic, readonly) JusikRecord *combinedPriceRecord;
@property (nonatomic, readonly) JusikRecord *USStockPriceRecord;
@property (nonatomic, readonly) JusikRecord *exchangeRateRecord;

@property (nonatomic, readonly) double combinedPrice;
@property (nonatomic, readonly) double USStockPrice;
@property (nonatomic, readonly) double exchangeRate;

@property double duration;
@property double period;

@property (nonatomic, readonly) NSUInteger turn;
@property (nonatomic, readonly) NSUInteger openedCount;

@property (nonatomic, readonly) NSDate *currentDate;

- (id)initWithInitialDateWithYear: (NSUInteger)year month: (NSUInteger)month day: (NSUInteger)day;

- (void)open;
- (void)close;

- (void)nextPeriod;

- (void)addCompany: (JusikCompanyInfo *)info initialPrice: (double)price;
- (void)removeCompanyWithName: (NSString *)name;
- (void)removeCompanyWithIdentifier: (NSUInteger)identifier;

- (JusikStock *)stockOfCompanyWithName: (NSString *)name;

@end

extern NSString *JusikStockMarketNameKospi;
extern NSString *JusikStockMarketNameDow;
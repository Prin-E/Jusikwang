//
//  JusikStockFunction.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 14..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JusikEvent.h"

@class JusikStock;
@class JusikRecord;
@class JusikStockMarket;
@interface JusikStockFunction : NSObject <JusikEventProcessing> {
    JusikStock *_stock;
    
    NSMutableArray *_events;
    NSMutableArray *_waitingStockFunctionEvents;
    
    JusikRecord *_combinedPriceRecord;
    JusikRecord *_exchangeRateRecord;
    
    NSUInteger _turn;
    
    JusikStockMarket *_market;
    
    double _A, _B, _C, _D, _E, _F, _G, _H, _I, _J;
    double _x, _y;
    
    double _openingPrice;
    double _closingPrice;
}

@property (nonatomic, assign) JusikStockMarket *market;
@property (nonatomic, retain) JusikStock *stock;
@property (nonatomic, retain) JusikRecord *combinedPriceRecord;
@property (nonatomic, retain) JusikRecord *exchangeRateRecord;

@property NSUInteger turn;

- (id)initWithStock: (JusikStock *)stock;
- (id)initWithStock: (JusikStock *)stock
combinedPriceRecord: (JusikRecord *)combinedPriceRecord
 exchangeRateRecord: (JusikRecord *)exchangeRateRecord;

+ (id)functionWithStock: (JusikStock *)stock;

+ (id)functionWithStock: (JusikStock *)stock
    combinedPriceRecord: (JusikRecord *)combinedPriceRecord
     exchangeRateRecord: (JusikRecord *)exchangeRateRecord;

- (void)calculateNextDayStockPrice;
- (void)calculateStockPriceOfT: (double)t;
//- (void)calculateNextPeriodStockPrice;

@end

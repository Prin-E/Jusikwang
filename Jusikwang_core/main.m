//
//  main.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JusikCore.h"

int main (int argc, const char * argv[])
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    // 마켓 생성
    JusikStockMarket *market = [[JusikStockMarket alloc] initWithInitialDateWithYear: 2011 month: 11 day: 10];
    
    // 기업 생성
    JusikBusinessType *type;
    JusikCompanyInfo *info;
    
    // 안영희연구소
    type = [[JusikBusinessType alloc] initWithIdentifier: 12
                                                    name: @"com.jusikwang.business.software"
                                                     PER: 50.35
                                      exchangeRateEffect: 0.0];
    info = [[JusikCompanyInfo alloc] initWithIdentifier: 37
                                                   name: @"com.jusikwang.company.ahnlab"
                                           capitalStock: JusikCapitalStockMedium                                                             businessType: type
                                           detailedType: @"com.jusikwang.business.detailed.test"
                                                    EPS: 1444
                                                    ROE: JusikRangeMake(15.12, 12.46)
                                                    BPS: 14692
                                sensitiveToExchangeRate: JusikSensitiveValueInsensitive
                               sensitiveToBusinessScale: JusikSensitiveValueNormal
                                         sensitiveToPBR: JusikSensitiveValueNormal];
    
    [type release];
    //[market addCompany: info initialPrice: 19000];
    [info release];
    
    // 동어제약
    type = [[JusikBusinessType alloc] initWithIdentifier: 3
                                                    name: @"com.jusikwang.business.medicine_manufacture"
                                                     PER: 19.63
                                      exchangeRateEffect: -0.012];
    info = [[JusikCompanyInfo alloc] initWithIdentifier: 9
                                                   name: @"com.jusikwang.company.dongeo"
                                           capitalStock: JusikCapitalStockLarge                                                             businessType: type
                                           detailedType: @"com.jusikwang.business.detailed.test"
                                                    EPS: 6431
                                                    ROE: JusikRangeMake(13.6, 10.76)
                                                    BPS: 67011
                                sensitiveToExchangeRate: JusikSensitiveValueNormal
                               sensitiveToBusinessScale: JusikSensitiveValueNormal
                                         sensitiveToPBR: JusikSensitiveValueNormal];
    
    [type release];
    [market addCompany: info initialPrice: 102000];
    [info release];
    
    JusikStock *stock = [market stockOfCompanyWithName: @"com.jusikwang.company.dongeo"];
    
    // 이벤트
    JusikEvent *e = [[JusikEvent alloc] init];
    e.name = @"com.jusikwang.event.test";
    e.type = JusikEventTypeStockMarket;
    e.targets = [NSArray arrayWithObject: @"com.jusikwang.stock_market.dow"];
    e.change = JusikRangeMake(-0.02, 0.035);
    e.changeWay = JusikEventChangeWayRateAbsolute;
    e.startTurn = 1;
    e.persistTurn = 39;
    
    JusikEvent *e2 = [[JusikEvent alloc] init];
    e2.name = @"com.jusikwang.event.test2";
    e2.type = JusikEventTypeStockMarket;
    e2.targets = [NSArray arrayWithObject: @"com.jusikwang.stock_market.dow"];
    e2.change = JusikRangeMake(-0.055, 0.01);
    e2.changeWay = JusikEventChangeWayRateAbsolute;
    e2.startTurn = 56;
    e2.persistTurn = 11;
    
    JusikEvent *e3 = [[JusikEvent alloc] init];
    e3.name = @"com.jusikwang.event.test3";
    e3.type = JusikEventTypeStockMarket;
    e3.targets = [NSArray arrayWithObject: @"com.jusikwang.stock_market.dow"];
    e3.change = JusikRangeMake(-0.03, 0.03);
    e3.changeWay = JusikEventChangeWayRateAbsolute;
    e3.startTurn = 71;
    e3.persistTurn = 10;
    
    [market processJusikEvents: [NSArray arrayWithObjects: e, e2, e3, nil]];
    [e release];
    [e2 release];
    [e3 release];
    
    for(int j = 1; j <= 39; j++) {
        [market open];
        NSLog(@"initial : %.f", stock.price);
        
        for(int i = 1; i <= 18; i++) {
            [market nextPeriod];
            NSLog(@"%d : %.f", i, stock.price);
        }
        [market close];
    }
    for(int j = 1; j <= 11; j++) {
        [market open];
        NSLog(@"2initial : %.f", stock.price);
        
        for(int i = 1; i <= 18; i++) {
            [market nextPeriod];
            NSLog(@"%d : %.f", i, stock.price);
        }
        [market close];
    }
    for(int j = 1; j <= 10; j++) {
        [market open];
        NSLog(@"initial : %.f", stock.price);
        
        for(int i = 1; i <= 18; i++) {
            [market nextPeriod];
            NSLog(@"%d : %.f", i, stock.price);
        }
        [market close];
    }
    
    [market removeCompanyWithName: @"com.jusikwang.company.dongeo"];
    [market release];
    
    [pool release];
    
    return 0;
}


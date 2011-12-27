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
    JusikBusinessType *type = [[JusikBusinessType alloc] initWithIdentifier: 1
                                                                       name: @"com.jusikwang.business.test"
                                                                        PER: 9.06
                                                         exchangeRateEffect: 0.015];
    
    JusikCompanyInfo *info = [[JusikCompanyInfo alloc] initWithIdentifier: 1
                                                                     name: @"com.jusikwang.company.test"
                                                             capitalStock: JusikCapitalStockMedium
                                                             businessType: type
                                                             detailedType: @"com.jusikwang.business.detailed.test"
                                                                      EPS: 18450
                                                                      ROE: JusikRangeMake(14.6, 22.24)
                                                                      BPS: 990000
                                                  sensitiveToExchangeRate: JusikSensitiveValueNormal
                                                 sensitiveToBusinessScale: JusikSensitiveValueNormal
                                                           sensitiveToPBR: JusikSensitiveValueNormal];
    [type release];
    [market addCompany: info initialPrice: 180000];
    JusikStock *stock = [market stockOfCompanyWithName: @"com.jusikwang.company.test"];
    
    // 이벤트
    JusikEvent *e = [[JusikEvent alloc] init];
    e.name = @"com.jusikwang.event.test";
    e.type = JusikEventTypeStockMarket;
    e.targets = [NSArray arrayWithObject: @"com.jusikwang.stock_market.dow"];
    e.change = JusikRangeMake(-0.02, 0.04);
    e.changeWay = JusikEventChangeWayRateRelative;
    e.startTurn = 1;
    e.persistTurn = 1;
    
    [market processJusikEvents: [NSArray arrayWithObject: e]];
    [e release];
    
    for(int j = 1; j <= 40; j++) {
        [market open];
        NSLog(@"initial : %.f", stock.price);
    
        for(int i = 1; i <= 18; i++) {
            [market nextPeriod];
            NSLog(@"%d : %.f", i, stock.price);
        }
        [market close];
    }
    
    [pool release];
    
    return 0;
}


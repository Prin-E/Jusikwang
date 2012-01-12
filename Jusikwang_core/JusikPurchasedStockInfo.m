//
//  JusikPurchasedStockInfo.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 31..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikPurchasedStockInfo.h"

@implementation JusikPurchasedStockInfo
@synthesize stockName = _stockName;
@synthesize market = _market;
@synthesize count = _count;

- (id)copyWithZone:(NSZone *)zone {
    JusikPurchasedStockInfo *newInfo = [[JusikPurchasedStockInfo allocWithZone: zone] init];
    newInfo.stockName = _stockName;
    newInfo.market = _market;
    newInfo.count = _count;
    return newInfo;
}

- (void)dealloc {
    self.stockName = nil;
    self.market = nil;
    
    [super dealloc];
}

@end

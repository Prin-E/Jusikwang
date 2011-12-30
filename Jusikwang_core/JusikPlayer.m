//
//  JusikPlayer.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 31..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikPlayer.h"
#import "JusikStock.h"
#import "JusikStockMarket.h"
#import "JusikPurchasedStockInfo.h"
#import "JusikStockDataType.h"
#import "JusikCompanyInfo.h"

@implementation JusikPlayer
@synthesize name = _name;
@synthesize purchasedStockInfos = _purchasedStockInfos;
@synthesize money = _money;
@synthesize intelligence = _intelligence;
@synthesize fatigability = _fatigability;
@synthesize reliability = _reliability;

- (id)init {
    return [self initWithName: @"com.jusikwang.player.none"
                 initialMoney: 5000000 
                 intelligence: 0
                 fatigability: 0
                  reliability: 0];
}
- (id)initWithName: (NSString *)name
      initialMoney: (double)money
      intelligence: (double)intelligence
      fatigability: (double)fatigability
       reliability: (double)reliablity {
    self = [super init];
    if(self) {
        _name = [name copy];
        _purchasedStockInfos = [NSMutableDictionary new];
        _skills = [NSMutableDictionary new];
        
        _money = money;
        _intelligence = intelligence;
        _fatigability = fatigability;
        _reliability = reliablity;
    }
    return self;
}

- (BOOL)buyStockName: (NSString *)name fromMarket: (JusikStockMarket *)market count: (NSUInteger)count {
    JusikStock *stock = [market stockOfCompanyWithName: name];
    if(stock == nil)
        return NO;
    
    JusikPurchasedStockInfo *info = [_purchasedStockInfos objectForKey: stock.info.name];
    if(info == nil) {
        info = [[JusikPurchasedStockInfo alloc] init];
        [_purchasedStockInfos setObject: info forKey: stock.info.name];
        [info release];
        
        info.stockName = name;
        info.market = market;
    }
    info.count += count;
    
    // 수수료 제외한 금액 차감
    _money -= (stock.price * (1.0 + kJusikStockCommission)) * (double)count;
    
    return YES;
}

- (BOOL)sellStockName: (NSString *)name toMarket: (JusikStockMarket *)market count: (NSUInteger)count {
    JusikStock *stock = [market stockOfCompanyWithName: name];
    if(stock == nil)
        return NO;
    
    JusikPurchasedStockInfo *info = [_purchasedStockInfos objectForKey: stock.info.name];
    if(info == nil)
        return NO;
    
    info.count = ((info.count < count) ? 0 : info.count - count);
    if(info.count)
        [_purchasedStockInfos removeObjectForKey: stock.info.name];
    
    // 수수료 제외한 금액 증가
    _money += (stock.price * (1.0 - kJusikStockCommission)) * (double)count;
    return YES;
}

- (NSDictionary *)purchasedStockInfos {
    NSMutableDictionary *res = [NSMutableDictionary dictionary];
    NSEnumerator *e = [_purchasedStockInfos keyEnumerator];
    
    NSString *key = [e nextObject];
    while(key != nil) {
        JusikPurchasedStockInfo *info = [_purchasedStockInfos objectForKey: key];
        info = [info copy];
        [res setObject: info forKey: key];
        [info release];
        
        key = [e nextObject];
    }
    return res;
}

- (void)dealloc {
    [_name release];
    [_purchasedStockInfos release];
    [_skills release];
    
    [super dealloc];
}

@end

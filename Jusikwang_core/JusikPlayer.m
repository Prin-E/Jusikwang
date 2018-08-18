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

@implementation JusikPlayer {
    NSString *_name;
    
    NSMutableDictionary *_purchasedStockInfos;
    double _money;
    
    double _intelligence;
    double _fatigability;
    double _reliability;
    
    NSMutableArray *_skills;    // 스킬
    NSMutableArray *_favorites; // 즐겨찾기
    
    BOOL _callsAddFavoites;
    BOOL _callsRemoveFavorites;
}

@synthesize name = _name;
@synthesize purchasedStockInfos = _purchasedStockInfos;
@synthesize money = _money;
@synthesize intelligence = _intelligence;
@synthesize fatigability = _fatigability;
@synthesize reliability = _reliability;
@synthesize skills = _skills;
@synthesize favorites = _favorites;

#pragma mark - 초기화 메서드
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
        _skills = [NSMutableArray new];
        _favorites = [NSMutableArray new];
        
        _money = money;
        _intelligence = intelligence;
        _fatigability = fatigability;
        _reliability = reliablity;
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (NSArray *)skills {
    return [NSArray arrayWithArray: _skills];
}

- (NSArray *)favorites {
    return [NSArray arrayWithArray: _favorites];
}

- (double)intelligence {
    return _intelligence;
}

- (void)setIntelligence:(double)intelligence {
    if(intelligence < 0)
        intelligence = 0;
    _intelligence = intelligence;
}

- (double)reliability {
    return _reliability;
}

- (void)setReliability:(double)reliability {
    if(reliability < 0)
        reliability = 0;
    _reliability = reliability;
}

- (double)fatigability {
    return _fatigability;
}

- (void)setFatigability:(double)fatigability {
    if(fatigability < 0)
        fatigability = 0;
    _fatigability = fatigability;
}

#pragma mark - 주식 구입/매각
- (BOOL)buyStockName: (NSString *)name fromMarket: (JusikStockMarket *)market count: (NSUInteger)count {
    JusikStock *stock = [market stockOfCompanyWithName: name];
    if(stock == nil)
        return NO;
    
    // 자금보다 구입 비용이 많으면 구입 불가능
    if((stock.price * (1.0 + kJusikStockCommission)) * (double)count > _money)
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
    [self willChangeValueForKey: @"money"];
    _money -= (stock.price * (1.0 + kJusikStockCommission)) * (double)count;
    [self didChangeValueForKey: @"money"];
    
    return YES;
}

- (BOOL)sellStockName: (NSString *)name toMarket: (JusikStockMarket *)market count: (NSUInteger)count {
    JusikStock *stock = [market stockOfCompanyWithName: name];
    if(stock == nil)
        return NO;
    
    JusikPurchasedStockInfo *info = [_purchasedStockInfos objectForKey: stock.info.name];
    if(info == nil)
        return NO;
    
    NSUInteger actualCount = ((info.count < count) ? info.count : count);
    info.count -= actualCount;
    if(info.count < 1)
        [_purchasedStockInfos removeObjectForKey: stock.info.name];
    
    // 수수료 제외한 금액 증가
    [self willChangeValueForKey: @"money"];
    _money += (stock.price * (1.0 - kJusikStockCommission)) * (double)actualCount;
    [self didChangeValueForKey: @"money"];
    return YES;
}

#pragma mark 주식 정보
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

#pragma mark - 스킬/즐겨찾기
- (void)addSkill: (NSString *)skill {
    [self willChangeValueForKey: @"skills"];
    if(skill != nil)
        [_skills addObject: skill];
    [self didChangeValueForKey: @"skills"];
}

- (void)removeSkill: (NSString *)skill {
    [self willChangeValueForKey: @"skills"];
    if(skill != nil)
        [_skills removeObject: skill];
    [self didChangeValueForKey: @"skills"];
    
}

- (BOOL)hasSkill: (NSString *)skill {
    return [_skills containsObject: skill];
}

- (void)addFavorite:(NSString *)companyName {
    // 요렇게 한 이유는 중복 호출을 방지하려고.
    if(_callsAddFavoites) {
        [self willChangeValueForKey: @"favorites"];
    }
    
    if(companyName != nil && [_favorites containsObject: companyName] == NO)
        [_favorites addObject: companyName];
    
    if(_callsAddFavoites) {
        [self didChangeValueForKey: @"favorites"];
    }
}

- (void)addFavorites:(NSSet *)objects {
    _callsAddFavoites = YES;
    
    [self willChangeValueForKey: @"favorites"];
    
    for(NSString *companyName in objects) {
        [self addFavorite: companyName];
    }
    
    [self didChangeValueForKey: @"favorites"];
    
    _callsAddFavoites = NO;
}

- (void)removeFavorite: (NSString *)companyName {
    if(_callsRemoveFavorites) {
        [self willChangeValueForKey: @"favorites"];
    }
    
    if(companyName != nil && [_favorites containsObject: companyName] == YES)
        [_favorites removeObject: companyName];
    
    if(_callsRemoveFavorites) {
        [self didChangeValueForKey: @"favorites"];
    }
}

- (void)removeFavorites:(NSSet *)objects {
    _callsRemoveFavorites = YES;
    
    [self willChangeValueForKey: @"favorites"];
    
    for(NSString *companyName in objects) {
        [self removeFavorite: companyName];
    }
    
    [self didChangeValueForKey: @"favorites"];
    
    _callsRemoveFavorites = NO;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_name release];
    [_purchasedStockInfos release];
    [_skills release];
    [_favorites release];
    
    [super dealloc];
}

@end

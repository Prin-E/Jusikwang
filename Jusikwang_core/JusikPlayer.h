//
//  JusikPlayer.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 31..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JusikPurchasedStockInfo;
@class JusikStockMarket;
@class JusikSkill;
@interface JusikPlayer : NSObject {
    NSString *_name;
    
    NSMutableDictionary *_purchasedStockInfos;
    double _money;
    
    double _intelligence;
    double _fatigability;
    double _reliability;
    
    NSMutableDictionary *_skills;
}
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSDictionary *purchasedStockInfos;

@property (nonatomic, readonly) double money;
@property (nonatomic, readwrite) double intelligence;
@property (nonatomic, readwrite) double fatigability;
@property (nonatomic, readwrite) double reliability;

- (id)initWithName: (NSString *)name
      initialMoney: (double)money
      intelligence: (double)intelligence
      fatigability: (double)fatigability
       reliability: (double)reliablity;

- (BOOL)buyStockName: (NSString *)name fromMarket: (JusikStockMarket *)market count: (NSUInteger)count;
- (BOOL)sellStockName: (NSString *)name toMarket: (JusikStockMarket *)market count: (NSUInteger)count;

/*
- (void)addSkill: (JusikSkill *)skill;
- (JusikSkill *)skillWithName: (NSString *)name;
- (BOOL)hasSkill: (NSString *)name;
*/

@end

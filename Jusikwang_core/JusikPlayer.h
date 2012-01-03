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
@interface JusikPlayer : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSDictionary *purchasedStockInfos;

@property (nonatomic, readonly) double money;
@property (nonatomic, readwrite) double intelligence;
@property (nonatomic, readwrite) double fatigability;
@property (nonatomic, readwrite) double reliability;

@property (nonatomic, readonly) NSArray *skills;
@property (nonatomic, readonly) NSArray *favorites;

- (id)initWithName: (NSString *)name
      initialMoney: (double)money
      intelligence: (double)intelligence
      fatigability: (double)fatigability
       reliability: (double)reliablity;

- (BOOL)buyStockName: (NSString *)name fromMarket: (JusikStockMarket *)market count: (NSUInteger)count;
- (BOOL)sellStockName: (NSString *)name toMarket: (JusikStockMarket *)market count: (NSUInteger)count;

- (void)addSkill: (NSString *)skill;
- (void)removeSkill: (NSString *)skill;
- (BOOL)hasSkill: (NSString *)skill;

- (void)addCompanyNameToFavorites: (NSString *)company;
- (void)removeCompanyNameFromFavorites: (NSString *)company;


@end

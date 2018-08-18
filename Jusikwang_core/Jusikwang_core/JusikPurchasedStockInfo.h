//
//  JusikPurchasedStockInfo.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 31..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JusikStockMarket;
@interface JusikPurchasedStockInfo : NSObject <NSCopying> {
    NSString *_stockName;
    JusikStockMarket *_market;
    
    NSUInteger _count;
}
@property (nonatomic, copy) NSString *stockName;
@property (nonatomic, assign) JusikStockMarket *market;
@property (nonatomic, readwrite) NSUInteger count;

@end

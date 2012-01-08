//
//  JusikDBManager.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 6..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JusikLoadingViewController;
@interface JusikDBManager : NSObject

@property (nonatomic, assign) JusikLoadingViewController *loadingViewController;

- (id)initWithDBNamed: (NSString *)dbName;
- (void)query: (NSString *)query;
- (void)selectTable: (NSString *)tableName;
- (NSUInteger)numberOfRowsOfTable: (NSString *)tableName;
- (BOOL)nextRow;
- (NSInteger)integerColumnOfCurrentRowAtIndex: (NSUInteger)idx;
- (NSString *)stringColumnOfCurrentRowAtIndex: (NSUInteger)idx;
- (double)doubleColumnOfCurrentRowAtIndex: (NSUInteger)idx;

@end

extern NSString *kJusikDBDefaultName;
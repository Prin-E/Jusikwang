//
//  JusikDBManager.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 6..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikDBManager.h"
#import "JusikLoadingViewController.h"
#import "/usr/include/sqlite3.h"

NSString *kJusikDBDefaultName = @"game.db";

@implementation JusikDBManager {
    sqlite3 *_gameDB;
    sqlite3_stmt *_stmt;
}
@synthesize loadingViewController = _loadingViewController;

- (id)initWithDBNamed:(NSString *)dbName {
    self = [super init];
    if(self) {
        _gameDB = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource: @"game" ofType: @"db" inDirectory: @"DB"];
        if([dbName isEqualToString: kJusikDBDefaultName]) {
        }
        else {
            NSFileManager *fm = [[NSFileManager alloc] init];
            NSArray *a = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *destPath = [a objectAtIndex: 0];
            destPath = [destPath stringByAppendingFormat: dbName];
            
            if([fm fileExistsAtPath: destPath])
                [fm removeItemAtPath: destPath error: nil];
            [fm copyItemAtPath: path toPath: destPath error: nil];
            
            path = destPath;
            [fm release];
        }
        sqlite3_open_v2([path UTF8String], &_gameDB, SQLITE_READONLY, NULL);
    }
    return self;
}

- (void)query:(NSString *)query {
    if(_stmt) {
        sqlite3_finalize(_stmt);
        _stmt = nil;
    }
    
    const char *pzTail;
    const char *sql = [query UTF8String];
    
    sqlite3_prepare_v2(_gameDB, sql, strlen(sql)+1, &_stmt, &pzTail);
}

- (void)selectTable: (NSString *)tableName {
    NSString *query = [NSString stringWithFormat: @"select * from %@;", tableName];
    [self query: query];
}

- (BOOL)nextRow {
    if(_stmt) {
        int val = sqlite3_step(_stmt);
        if(val != SQLITE_ROW) {
            sqlite3_finalize(_stmt);
            _stmt = nil;
            return NO;
        }
        return YES;
    }
    return NO;
}

- (NSUInteger)numberOfRowsOfTable:(NSString *)tableName {
    NSString *query = [NSString stringWithFormat: @"select count(*) from %@;", tableName];
    [self query: query];
    
    [self nextRow];
    NSUInteger count = [self integerColumnOfCurrentRowAtIndex: 0];
    return count;
}

- (NSInteger)integerColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    sqlite3_int64 val = sqlite3_column_int64(_stmt, idx);
    return (NSUInteger)val;
}

- (NSString *)stringColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    const unsigned char *string = sqlite3_column_text(_stmt, idx);
    NSString *str = [NSString stringWithUTF8String: (const char *)string];
    return str;
}

- (double)doubleColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    double val = sqlite3_column_double(_stmt, idx);
    return val;
}

- (void)dealloc {
    sqlite3_close(_gameDB);
    [super dealloc];
}

@end

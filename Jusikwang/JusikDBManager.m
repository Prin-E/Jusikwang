//
//  JusikDBManager.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 6..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikDBManager.h"
#import <sqlite3.h>

NSString *kJusikDBDefaultName = @"game.db";

@implementation JusikDBManager {
    sqlite3 *_gameDB;
    sqlite3_stmt *_stmt;
}

#pragma mark - 초기화 메서드
- (id)init {
    return [self initWithDBNamed: kJusikDBDefaultName];
}

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
        int ret = sqlite3_open_v2([path UTF8String], &_gameDB, SQLITE_OPEN_READWRITE, NULL);
        NSLog(@"%s -> ret : %d", __PRETTY_FUNCTION__, ret);
    }
    return self;
}

#pragma mark - 쿼리
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

#pragma mark - 현재 행에서 데이터 얻기
- (NSInteger)integerColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    sqlite3_int64 val = sqlite3_column_int64(_stmt, idx);
    return (NSUInteger)val;
}

- (NSString *)stringColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    const unsigned char *string = sqlite3_column_text(_stmt, idx);
    if(string) {
        NSString *str = [NSString stringWithUTF8String: (const char *)string];
        return str;
    }
    else
        return nil;
}

- (const void *)byteColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    const void *byte = sqlite3_column_blob(_stmt, idx);
    if(byte) {
        return byte;
    }
    else
        return nil;
}

- (double)doubleColumnOfCurrentRowAtIndex: (NSUInteger)idx {
    double val = sqlite3_column_double(_stmt, idx);
    return val;
}

- (NSDictionary *)rowData {
    if(_stmt == nil) return nil;
    
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    NSUInteger count = sqlite3_column_count(_stmt);
    for(NSUInteger i = 0; i < count; i++) {
        const char *columnName = sqlite3_column_name(_stmt, i);
        NSString *key = [NSString stringWithUTF8String: columnName];
        id object;
        
        switch(sqlite3_column_type(_stmt, i)) {
            case SQLITE_TEXT: {
                const unsigned char *val = sqlite3_column_text(_stmt, i);
                NSString *valStr;
                if(val) {
                    valStr = [NSString stringWithUTF8String: (const char *)val];
                    object = valStr;
                }
                else {
                    object = nil;
                }
                break;
            }
            case SQLITE_INTEGER: {
                sqlite3_int64 val = sqlite3_column_int64(_stmt, i);
                NSNumber *valNum = [NSNumber numberWithInteger: (NSInteger)val];
                object = valNum;
                break;
            }
            case SQLITE_FLOAT: {
                double val = sqlite3_column_double(_stmt, i);
                NSNumber *valNum = [NSNumber numberWithDouble: val];
                object = valNum;
                break;
            }
            case SQLITE_BLOB: {
                const void *val = sqlite3_column_blob(_stmt, i);
                if(val) {
                    NSValue *valVal = [NSValue valueWithPointer: val];
                    object = valVal;
                }
                else {
                    object = nil;
                }
                break;
            }
            default:
                object = nil;
                break;
        }
        // 기록
        if(object)
            [d setObject: object forKey: key];
    }
    return [NSDictionary dictionaryWithDictionary: d];
}

#pragma mark - 메모리 해제
- (void)dealloc {
    if(_stmt) {
        sqlite3_finalize(_stmt);
        _stmt = nil;
    }
    sqlite3_close(_gameDB);
    [super dealloc];
}

@end

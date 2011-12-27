//
//  JusikStockDataType.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#define ARC4RANDOM_MAX      0x100000000

typedef struct {
    union {
        double start;
        double end;
    };
    union {
        double s;
        double e;
    };
} JusikRange;

typedef enum {
    JusikCapitalStockSmall = 1,
    JusikCapitalStockMedium = 2,
    JusikCapitalStockLarge = 3
} JusikCapitalStock;

typedef enum {
    JusikEventTypeStockMarket = 1,
    JusikEventTypeBusinessType = 2,
    JusikEventTypeCompany = 3
} JusikEventType;

typedef enum {
    JusikSensitiveValueInsensitive = -1,
    JusikSensitiveValueNormal = 0,
    JusikSensitiveValueSensitive = 1
} JusikSensitiveValue;

extern inline JusikRange JusikRangeMake(double s, double e);
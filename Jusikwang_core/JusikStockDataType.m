//
//  JusikStockDataType.c
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 27..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//
#import "JusikStockDataType.h"

inline JusikRange JusikRangeMake(double s, double e) {
    JusikRange r;
    r.s = s;
    r.e = e;
    return r;
}
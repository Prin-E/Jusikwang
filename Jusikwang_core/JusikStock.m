//
//  JusikStock.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 12..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikStock.h"
#import "JusikCompanyInfo.h"
#import "JusikStockFunction.h"
#import "JusikRecord.h"

@implementation JusikStock
@synthesize record = _record;
@synthesize info = _info;
@synthesize price = _price;

- (id)initWithCompanyInfo:(JusikCompanyInfo *)info price:(double)price {
    self = [super init];
    if(self) {
        _info = [info retain];
        _price = price;
        
        _record = [[JusikRecord alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_info release];
    [_record release];
    [super dealloc];
}

@end

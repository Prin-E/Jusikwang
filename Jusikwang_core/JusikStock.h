//
//  JusikStock.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 12..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JusikCompanyInfo;
@class JusikRecord;
@interface JusikStock : NSObject {
    JusikCompanyInfo *_info;
    double _price;
    
    JusikRecord *_record;
}

@property (readonly) double PER;

@property (nonatomic, readonly) JusikRecord *record;
@property (nonatomic, readonly) JusikCompanyInfo *info;
@property (readwrite) double price;

- (id)initWithCompanyInfo: (JusikCompanyInfo *)info price: (double)price;

@end
//
//  JusikCompanyInfo.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JusikBusinessType.h"
#import "JusikStockDataType.h"

@interface JusikCompanyInfo : NSObject {
    @private
    NSUInteger _identifier;
    NSString *_name;
    
    JusikCapitalStock _capitalStock;
    JusikBusinessType *_businessType;
    NSString *_detailedType;
    
    double _EPS;
    JusikRange _ROE;
    double _BPS;
    
    JusikSensitiveValue _sensitiveToExchangeRate;
    JusikSensitiveValue _sensitiveToBusinessScale;
    JusikSensitiveValue _sensitiveToPBR;
}
@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) JusikCapitalStock capitalStock;
@property (nonatomic, readonly) JusikBusinessType *businessType;
@property (nonatomic, readonly) NSString *detailedType;
@property (nonatomic, readonly) double EPS;
@property (nonatomic, readonly) double PER;
@property (nonatomic, readonly) JusikRange ROE;
@property (nonatomic, readonly) double BPS;
@property (nonatomic, readonly) double PBR;

@property (nonatomic, readonly) JusikSensitiveValue sensitiveToExchangeRate;
@property (nonatomic, readonly) JusikSensitiveValue sensitiveToBusinessScale;
@property (nonatomic, readonly) JusikSensitiveValue sensitiveToPBR;

- (id)initWithIdentifier: (NSUInteger)identifier
                    name: (NSString *)name
            capitalStock: (JusikCapitalStock)capitalStock
            businessType: (JusikBusinessType *)businessType
            detailedType: (NSString *)detailedType
                     EPS: (double)EPS
                     ROE: (JusikRange) ROE
                     BPS: (double)BPS
 sensitiveToExchangeRate: (JusikSensitiveValue)sensitiveToExchangeRate
sensitiveToBusinessScale: (JusikSensitiveValue)sensitiveToBusinessScale
          sensitiveToPBR: (JusikSensitiveValue)sensitiveToPBR;

@end

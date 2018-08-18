//
//  JusikCompanyInfo.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikCompanyInfo.h"

@implementation JusikCompanyInfo
@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize capitalStock = _capitalStock;
@synthesize businessType = _businessType;
@synthesize detailedType = _detailedType;
@synthesize ROE = _ROE;
@synthesize EPS = _EPS;
@synthesize BPS = _BPS;
@synthesize sensitiveToExchangeRate = _sensitiveToExchangeRate;
@synthesize sensitiveToBusinessScale = _sensitiveToBusinessScale;
@synthesize sensitiveToPBR = _sensitiveToPBR;

- (double)PER {
    if(self.EPS == 0)
        return 1000.0f;
    return 1.0 / self.EPS;
}

- (double)PBR {
    if(self.BPS == 0)
        return 1000.0f;
    return 1.0 / self.BPS;
}

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
          sensitiveToPBR: (JusikSensitiveValue)sensitiveToPBR {
    self = [super init];
    if(self) {
        _identifier = identifier;
        _name = [name retain];
        _capitalStock = capitalStock;
        
        _businessType = [businessType retain];
        _detailedType = [detailedType retain];
        
        _EPS = EPS;
        _ROE = ROE;
        _BPS = BPS;
        
        _sensitiveToExchangeRate = sensitiveToExchangeRate;
        _sensitiveToBusinessScale = sensitiveToBusinessScale;
        _sensitiveToPBR = sensitiveToPBR;
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_businessType release];
    [_detailedType release];
    
    [super dealloc];
}

@end

//
//  JusikBusinessType.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikBusinessType.h"

NSString *JusikBusinessTypeNameCar = @"com.jusikwang.business.car";
NSString *JusikBusinessTypeNameMarine = @"com.jusikwang.business.marine";
NSString *JusikBusinessTypeNameMedicineManufacture = @"com.jusikwang.business.medicine_manufacture";
NSString *JusikBusinessTypeNameShipbuilding = @"com.jusikwang.business.shipbuilding";
NSString *JusikBusinessTypeNameShipping = @"com.jusikwang.business.shipping";
NSString *JusikBusinessTypeNameSteel = @"com.jusikwang.business.steel";
NSString *JusikBusinessTypeNameBank = @"com.jusikwang.business.bank";
NSString *JusikBusinessTypeNameShare = @"com.jusikwang.business.share";
NSString *JusikBusinessTypeNameOil = @"com.jusikwang.business.oil";
NSString *JusikBusinessTypeNameChemistry = @"com.jusikwang.business.chemistry";
NSString *JusikBusinessTypeNameElectricity = @"com.jusikwang.business.electricity";
NSString *JusikBusinessTypeNameSoftware = @"com.jusikwang.business.software";
NSString *JusikBusinessTypeNameFlight = @"com.jusikwang.business.flight";
NSString *JusikBusinessTypeNameEducation = @"com.jusikwang.business.education";
NSString *JusikBusinessTypeNameAlternativeEnergy = @"com.jusikwang.business.alternative_energy";

@implementation JusikBusinessType 
@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize PER = _PER;
@synthesize exchangeRateEffect = _exchangeRateEffect;

- (id)initWithIdentifier: (NSUInteger)identifier
                    name: (NSString *)name
                     PER: (double)PER
      exchangeRateEffect: (double)exchangeRateEffect {
    self = [super init];
    if(self) {
        _identifier = identifier;
        _name = [name retain];
        _PER = PER;
        _exchangeRateEffect = exchangeRateEffect;
    }
    return self;
}

+ (id)typeWithIdentifier: (NSUInteger)identifier
                    name: (NSString *)name 
                     PER: (double)PER 
      exchangeRateEffect: (double)exchangeRateEffect {
    JusikBusinessType *type = [[JusikBusinessType alloc] initWithIdentifier: identifier
                                                                       name: name
                                                                        PER: PER
                                                         exchangeRateEffect: exchangeRateEffect];
    
    return [type autorelease];
}

- (BOOL)isEqual:(id)object {
    JusikBusinessType *type = object;
    if(self.identifier != type.identifier)
        return NO;
    if([self.name isEqualToString: type.name] == NO)
        return NO;
    if(self.PER != type.PER)
        return NO;
    if(self.exchangeRateEffect != type.exchangeRateEffect)
        return NO;
    return YES;
}

- (void)dealloc {
    [_name release];
    [super dealloc];
}

@end

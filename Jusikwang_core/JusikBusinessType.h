//
//  JusikBusinessType.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 11..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JusikBusinessType : NSObject {
    @private
    NSUInteger _identifier;
    NSString *_name;
    double _PER;
    double _exchangeRateEffect;
}
@property (nonatomic, readonly) NSUInteger identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) double PER;
@property (nonatomic, readonly) double exchangeRateEffect;

/*
+ (JusikBusinessType *)carType;
+ (JusikBusinessType *)marineProductType;
+ (JusikBusinessType *)medicineManufactureType;
+ (JusikBusinessType *)shipbuildingType;
+ (JusikBusinessType *)shippingType;
+ (JusikBusinessType *)steelType;
+ (JusikBusinessType *)bankType;
+ (JusikBusinessType *)shareType;
+ (JusikBusinessType *)oilType;
+ (JusikBusinessType *)chemistryType;
+ (JusikBusinessType *)electronicsType;
+ (JusikBusinessType *)softwareType;
+ (JusikBusinessType *)flightType;
+ (JusikBusinessType *)educationType;
+ (JusikBusinessType *)alternativeEnergyType;
*/

- (id)initWithIdentifier: (NSUInteger)identifier
                    name: (NSString *)name
                     PER: (double)PER
      exchangeRateEffect: (double)exchangeRateEffect;

+ (id)typeWithIdentifier: (NSUInteger)identifier
                    name: (NSString *)name 
                     PER: (double)PER
      exchangeRateEffect: (double)exchangeRateEffect;
@end

extern NSString *JusikBusinessTypeNameCar;
extern NSString *JusikBusinessTypeNameMarine;
extern NSString *JusikBusinessTypeNameMedicineManufacture;
extern NSString *JusikBusinessTypeNameShipbuilding;
extern NSString *JusikBusinessTypeNameShipping;
extern NSString *JusikBusinessTypeNameSteel;
extern NSString *JusikBusinessTypeNameBank;
extern NSString *JusikBusinessTypeNameShare;
extern NSString *JusikBusinessTypeNameOil;
extern NSString *JusikBusinessTypeNameChemistry;
extern NSString *JusikBusinessTypeNameElectricity;
extern NSString *JusikBusinessTypeNameSoftware;
extern NSString *JusikBusinessTypeNameFlight;
extern NSString *JusikBusinessTypeNameEducation;
extern NSString *JusikBusinessTypeNameAlternativeEnergy;
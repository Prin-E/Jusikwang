//
//  JusikDBManager+Extension.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 21..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikDBManager+Extension.h"
#import "JusikScript.h"
#import "JusikPlayer.h"
#import "JusikBusinessType.h"
#import "JusikActivityObject.h"

NSString * const kJusikTableNameScriptSpeech = @"script_speech";
NSString * const kJusikTableNameBusinessType = @"business_type";
NSString * const kJusikTableNameActivityHomeObject = @"activity_home_object";

NSString * const kJusikTableNameScriptHomeAnalysisCompanyFailed = @"script_home_analysis_company_fail";
NSString * const kJusikTableNameScriptHomeAnalysisCompanyStudy = @"script_home_analysis_company_study";
NSString * const kJusikTableNameScriptHomeAnalysisCompanyMore = @"script_home_analysis_company_more";
NSString * const kJusikTableNameScriptHomeAnalysisChartFailed = @"script_home_analysis_chart_fail";
NSString * const kJusikTableNameScriptHomeAnalysisChartStudy = @"script_home_analysis_chart_study";
NSString * const kJusikTableNameScriptHomeAnalysisChartMore = @"script_home_analysis_chart_more";
NSString * const kJusikTableNameScriptHomeStudy = @"script_home_study";
NSString * const kJusikTableNameScriptHomeBed = @"script_home_bed";

@implementation JusikDBManager (Extension)

- (JusikScript *)scriptWithID:(NSUInteger)uid {
    [self query: [NSString stringWithFormat: @"select * from %@ where uid=%d order by speech_num asc", kJusikTableNameScriptSpeech, uid]];
    
    JusikScript *script = [[[JusikScript alloc] init] autorelease];
    NSMutableArray *speeches = [NSMutableArray array];
    while([self nextRow]) {
        JusikSpeech *speech = [[JusikSpeech alloc] init];
        NSDictionary *d = [self rowData];
        
        speech.who = [d objectForKey: @"who"];
        speech.speech = [d objectForKey: @"speech"];
        speech.standingImageName = [d objectForKey: @"standing_image_name"];
        
        id obj = [d objectForKey: @"position"];
        if([obj isKindOfClass: [NSNumber class]])
            speech.position = (JusikStandingCutPosition)[obj unsignedIntegerValue];
        else
            speech.position = JusikStandingCutPositionNone;
        
        speech.musicName = [d objectForKey: @"music_name"];
        speech.soundEffectName = [d objectForKey: @"sound_effect_name"];
        speech.backgroundImageName = [d objectForKey: @"background_image_name"];
        [speeches addObject: speech];
        [speech release];
    }
    script.speeches = speeches;
    
    return script;
}

- (NSDictionary *)rowDataForCompanyAnalysisWithStep: (NSUInteger)step {
    NSString *query = [NSString stringWithFormat: @"select * from %@ where step=%d", kJusikTableNameScriptHomeAnalysisCompanyStudy, step];
    [self query: query];
    if([self nextRow]) {
        return [self rowData];
    }
    else {
        return nil;
    }
}

- (JusikBusinessType *)businessTypes {
    NSMutableArray *a = [NSMutableArray array];
    [self selectTable: kJusikTableNameBusinessType];
    while([self nextRow]) {
        NSDictionary *d = [self rowData];
        NSUInteger identifier = [[d objectForKey: @"uid"] unsignedIntegerValue];
        NSString *name = [d objectForKey: @"name"];
        double PER = [[d objectForKey: @"PER"] doubleValue];
        double exchangeRateEffect = [[d objectForKey: @"exchange_rate_effect"] doubleValue];
        JusikBusinessType *type = [[JusikBusinessType alloc] initWithIdentifier: identifier
                                                                           name: name
                                                                            PER: PER
                                                             exchangeRateEffect: exchangeRateEffect];
        [a addObject: type];
        [type release];
    }
    return [NSArray arrayWithArray: a];
}

- (JusikBusinessType *)businessTypeWithID: (NSUInteger)uid {
    NSString *query = [NSString stringWithFormat: @"select * from %@ where uid=%d", kJusikTableNameBusinessType, uid];
    [self query: query];
    if([self nextRow]) {
        NSDictionary *d = [self rowData];
        NSUInteger identifier = [[d objectForKey: @"uid"] unsignedIntegerValue];
        NSString *name = [d objectForKey: @"name"];
        double PER = [[d objectForKey: @"PER"] doubleValue];
        double exchangeRateEffect = [[d objectForKey: @"exchange_rate_effect"] doubleValue];
        JusikBusinessType *type = [[JusikBusinessType alloc] initWithIdentifier: identifier
                                                                           name: name
                                                                            PER: PER
                                                             exchangeRateEffect: exchangeRateEffect];
        return [type autorelease];
    }
    return nil;
}

- (NSArray *)activityHomeObjects {
    NSMutableArray *a = [NSMutableArray array];
    [self selectTable: kJusikTableNameActivityHomeObject];
    
    while([self nextRow]) {
        NSDictionary *d = [self rowData];
        
        NSString *name = [d objectForKey: @"name"];
        double x = [[d objectForKey: @"x"] doubleValue];
        double y = [[d objectForKey: @"y"] doubleValue];
        double width = [[d objectForKey: @"width"] doubleValue];
        double height = [[d objectForKey: @"height"] doubleValue];
//        NSString *imageName = [d objectForKey: @"image_name"];
        NSString *overImageName = [d objectForKey: @"over_image_name"];
        
        UIImage *overImage = [UIImage imageNamed: overImageName];
        CGRect area = CGRectMake(x, y, width, height);
        
        JusikActivityObject *o = [[JusikActivityObject alloc] initWithName: name];
        o.overImage = overImage;
        o.area = area;
        
        if(o) {
            [a addObject: o];
            [o release];
        }
    }
    return [NSArray arrayWithArray: a];
}

@end

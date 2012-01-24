//
//  JusikDBManager+Extension.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 21..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikDBManager.h"

@class JusikScript;
@class JusikPlayer;
@class JusikBusinessType;
@interface JusikDBManager (Extension)
- (JusikScript *)scriptWithID: (NSUInteger)uid;

- (NSArray *)businessTypes;
- (JusikBusinessType *)businessTypeWithID: (NSUInteger)uid;

- (NSArray *)activityHomeObjects;
@end

extern NSString * const kJusikTableNameScriptSpeech;
extern NSString * const kJusikTableNameBusinessType;
extern NSString * const kJusikTableNameActivityHomeObject;

// Scripts
extern NSString * const kJusikTableNameScriptHomeAnalysisCompanyFailed;
extern NSString * const kJusikTableNameScriptHomeAnalysisCompanyStudy;
extern NSString * const kJusikTableNameScriptHomeAnalysisCompanyMore;
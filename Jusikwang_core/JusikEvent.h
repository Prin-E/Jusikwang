//
//  JusikEvent.h
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 25..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JusikStockDataType.h"

/*
 JusikEventChangeWayRateRelative : 상대적인 비율로 변동
 JusikEventChangeWayRateAbsolute : 비율을 절대적인 값으로 고정
 JusikEventChangeWayValueRelative : 값을 상대적으로 변동
 JusikEventChangeWayValueAbsolute : 값을 절대적으로 고정
 */
typedef enum {
    JusikEventChangeWayRateRelative = 1,
    JusikEventChangeWayRateAbsolute = 2,
    JusikEventChangeWayValueRelative = 3,
    JusikEventChangeWayValueAbsolute = 4
} JusikEventChangeWay;

@interface JusikEvent : NSObject {
    NSString *_name;
    JusikEventType _type;
    NSMutableArray *_targets;
    
    JusikRange _change;
    JusikEventChangeWay _changeWay;
    NSUInteger _startTurn;
    NSUInteger _persistTurn;
    
    // 내부적으로 이벤트를 처리하기 위해 필요한 변수
    BOOL _effective;
    NSUInteger _remainingTurn;
}
@property (nonatomic, retain) NSString *name;
@property JusikEventType type;
@property (nonatomic, copy) NSMutableArray *targets;

@property JusikRange change;
@property JusikEventChangeWay changeWay;
@property NSUInteger startTurn;
@property NSUInteger persistTurn;

@property (readwrite, getter=isEffective) BOOL effective;
@property NSUInteger remainingTurn;
@end

@protocol JusikEventProcessing
- (void)processJusikEvents: (NSArray *)events;
@end

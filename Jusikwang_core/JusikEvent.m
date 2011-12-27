//
//  JusikEvent.m
//  Jusikwang_core
//
//  Created by 이 현우 on 11. 12. 25..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikEvent.h"

@implementation JusikEvent
@synthesize name = _name;
@synthesize type = _type;
@synthesize targets = _targets;
@synthesize change = _change;
@synthesize changeWay = _changeWay;
@synthesize startTurn = _startTurn;
@synthesize persistTurn = _persistTurn;
@synthesize remainingTurn = _remainingTurn;
@synthesize effective = _effective;

#pragma mark - 초기화 메서드
- (id)init {
    self = [super init];
    if(self) {
        self.targets = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (NSUInteger)persistTurn {
    return _persistTurn;
}

- (void)setPersistTurn:(NSUInteger)persistTurn {
    _persistTurn = persistTurn;
    _remainingTurn = persistTurn;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    self.name = nil;
    self.targets = nil;
    
    [super dealloc];
}

@end

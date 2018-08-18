//
//  JusikActivityObject.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 23..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JusikActivityObject.h"
#import "JusikUIDataTypes.h"

@implementation JusikActivityObject {
    BOOL _isPressedState;
    UIImage *_image;
}

@synthesize name = _name;
@synthesize description = _description;
@synthesize layer = _layer;
@synthesize area = _area;
@synthesize overImage = _overImage;

#pragma mark - 초기화 메서드
- (id)init {
    return nil;
}

- (id)initWithName:(NSString *)name {
    if(name == nil) return nil;
    
    self = [super init];
    if(self) {
        _name = [name copy];
        _layer = [CALayer new];
        [self showNormalState];
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (void)setOverImage:(UIImage *)overImage {
    [overImage retain];
    [_overImage release];
    _overImage = overImage;
    
    if(_isPressedState) {
        _isPressedState = NO;
        [self showPressedState];
    }
}

#pragma mark 상태
- (void)showNormalState {
    if(!_isPressedState) return;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration: kJusikViewShowHideTime];
    self.layer.contents = (id)[_image CGImage];
    [CATransaction commit];
    
    _isPressedState = NO;
}

- (void)showPressedState {
    if(_isPressedState) return;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration: kJusikViewShowHideTime];
    self.layer.contents = (id)[self.overImage CGImage];
    [CATransaction commit];
    
    _isPressedState = YES;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_name release];
    [_description release];
    [_layer release];
    [_overImage release];
    
    [super dealloc];
}

@end

//
//  JusikStockGraphView.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 11..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikStockGraphView.h"
#import "JusikStock.h"
#import "JusikRecord.h"

@implementation JusikStockGraphView
@synthesize stock = _stock;

#pragma mark - 초기화 메서드
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (JusikStock *)stock {
    return _stock;
}

- (void)setStock:(JusikStock *)stock {
    [stock retain];
    [_stock release];
    _stock = stock;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_stock release];
    [super dealloc];
}

@end

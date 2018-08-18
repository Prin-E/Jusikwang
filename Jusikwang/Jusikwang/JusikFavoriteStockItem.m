//
//  JusikFavoriteStockItem.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 22..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikFavoriteStockItem.h"
#import <QuartzCore/QuartzCore.h>
#import "JusikStock.h"
#import "JusikCompanyInfo.h"
#import "JusikFavoriteStockView.h"

@interface JusikFavoriteStockItem (Private)
- (void)_initLayers;
- (void)_layoutLayers;

- (void)_updateStyle;

- (void)_showPressedState;
- (void)_showNormalState;
@end

@implementation JusikFavoriteStockItem {
    CALayer *_containerLayer;
    CATextLayer *_companyNameLayer;
    CATextLayer *_priceLayer;
    CALayer *_arrowLayer;
}

@synthesize favoriteStockView = _favoriteStockView;
@synthesize stock = _stock;
@synthesize style = _style;

- (id)init {
    return [self initWithFrame: CGRectZero];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initLayers];
    }
    return self;
}

- (void)awakeFromNib {
    [self _initLayers];
}

#pragma mark - 프로퍼티 메서드
- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    [self _layoutLayers];
}

- (JusikStock *)stock {
    return _stock;
}

- (void)setStock:(JusikStock *)stock {
    [stock retain];
    [_stock release];
    _stock = stock;
    [self update];
}

- (JusikFavoriteStockItemStyle)style {
    return _style;
}

- (void)setStyle:(JusikFavoriteStockItemStyle)style {
    _style = style;
    [self _updateStyle];
}

#pragma mark - 주식 정보 표시
- (void)update {
    _companyNameLayer.string = NSLocalizedString(self.stock.info.name, self.stock.info.name);
    _priceLayer.string = [NSString stringWithFormat: @"%.0f", self.stock.price];
}

#pragma mark - 터치 이벤트
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _showPressedState];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _showNormalState];
    
    [self.favoriteStockView ariseTouchActionOfStock: self.stock.info.name];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self _showNormalState];
}

#pragma mark - 비공개 메서드
- (void)_initLayers {
    if(!_containerLayer) {
        _containerLayer = [[CALayer alloc] init];
        _containerLayer.masksToBounds = YES;
        
        _containerLayer.backgroundColor = [[UIColor colorWithRed: 0.872
                                                           green: 0.425
                                                            blue: 0.133
                                                           alpha: 0.958] CGColor];
        [self.layer addSublayer: _containerLayer];
    }
    if(!_companyNameLayer) {
        _companyNameLayer = [[CATextLayer alloc] init];
        _companyNameLayer.fontSize = 15;
        _companyNameLayer.wrapped = YES;
        _companyNameLayer.truncationMode = kCATruncationNone;
        _companyNameLayer.alignmentMode = kCAAlignmentCenter;
        
        [_containerLayer addSublayer: _companyNameLayer];
    }
    if(!_priceLayer) {
        _priceLayer = [[CATextLayer alloc] init];
        _priceLayer.fontSize = 12;
        _priceLayer.wrapped = YES;
        _priceLayer.alignmentMode = kCAAlignmentRight;
        
        [_containerLayer addSublayer: _priceLayer];
    }
    if(!_arrowLayer) {
        _arrowLayer = [[CALayer alloc] init];
        _arrowLayer.contentsGravity = kCAGravityCenter;
        [_containerLayer addSublayer: _arrowLayer];
    }
}

- (void)_layoutLayers {
    CGRect bounds = self.layer.bounds;
    CGPoint position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    CGFloat offset = 5.0;
    
    _containerLayer.bounds = bounds;
    _containerLayer.position = position;
    
    CGRect cnBounds = CGRectMake(0, 0, bounds.size.width - offset * 2, 
                                 bounds.size.height * 0.625 - offset * 2);
    CGPoint cnPos = CGPointMake(cnBounds.size.width * 0.5 + offset, 
                                cnBounds.size.height * 0.5 + offset);
    _companyNameLayer.bounds = cnBounds;
    _companyNameLayer.position = cnPos;
    
    CGRect pBounds = CGRectMake(0, 0, bounds.size.width * 0.75 - offset * 2,
                                bounds.size.height * 0.375 - offset * 2);
    CGPoint pPos = CGPointMake(pBounds.size.width * 0.5 + offset,
                               bounds.size.height * 0.625 + pBounds.size.height * 0.5 + offset);
    _priceLayer.bounds = pBounds;
    _priceLayer.position = pPos;
    
    CGRect aBounds = CGRectMake(0, 0, bounds.size.width * 0.25, bounds.size.height * 0.375);
    CGPoint aPos = CGPointMake(bounds.size.width * 0.75 + aBounds.size.width * 0.5, 
                               bounds.size.height * 0.625 + aBounds.size.height * 0.5);
    _arrowLayer.bounds = aBounds;
    _arrowLayer.position = aPos;
}

- (void)_showPressedState {
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.0];
    
    _containerLayer.opacity = 0.8;
    
    [CATransaction commit];
}

- (void)_showNormalState {
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.0];
    
    _containerLayer.opacity = 1.0;
    
    [CATransaction commit];
}

- (void)_updateStyle {
    [CATransaction begin];
    [CATransaction setAnimationDuration: 0.0];
    
    if(_style == JusikFavoriteStockItemStyleNormal) {
        _containerLayer.backgroundColor = [[UIColor colorWithRed: 0.872
                                                           green: 0.425
                                                            blue: 0.133
                                                           alpha: 0.958] CGColor];
    }
    else if(_style == JusikFavoriteStockItemStyleFavorite) {
        _containerLayer.backgroundColor = [[UIColor colorWithRed: 0.133
                                                           green: 0.425
                                                            blue: 0.872
                                                           alpha: 0.958] CGColor];
    }
    
    [CATransaction commit];
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_containerLayer release];
    [_companyNameLayer release];
    [_priceLayer release];
    [_arrowLayer release];
    
    [super dealloc];
}

@end

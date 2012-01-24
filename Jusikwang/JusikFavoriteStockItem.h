//
//  JusikFavoriteStockItem.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 22..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JusikFavoriteStockItemStyleNormal,
    JusikFavoriteStockItemStyleFavorite
} JusikFavoriteStockItemStyle;

@class JusikStock;
@class JusikFavoriteStockView;
@interface JusikFavoriteStockItem : UIView

@property (nonatomic, assign) JusikFavoriteStockView *favoriteStockView;
@property (nonatomic, retain) JusikStock *stock;
@property (nonatomic) JusikFavoriteStockItemStyle style;

- (void)update;

@end
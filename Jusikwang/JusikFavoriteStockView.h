//
//  JusikFavoriteStockView.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JusikFavoriteSortByName,
    JusikFavoriteSortByBusinessType,
    JusikFavoriteSortByPrice
} JusikFavoriteSorting;

@class JusikPlayer;
@class JusikStock;
@class JusikStockMarket;
@interface JusikFavoriteStockView : UIView

@property (nonatomic) JusikFavoriteSorting sort;
@property (nonatomic, retain) JusikPlayer *player;
@property (nonatomic, retain) JusikStockMarket *market;
@property (nonatomic, assign) id delegate;

- (void)update;
- (void)reload;

- (void)ariseTouchActionOfStock: (NSString *)stockName;

@end

@protocol JusikFavoriteStockViewDelegate
@optional
- (void)favoriteView: (JusikFavoriteStockView *)view didSelectStock: (NSString *)stockName;
@end
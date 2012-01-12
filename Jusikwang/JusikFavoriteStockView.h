//
//  JusikFavoriteStockView.h
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    JusikFavoriteSortWayName,
    JusikFavoriteSortWayBusinessType,
    JusikFavoriteSortWayPrice
} JusikFavoriteSortWay;

@class JusikPlayer;
@interface JusikFavoriteStockView : UIView

@property (nonatomic, readonly) JusikFavoriteSortWay currentSortWay;
@property (nonatomic, retain) JusikPlayer *player;

- (void)update;
- (void)reload;

@end

//
//  JusikFavoriteStockView.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikFavoriteStockView.h"
#import "JusikPlayer.h"

@implementation JusikFavoriteStockView {
    @private
    UIScrollView *_scrollView;
    NSMutableArray *_buttons;
    
    UIButton *_favoriteSortButton;
}

@synthesize player = _player;

@end

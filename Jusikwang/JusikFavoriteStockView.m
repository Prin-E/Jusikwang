//
//  JusikFavoriteStockView.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikFavoriteStockView.h"
#import "JusikPlayer.h"
#import "JusikPurchasedStockInfo.h"
#import "JusikCompanyInfo.h"
#import "JusikFavoriteStockItem.h"
#import "JusikStockMarket.h"
#import "JusikStock.h"

@interface JusikFavoriteStockView (Private)
- (void)_initObjects;
- (void)_layoutViews;
- (void)_layoutItems;

- (void)_updateSortButton;
- (void)_favoriteSortButtonAction: (id)sender;
@end

@implementation JusikFavoriteStockView {
    @private
    UIScrollView *_scrollView;
    
    UIView *_buttonView;
    NSMutableArray *_items;
    
    UIButton *_favoriteSortButton;
}

@synthesize player = _player;
@synthesize market = _market;
@synthesize sort = _sort;
@synthesize delegate = _delegate;

#pragma mark - 초기화 메서드
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if(self) {
        [self _initObjects];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if(self) {
        [self _initObjects];
    }
    return self;
}

- (void)awakeFromNib {
    [self addSubview: _scrollView];
    [self addSubview: _favoriteSortButton];
}

#pragma mark - 프로퍼티 메서드
- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    
    [self _layoutViews];
}

- (void)setPlayer:(JusikPlayer *)player {
    [player retain];
    [_player release];
    _player = player;
    
    [self reload];
}

- (void)setSort:(JusikFavoriteSorting)sort {
    _sort = sort;
    [self _layoutItems];
    [self _updateSortButton];
}

#pragma mark - 업데이트/다시 불러오기
- (void)update {
    for(JusikFavoriteStockItem *item in _items)
        [item update];
    [self _layoutItems];
    [self _updateSortButton];
}

- (void)reload {
    for(JusikFavoriteStockItem *item in _items) {
        [item removeFromSuperview];
    }
    [_items removeAllObjects];
    
    // 구입한 주식들을 먼저 추가하기
    NSDictionary *info = self.player.purchasedStockInfos;
    NSEnumerator *e = [info keyEnumerator];
    
    NSString *key = [e nextObject];
    while(key) {
        JusikFavoriteStockItem *item = [[JusikFavoriteStockItem alloc] init];
        JusikPurchasedStockInfo *i = [info objectForKey: key];
        
        item.style = JusikFavoriteStockItemStyleNormal;
        item.stock = [i.market stockOfCompanyWithName: i.stockName];
        item.favoriteStockView = self;
        
        [_items addObject: item];
        [_scrollView addSubview: item];
        [item release];
        
        key = [e nextObject];
    }
    
    // 즐겨찾기를 설정하기 전에 중복되는 주식들은 제외한다.
    NSMutableArray *a = [NSMutableArray arrayWithArray: self.player.favorites];
    NSMutableArray *removeList = [NSMutableArray array];
    for(JusikFavoriteStockItem *item in _items) {
        for(NSString *companyName in a) {
            if([item.stock.info.name isEqualToString: companyName]) {
                [item setStyle: JusikFavoriteStockItemStyleFavorite];
                [removeList addObject: companyName];
            }
        }
    }
    
    for(NSString *string in removeList)
        [a removeObject: string];
    
    // 즐겨찾기 추가
    for(NSString *companyName in a) {
        JusikStock *stock = [self.market stockOfCompanyWithName: companyName];
        if(stock) {
            JusikFavoriteStockItem *item = [[JusikFavoriteStockItem alloc] init];
            
            item.style = JusikFavoriteStockItemStyleFavorite;
            item.stock = stock;
            item.favoriteStockView = self;
            
            [_items addObject: item];
            [_scrollView addSubview: item];
            [item release];
        }
    }
    
    [self _layoutItems];
}

#pragma mark - 터치 이벤트
- (void)ariseTouchActionOfStock: (NSString *)stockName {
    if([_delegate respondsToSelector: @selector(favoriteView:didSelectStock:)]) {
        [_delegate favoriteView: self didSelectStock: stockName];
    }
}

#pragma mark - 비공개 메서드
- (void)_initObjects {
    if(_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.canCancelContentTouches = YES;
        [self addSubview: _scrollView];
    }
    
    if(_favoriteSortButton == nil) {
        _favoriteSortButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [_favoriteSortButton addTarget: self
                                action: @selector(_favoriteSortButtonAction:)
                      forControlEvents: UIControlEventTouchUpInside];
        [_favoriteSortButton setTitleColor: [UIColor blackColor] 
                                  forState: UIControlStateNormal];
        [self _updateSortButton];
        [self addSubview: _favoriteSortButton];
    }
    
    if(_items == nil) {
        _items = [NSMutableArray new];
    }
}

- (void)_layoutViews {
    CGRect frame = self.frame;
    
    CGRect scrollViewFrame = _scrollView.frame;
    scrollViewFrame.origin.x = 0;
    scrollViewFrame.origin.y = 0;
    scrollViewFrame.size.width = MAX(frame.size.width - frame.size.height, 0);
    scrollViewFrame.size.height = frame.size.height;
    _scrollView.frame = scrollViewFrame;
    
    CGRect buttonFrame = _favoriteSortButton.frame;
    buttonFrame.origin.x = scrollViewFrame.size.width;
    buttonFrame.origin.y = 0;
    buttonFrame.size.width = frame.size.height;
    buttonFrame.size.height = frame.size.height;
    _favoriteSortButton.frame = buttonFrame;
}

- (void)_layoutItems {
    CGRect frame = self.frame;
    CGFloat offset = 5.0;
    CGFloat buttonSize = frame.size.height - offset * 2;
    
    NSUInteger count = [_items count];
    CGSize scrollContentSize;
    scrollContentSize.width = count * (buttonSize + offset) + offset;
    scrollContentSize.height = buttonSize + 2 * offset;
    
    _scrollView.contentSize = scrollContentSize;
    
    CGFloat posX = 0;
    
    NSArray *sortedItems = [_items sortedArrayUsingComparator: ^(id obj1, id obj2) {
        JusikFavoriteStockItem *item1 = obj1;
        JusikFavoriteStockItem *item2 = obj2;
        NSComparisonResult result = NSOrderedSame;
        switch(self.sort) {
            case JusikFavoriteSortByName: {
                NSString *item1Name = NSLocalizedString(item1.stock.info.name, item1.stock.info.name);
                NSString *item2Name = NSLocalizedString(item2.stock.info.name, item2.stock.info.name);
                result = [item1Name localizedCaseInsensitiveCompare: item2Name];
                break;
            }
            case JusikFavoriteSortByBusinessType: {
                NSString *item1BTName = NSLocalizedString(item1.stock.info.businessType.name, item1.stock.info.businessType.name);
                NSString *item2BTName = NSLocalizedString(item2.stock.info.businessType.name, item2.stock.info.businessType.name);
                result = [item1BTName localizedCaseInsensitiveCompare: item2BTName];
                break;
            }
            case JusikFavoriteSortByPrice:
                if(item1.stock.price > item2.stock.price) {
                    result = NSOrderedDescending;
                }
                else if(item1.stock.price < item2.stock.price) {
                    result = NSOrderedAscending;
                }
                else {
                    result = NSOrderedSame;
                }
                break;
        }
        return result;
    }];
    
    for(JusikFavoriteStockItem *item in sortedItems) {
        item.frame = CGRectMake(posX + offset, offset, buttonSize, buttonSize);
        posX += buttonSize + offset;
    }
}

- (void)_favoriteSortButtonAction:(id)sender {
    JusikFavoriteSorting sort;
    switch(self.sort) {
        case JusikFavoriteSortByName:
            sort = JusikFavoriteSortByBusinessType;
            break;
        case JusikFavoriteSortByBusinessType:
            sort = JusikFavoriteSortByPrice;
            break;
        case JusikFavoriteSortByPrice:
        default:
            sort = JusikFavoriteSortByName;
            break;
    }
    self.sort = sort;
}

- (void)_updateSortButton {
    switch(self.sort) {
        case JusikFavoriteSortByName:
            [_favoriteSortButton setTitle: NSLocalizedString(@"com.jusikwang.stock_activity.favorite_stock.view.sort.name", @"com.jusikwang.stock_activity.favorite_stock.view.sort.name")
                                 forState: UIControlStateNormal];
            break;
        case JusikFavoriteSortByBusinessType:
            [_favoriteSortButton setTitle: NSLocalizedString(@"com.jusikwang.stock_activity.favorite_stock.view.sort.business_type", @"com.jusikwang.stock_activity.favorite_stock.view.sort.business_type")
                                 forState: UIControlStateNormal];
            break;
        case JusikFavoriteSortByPrice:
            [_favoriteSortButton setTitle: NSLocalizedString(@"com.jusikwang.stock_activity.favorite_stock.view.sort.price", @"com.jusikwang.stock_activity.favorite_stock.view.sort.price")
                                 forState: UIControlStateNormal];
            break;
    }
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_scrollView release];
    [_buttonView release];
    [_items release];
    [_favoriteSortButton release];
    [_delegate release];
    [_player release];
    
    [super dealloc];
}

@end

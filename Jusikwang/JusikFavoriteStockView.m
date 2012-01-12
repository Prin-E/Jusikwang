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

@interface JusikFavoriteStockView (Private)
- (void)_layoutButtons;
@end

@implementation JusikFavoriteStockView {
    @private
    UIScrollView *_scrollView;
    
    UIView *_buttonView;
    NSMutableArray *_buttons;
    
    UIButton *_favoriteSortButton;
}

@synthesize player = _player;
@synthesize currentSortWay = _currentSortWay;

#pragma mark - 초기화 메서드
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if(self) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.canCancelContentTouches = YES;
        
        _favoriteSortButton = [UIButton buttonWithType: UIButtonTypeCustom];
        _favoriteSortButton.titleLabel.text = @"";
        
        _buttons = [NSMutableArray new];
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (void)setFrame:(CGRect)frame {
    [super setFrame: frame];
    
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

- (void)setPlayer:(JusikPlayer *)player {
    [player retain];
    [_player release];
    _player = player;
    
    [self reload];
}

- (void)update {
    
}

- (void)reload {
    for(NSDictionary *d in _buttons) {
        UIButton *b = [d objectForKey: @"button"];
        [b removeFromSuperview];
    }
    [_buttons removeAllObjects];
    
    NSDictionary *info = self.player.purchasedStockInfos;
    NSEnumerator *e = [info keyEnumerator];
    
    NSString *key = [e nextObject];
    while(key) {
        NSMutableDictionary *d = [NSMutableDictionary dictionary];
        JusikPurchasedStockInfo *i = [info objectForKey: key];
        [d setObject: i.stockName forKey: @"stockName"];
        [d setObject: i.market forKey: @"market"];
        [d setObject: [NSNumber numberWithInteger: i.count] forKey: @"count"];
        UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
        [d setObject: button forKey: @"button"];
        
        [_buttons addObject: d];
        
        key = [e nextObject];
    }
    
    [self _layoutButtons];
}

#pragma mark - 비공개 메서드
- (void)_layoutButtons {
    CGRect frame = self.frame;
    CGFloat buttonSize = frame.size.height * 0.75;
    CGFloat offset = frame.size.height * 0.125;
    
    NSUInteger count = [_buttons count];
    CGRect buttonViewFrame = _buttonView.frame;
    buttonViewFrame.origin.x = 0;
    buttonViewFrame.origin.y = 0;
    buttonViewFrame.size.width = count * (buttonSize + offset) + offset;
    buttonViewFrame.size.height = buttonSize + 2 * offset;
    _buttonView.frame = buttonViewFrame;
    
    _scrollView.contentSize = buttonViewFrame.size;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_scrollView release];
    [_buttonView release];
    [_buttons release];
    [_favoriteSortButton release];
    
    [super dealloc];
}

@end

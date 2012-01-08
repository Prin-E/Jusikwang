//
//  JusikStatusBarController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 1..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikStatusBarController.h"
#import "JusikStockMarket.h"
#import "JusikPlayer.h"

@implementation JusikStatusBarController
#pragma mark - 프로퍼티
@synthesize mode = _mode;

@synthesize market = _market;
@synthesize player = _player;

@synthesize date = _date;

@synthesize statusContainerView = _statusContainerView;
@synthesize statusBarButton = _statusBarButton;

@synthesize stockTimeStatusView = _stockTimeStatusView;
@synthesize activityTimeStatusView = _activityTimeStatusView;

@synthesize stockTimeMoneyText = _stockTimeMoneyText;
@synthesize stockTimeKospiText = _stockTimeKospiText;
@synthesize stockTimeDowText = _stockTimeDowText;
@synthesize stockTimeExchangeText = _stockTimeExchangeText;
@synthesize stockTimeDateText = _stockTimeDateText;

@synthesize activityTimeMoneyText = _activityTimeMoneyText;
@synthesize activityTimeIntelligenceText = _activityTimeIntelligenceText;
@synthesize activityTimeReliabilityText = _activityTimeReliabilityText;
@synthesize activityTimeFatigabilityText = _activityTimeFatigabilityText;
@synthesize activityTimeDateText = _activityTimeDateText;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 프로퍼티 메서드
- (JusikStockMarket *)market {
    return _market;
}

- (void)setMarket:(JusikStockMarket *)market {
    if(_market != market) {
        [_market removeObserver: self forKeyPath: @"combinedPrice"];
        [_market removeObserver: self forKeyPath: @"exchangeRate"];
        [_market removeObserver: self forKeyPath: @"USStockPrice"];
        
        [market addObserver: self
                 forKeyPath: @"combinedPrice"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [market addObserver: self
                 forKeyPath: @"exchangeRate"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [market addObserver: self
                 forKeyPath: @"USStockPrice"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
    }
    
    [market retain];
    [_market release];
    _market = market;
    
    [self updateStatus];
}

- (JusikPlayer *)player {
    return _player;
}

- (void)setPlayer:(JusikPlayer *)player {
    if(_player != player) {
        [_market removeObserver: self forKeyPath: @"money"];
        [_market removeObserver: self forKeyPath: @"intelligence"];
        [_market removeObserver: self forKeyPath: @"reliability"];
        [_market removeObserver: self forKeyPath: @"fatigability"];
        
        [player addObserver: self
                 forKeyPath: @"money"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"intelligence"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"reliability"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"fatigability"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
    }
    
    [player retain];
    [_player release];
    _player = player;
    
    [self updateStatus];
}

- (JusikStatusBarMode)mode {
    return _mode;
}

- (void)setMode:(JusikStatusBarMode)mode {
    _mode = mode;
    if(mode == JusikStatusBarModeStockTime) {
        [self.activityTimeStatusView removeFromSuperview];
        [self.statusContainerView addSubview: self.stockTimeStatusView];
    }
    else if(mode == JusikStatusBarModeActivity) {
        [self.stockTimeStatusView removeFromSuperview];
        [self.statusContainerView addSubview: self.activityTimeStatusView];
    }
    [self updateStatus];
}

- (NSDate *)date {
    return [[_date copy] autorelease];
}

- (void)setDate:(NSDate *)date {
    if(_date != date) {
        [_date release];
        _date = [date copy];
        
        [self updateDate];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mode = JusikStatusBarModeStockTime;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.statusContainerView = nil;
    self.statusBarButton = nil;
    
    self.stockTimeStatusView = nil;
    self.activityTimeStatusView = nil;
    
    self.stockTimeMoneyText = nil;
    self.stockTimeKospiText = nil;
    self.stockTimeDowText = nil;
    self.stockTimeExchangeText = nil;
    self.stockTimeDateText = nil;
    
    self.activityTimeMoneyText = nil;
    self.activityTimeIntelligenceText = nil;
    self.activityTimeReliabilityText = nil;
    self.activityTimeFatigabilityText = nil;
    self.activityTimeDateText = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 상태 업데이트
- (void)updateStatus {
    if(_mode == JusikStatusBarModeStockTime) {
        if(self.player) {
            self.stockTimeMoneyText.text = [NSString stringWithFormat: @"%.0f", self.player.money];
        }
        else {
            self.stockTimeMoneyText.text = @"?";
        }
        
        if(self.market) {
            self.stockTimeKospiText.text = [NSString stringWithFormat: @"%.0f", self.market.combinedPrice];
            self.stockTimeDowText.text = [NSString stringWithFormat: @"%.0f", self.market.USStockPrice];
            self.stockTimeExchangeText.text = [NSString stringWithFormat: @"%.0f", self.market.exchangeRate];
        }
        else {
            self.stockTimeKospiText.text = @"?";
            self.stockTimeDowText.text = @"?";
            self.stockTimeExchangeText.text = @"?";
        }
    }
    else if(_mode == JusikStatusBarModeActivity) {
        if(self.player) {
            self.activityTimeMoneyText.text = [NSString stringWithFormat: @"%.0f", self.player.money];
            self.activityTimeIntelligenceText.text = [NSString stringWithFormat: @"%.0f", self.player.intelligence];
            self.activityTimeReliabilityText.text = [NSString stringWithFormat: @"%.0f", self.player.reliability];
            self.activityTimeFatigabilityText.text = [NSString stringWithFormat: @"%.0f", self.player.fatigability];
        }
        else {
            self.activityTimeMoneyText.text = @"?";
            self.activityTimeIntelligenceText.text = @"?";
            self.activityTimeReliabilityText.text = @"?";
            self.activityTimeFatigabilityText.text = @"?";
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self updateStatus];
}

- (void)updateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd EEE"];
    self.stockTimeDateText.text = [formatter stringFromDate: _date];
    self.activityTimeDateText.text = [formatter stringFromDate: _date];
    [formatter release];
}

#pragma mark - 메모리 해제
- (void)dealloc {
    self.market = nil;
    self.player = nil;
    self.date = nil;
    
    [super dealloc];
}

@end

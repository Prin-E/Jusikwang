//
//  JusikStockGameViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikStockGameViewController.h"
#import "JusikStockMarket.h"
#import "JusikPlayer.h"
#import "JusikUIDataTypes.h"
#import "JusikStock.h"
#import "JusikCompanyInfo.h"
#import "JusikPurchasedStockInfo.h"
#import "JusikBGMPlayer.h"
#import "JusikDBManager.h"
#import "JusikDBManager+Extension.h"
#import "JusikFavoriteStockView.h"

#define kJusikStockTimePeriod 10
#define kJusikStockGameMaxSeconds 180

NSString *const JusikStockGameViewGameDidStartNotification =  @"JusikStockGameViewGameDidStartNotification";
NSString *const JusikStockGameViewPeriodDidUpdateNotification = @"JusikStockGameViewPeriodDidUpdateNotification";
NSString *const JusikStockGameViewGameDidStopNotification = @"JusikStockGameViewGameDidStopNotification";

@interface JusikStockGameViewController (Private)
- (void)showNews;
- (void)hideNews;

// 시장 관련
- (void)openMarket;
- (void)closeMarket;

- (void)setupTimer;
- (void)removeTimer;
- (void)gameTimer;
- (void)nextPeriod;

- (void)setupFavoriteView;
- (void)setupNewsView;
- (void)setupGameView;

- (void)showFavoriteView;
- (void)hideFavoriteView;

- (void)showResultView;
- (void)hideResultView;

- (void)_showStockInfoViewWithStockName: (NSString *)stockName;
- (void)updateStockInfoView;
@end

@implementation JusikStockGameViewController {
    BOOL _playing;
    
    NSTimer *_timer;
    BOOL _participating;
    
    BOOL _showingFavoriteView;
    
    NSUInteger _seconds;
    NSUInteger _timerCount;
    
    JusikStock *_selectedStock;
}

@synthesize favoriteView = _favoriteView;
@synthesize newsView = _newsView;
@synthesize newsBackgroundView = _newsBackgroundView;
@synthesize favoriteShowButton = _favoriteShowButton;
@synthesize gameTimeText = _gameTimeText;
@synthesize resultView = _resultView;

@synthesize worldMapView = _worldMapView;
@synthesize scrollView = _scrollView;

@synthesize stockInfoNameText = _stockInfoNameText;
@synthesize stockInfoView = _stockInfoView;
@synthesize stockInfoTypeText = _stockInfoTypeText;
@synthesize stockInfoCountText = _stockInfoCountText;
@synthesize stockInfoPriceText = _stockInfoPriceText;
@synthesize stockInfoPurchasedText = _stockInfoPurchasedText;
@synthesize stockInfoFavoriteAddButton = _stockInfoFavoriteAddButton;
@synthesize stockInfoFavoriteRemoveButton = _stockInfoFavoriteRemoveButton;

@synthesize market = _market;
@synthesize player = _player;

@synthesize date = _date;

@synthesize db = _db;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - 메모리 부족
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 게임 시작/중지
- (void)play {
    if(_playing) return;
    _playing = YES;
    
    [[JusikBGMPlayer sharedPlayer] playMusic: JusikBGMMusicMainMenu];
    [self showNews];
    [self openMarket];
}

- (void)pause {
    if(_participating) {
        [self removeTimer];
    }
}

- (void)resume {
    if(_participating) {
        [self setupTimer];
    }
}

- (void)stop {
    if(_playing == NO) return;
    _playing = NO;
    
    [self closeMarket];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: JusikStockGameViewGameDidStopNotification
                      object: self];
}

#pragma mark - 게임
- (void)openMarket {
    if(_participating) return;
    _participating = YES;
    
    [self.market open];
}

- (void)closeMarket {
    if(!_participating) return;
    
    [self removeTimer];
    
    NSUInteger remainingPeriods = (kJusikStockGameMaxSeconds - _seconds) / kJusikStockTimePeriod;
    
    while(remainingPeriods--)
        [self.market nextPeriod];
    
    [self.market close];
    
    self.gameTimeText.text = @"";
    [self.gameTimeText removeFromSuperview];
    _participating = NO;
}

- (void)setupGameView {
    self.gameTimeText.text = @"";
    UIImage *img = [UIImage imageNamed: @"Images/result.png"];
    if(img)
        self.resultView.backgroundColor = [UIColor colorWithPatternImage: img];
    
    [self.scrollView addSubview: self.worldMapView];
    self.scrollView.contentSize = self.worldMapView.frame.size;
    self.scrollView.contentMode = UIViewContentModeCenter;
}

- (IBAction)buyStock:(id)sender {
    NSInteger i = 0;
    BOOL success = [[NSScanner scannerWithString: self.stockInfoCountText.text] scanInteger: &i];
    if(success == NO) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle: @"Jusikwang"
                                                    message: @"숫자로 지정하세요"
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
        [a show];
        [a release];
        return;
    }
    
    [self.player buyStockName: _selectedStock.info.name
                   fromMarket: self.market
                        count: i];
    [self updateStockInfoView];
    [self.favoriteView reload];
}

- (IBAction)sellStock:(id)sender {
    NSInteger i = 0;
    BOOL success = [[NSScanner scannerWithString: self.stockInfoCountText.text] scanInteger: &i];
    if(success == NO) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle: @"Jusikwang"
                                                    message: @"숫자로 지정하세요"
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
        [a show];
        [a release];
        return;
    }
    
    [self.player sellStockName: _selectedStock.info.name
                      toMarket: self.market
                         count: i];
    [self updateStockInfoView];
    [self.favoriteView reload];
}

- (IBAction)addFavorite:(id)sender {
    if(_selectedStock) {
        [self.player addFavorite: _selectedStock.info.name];
        [self.favoriteView reload];
        [self updateStockInfoView];
    }
}

- (IBAction)removeFavorite:(id)sender {
    if(_selectedStock) {
        [self.player removeFavorite: _selectedStock.info.name];
        [self.favoriteView reload];
        [self updateStockInfoView];
    }
}

#pragma mark - 주식 정보 보기
- (IBAction)showStockInfo:(id)sender {
    if(_timer == nil) return;
    
    NSUInteger tag = [sender tag];
    NSString *companyName;
    switch(tag) {
        case 1:
            companyName = @"com.jusikwang.company.kodai";
            break;
        case 2:
            companyName = @"com.jusikwang.company.cia";
            break;
        case 3:
            companyName = @"com.jusikwang.company.yusang";
            break;
        case 4:
            companyName = @"com.jusikwang.company.hanisamhwa";
            break;
        case 5:
            companyName = @"com.jusikwang.company.otae";
            break;
    }
    
    [self _showStockInfoViewWithStockName: companyName];
}

- (IBAction)hideStockInfo:(id)sender {
    _selectedStock = nil;
    [self.stockInfoView removeFromSuperview];
}

- (void)updateStockInfoView {
    if(_selectedStock) {
        self.stockInfoNameText.text = NSLocalizedString(_selectedStock.info.name, @"");
        self.stockInfoPriceText.text = [NSString stringWithFormat: @"%.0f", _selectedStock.price];
        self.stockInfoTypeText.text = NSLocalizedString(_selectedStock.info.businessType.name, @"");
        
        JusikPurchasedStockInfo *i = [self.player.purchasedStockInfos objectForKey: _selectedStock.info.name];
        self.stockInfoPurchasedText.text = [NSString stringWithFormat: @"%d", i.count];
        
        if([self.player.favorites containsObject: _selectedStock.info.name]) {
            self.stockInfoFavoriteRemoveButton.enabled = YES;
            self.stockInfoFavoriteRemoveButton.alpha = 1.0;
            self.stockInfoFavoriteAddButton.enabled = NO;
            self.stockInfoFavoriteAddButton.alpha = 0.5;
        }
        else {
            self.stockInfoFavoriteAddButton.enabled = YES;
            self.stockInfoFavoriteAddButton.alpha = 1.0;
            self.stockInfoFavoriteRemoveButton.enabled = NO;
            self.stockInfoFavoriteRemoveButton.alpha = 0.5;
        }
    }
}

- (void)_showStockInfoViewWithStockName:(NSString *)stockName {
    _selectedStock = [self.market stockOfCompanyWithName: stockName];
    if(_selectedStock == nil) {
        NSLog(@"%s -> Cannot find stock named %@", __PRETTY_FUNCTION__, stockName);
        [self hideStockInfo: self];
        return;
    }
    
    [self updateStockInfoView];
    
    [self.view addSubview: self.stockInfoView];
    CGRect frame = self.stockInfoView.frame;
    CGRect viewFrame = self.view.frame;
    frame.origin.x = (viewFrame.size.width - frame.size.width) * 0.5;
    frame.origin.y = (viewFrame.size.height - frame.size.height) * 0.5;
    self.stockInfoView.frame = frame;
}

#pragma mark - 결과 창
- (void)showResultView {
    [self hideStockInfo: self];
    
    [self.view addSubview: self.resultView];
    CGRect frame = self.resultView.frame;
    CGRect viewFrame = self.view.frame;
    frame.origin.x = (viewFrame.size.width - frame.size.width) * 0.5;
    frame.origin.y = (viewFrame.size.height - frame.size.height) * 0.5;
    self.resultView.frame = frame;
}

- (void)hideResultView {
    [self.resultView removeFromSuperview];
}

- (void)resultButtonAction:(id)sender {
    [self hideResultView];
    [self stop];
}

#pragma mark - Timer
- (void)setupTimer {
    if(_timer == nil) {
        _timer = [[NSTimer scheduledTimerWithTimeInterval: 1.0
                                                   target: self
                                                 selector: @selector(gameTimer)
                                                 userInfo: nil
                                                  repeats: YES] retain];
    }
}

- (void)removeTimer {
    if(_timer) {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
    }
}

- (void)gameTimer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    _seconds++;
    _timerCount++;
    
    if(_seconds >= kJusikStockGameMaxSeconds) {
        [self closeMarket];
        [self showResultView];
        return;
    }
    if(_timerCount >= kJusikStockTimePeriod) {
        [self nextPeriod];
        _timerCount = 0;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName: JusikStockGameViewPeriodDidUpdateNotification
                          object: self];
        
        [self.favoriteView update];
        
        // for testing
        [self updateStockInfoView];
    }
    
    NSUInteger time = kJusikStockGameMaxSeconds - _seconds;
    NSUInteger timeMinute = time / 60;
    NSUInteger timeSecond = time % 60;
    self.gameTimeText.text = [NSString stringWithFormat: @"Time : %02d:%02d", timeMinute, timeSecond];
}

- (void)nextPeriod {
    [self.market nextPeriod];
}

#pragma mark - 뉴스
- (void)setupNewsView {
    UIImage *img = [UIImage imageNamed: @"Images/briefing_newpaper.png"];
    if(img)
        self.newsBackgroundView.backgroundColor = [UIColor colorWithPatternImage: img];
    self.newsView.alpha = 0.0;
    [self.view addSubview: self.newsView];
    
    [self hideNews];
}

- (void)showNews { 
    CGRect frame = self.newsView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.newsView.frame = frame;
                         self.newsView.alpha = 1.0;
                     }
                     completion: ^(BOOL completed) {
                     }];
}

- (void)hideNews {
    CGRect frame = self.newsView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         self.newsView.frame = frame;
                         self.newsView.alpha = 0.0;
                     }
                     completion: ^(BOOL completed) {
                     }];
}

- (IBAction)newsParticipateStockMarket:(id)sender {
    [self hideNews];
    
    _timerCount = 0;
    _seconds = 0;
    [self setupTimer];
    
    [self.view addSubview: self.gameTimeText];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: JusikStockGameViewGameDidStartNotification
                      object: self];
}

- (IBAction)newsSkip:(id)sender {
    [self hideNews];
    [self stop];
}

#pragma mark - 즐겨찾기
- (void)setupFavoriteView {
    [self.view addSubview: self.favoriteShowButton];
    [self.view addSubview: self.favoriteView];
    
    self.favoriteView.player = self.player;
    self.favoriteView.market = self.market;
    self.favoriteView.delegate = self;
    
    // 위치, 크기 설정
    CGRect frame = self.favoriteView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height;
    self.favoriteView.frame = frame;
    
    frame = self.favoriteShowButton.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.favoriteShowButton.frame = frame;
    
    // 배경 설정
    UIImage *favoriteImage = [UIImage imageNamed: @"Images/favorite_favorite.png"];
    if(favoriteImage)
        self.favoriteView.backgroundColor = [UIColor colorWithPatternImage: favoriteImage];
    UIImage *buttonImage = [UIImage imageNamed: @"Images/favorite_button_up.png"];
    if(buttonImage)
        self.favoriteShowButton.backgroundColor = [UIColor colorWithPatternImage:buttonImage];
}

- (void)toggleShowingFavoriteView:(id)sender {
    if(_showingFavoriteView)
        [self hideFavoriteView];
    else
        [self showFavoriteView];
}

- (void)showFavoriteView {
    if(_showingFavoriteView) return;
    
    _showingFavoriteView = YES;
    
    CGRect favoriteViewFrame = self.favoriteView.frame;
    CGRect favoriteButtonFrame = self.favoriteShowButton.frame;
    CGRect viewFrame = self.view.frame;
    favoriteViewFrame.origin.x = 0;
    favoriteViewFrame.origin.y = viewFrame.size.height - favoriteViewFrame.size.height;
    favoriteButtonFrame.origin.x = viewFrame.size.width - favoriteButtonFrame.size.width;
    favoriteButtonFrame.origin.y = viewFrame.size.height - favoriteButtonFrame.size.height - favoriteViewFrame.size.height;
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                     animations: ^{
                         self.favoriteView.frame = favoriteViewFrame;
                         self.favoriteShowButton.frame = favoriteButtonFrame;
                     }];
    
    UIImage *buttonImage = [UIImage imageNamed: @"Images/favorite_button_down.png"];
    if(buttonImage)
        self.favoriteShowButton.backgroundColor = [UIColor colorWithPatternImage:buttonImage];
}

- (void)hideFavoriteView {
    if(!_showingFavoriteView) return;
    
    _showingFavoriteView = NO;
    
    CGRect favoriteViewFrame = self.favoriteView.frame;
    CGRect favoriteButtonFrame = self.favoriteShowButton.frame;
    CGRect viewFrame = self.view.frame;
    favoriteViewFrame.origin.x = 0;
    favoriteViewFrame.origin.y = viewFrame.size.height;
    favoriteButtonFrame.origin.x = viewFrame.size.width - favoriteButtonFrame.size.width;
    favoriteButtonFrame.origin.y = viewFrame.size.height - favoriteButtonFrame.size.height;
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                     animations: ^{
                         self.favoriteView.frame = favoriteViewFrame;
                         self.favoriteShowButton.frame = favoriteButtonFrame;
                     }];
    
    UIImage *buttonImage = [UIImage imageNamed: @"Images/favorite_button_up.png"];
    if(buttonImage)
        self.favoriteShowButton.backgroundColor = [UIColor colorWithPatternImage:buttonImage];
}

- (void)favoriteView:(JusikFavoriteStockView *)view didSelectStock:(NSString *)stockName {
    [self _showStockInfoViewWithStockName: stockName];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.stockInfoCountText resignFirstResponder];
    return NO;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupFavoriteView];
    [self setupNewsView];
    [self setupGameView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self stop];
    
    self.newsView = nil;
    self.newsBackgroundView = nil;
    self.favoriteView = nil;
    self.favoriteShowButton = nil;
    self.gameTimeText = nil;
    self.worldMapView = nil;
    self.scrollView = nil;
    
    self.stockInfoPriceText = nil;
    self.stockInfoTypeText = nil;
    self.stockInfoView = nil;
    self.stockInfoNameText = nil;
    self.stockInfoCountText = nil;
    self.stockInfoPurchasedText = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)dealloc {
    self.market = nil;
    self.player = nil;
    self.db = nil;
    [super dealloc];
}

@end

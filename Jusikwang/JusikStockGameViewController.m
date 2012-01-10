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

#define kJusikStockTimePeriod 10
#define kJusikStockGameMaxSeconds 10

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
@end

@implementation JusikStockGameViewController {
    NSTimer *_timer;
    BOOL _participating;
    
    BOOL _showingFavoriteView;
    
    NSUInteger _seconds;
    NSUInteger _timerCount;
}

@synthesize favoriteView = _favoriteView;
@synthesize newsView = _newsView;
@synthesize newsBackgroundView = _newsBackgroundView;
@synthesize favoriteShowButton = _favoriteShowButton;
@synthesize gameTimeText = _gameTimeText;
@synthesize resultView = _resultView;

@synthesize market = _market;
@synthesize player = _player;

@synthesize date = _date;

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
    [self showNews];
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
    
    _timerCount = 0;
    _seconds = 0;
    [self setupTimer];
    
    [self.view addSubview: self.gameTimeText];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName: JusikStockGameViewGameDidStartNotification
                      object: self];
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
    
    [self showResultView];
}

- (void)setupGameView {
    self.gameTimeText.text = @"";
    UIImage *img = [UIImage imageNamed: @"Images/result.png"];
    if(img)
        self.resultView.backgroundColor = [UIColor colorWithPatternImage: img];
}

- (void)showResultView {
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
        return;
    }
    if(_timerCount >= kJusikStockTimePeriod) {
        [self nextPeriod];
        _timerCount = 0;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName: JusikStockGameViewPeriodDidUpdateNotification
                          object: self];
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
    [self openMarket];
}

- (IBAction)newsSkip:(id)sender {
    [self hideNews];
    [self stop];
}

#pragma mark - 즐겨찾기
- (void)setupFavoriteView {
    [self.view addSubview: self.favoriteShowButton];
    [self.view addSubview: self.favoriteView];
    
    CGRect frame = self.favoriteView.frame;
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height;
    self.favoriteView.frame = frame;
    
    frame = self.favoriteShowButton.frame;
    frame.origin.x = self.view.frame.size.width - frame.size.width;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.favoriteShowButton.frame = frame;
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end

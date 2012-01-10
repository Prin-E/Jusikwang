//
//  JusikGameViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikGameViewController.h"
#import "JusikViewController.h"
#import "JusikStatusBarController.h"
#import "JusikUIDataTypes.h"
#import "JusikPlayerInfoViewController.h"
#import "JusikStockGameViewController.h"
#import "JusikActivityGameViewController.h"
#import "NSDate+Extension.h"

#import "JusikCore.h"

@interface JusikGameViewController (Private)
- (void)_initStatusBar;
- (void)_layoutViews;
@end

@implementation JusikGameViewController {
    BOOL _showingMenu;
    UIViewController<JusikGameController> *_currentGameController;
}

@synthesize market = _market;
@synthesize player = _player;

@synthesize gameState = _gameState;
@synthesize date = _date;
@synthesize turn = _turn;
@synthesize showsTutorial = _showsTutorial;

@synthesize statusBarController = _statusBarController;
@synthesize viewController = _viewController;
@synthesize piViewController = _piViewController;

@synthesize stockGameController = _stockGameController;
@synthesize activityGameController = _activityGameController;

@synthesize contentView = _contentView;
@synthesize statusBarMenuView = _statusBarMenuView;
@synthesize menuView = _menuView;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSDateComponents *comp = [NSDateComponents new];
        comp.year = 2011;
        comp.month = 11;
        comp.day = 10;
        _date = [comp date];
        [_date retain];
        [comp release];
        
        
        JusikStockGameViewController *stockGame = [[JusikStockGameViewController alloc] initWithNibName: @"JusikStockGameViewController" bundle: nil];
        self.stockGameController = stockGame;
        [stockGame release];
        
        JusikActivityGameViewController *activityGame = [[JusikActivityGameViewController alloc] initWithNibName: @"JusikActivityGameViewController" bundle: nil];
        self.activityGameController = activityGame;
        [activityGame release];
        
        self.gameState = JusikGamePlayStateStock;
        _showsTutorial = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stockGameDidStart:)
                                                     name: JusikStockGameViewGameDidStartNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stockGamePeriodDidUpdate:)
                                                     name: JusikStockGameViewPeriodDidUpdateNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(stockGameDidEnd:)
                                                     name: JusikStockGameViewGameDidStopNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(activityGameDidStart:)
                                                     name: JusikActivityGameViewGameDidStartNotification
                                                   object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(activityGameDidStart:)
                                                     name: JusikActivityGameViewGameDidStopNotification
                                                   object: nil];
    }
    return self;
}

#pragma mark - 프로퍼티 메서드
- (JusikStatusBarController *)statusBarController {
    return _statusBarController;
}

- (void)setStatusBarController:(JusikStatusBarController *)statusBarController {
    [_statusBarController.view removeFromSuperview];
    [statusBarController retain];
    [_statusBarController release];
    
    _statusBarController = statusBarController;
    [self.statusBarMenuView addSubview: _statusBarController.view];
    
    [self.statusBarController.statusBarButton addTarget: self
                                                 action: @selector(showMenu:)
                                       forControlEvents: UIControlEventTouchUpInside];
    
    [self _layoutViews];
}

- (JusikPlayerInfoViewController *)piViewController {
    return _piViewController;
}

- (void)setPiViewController:(JusikPlayerInfoViewController *)piViewController {
    [_piViewController.view removeFromSuperview];
    [piViewController retain];
    [_piViewController release];
    
    _piViewController = piViewController;
    [self.statusBarMenuView addSubview: _piViewController.view];
    
    _piViewController.player = self.player;
    [self _layoutViews];
}

- (JusikStockGameViewController *)stockGameController {
    return _stockGameController;
}

- (void)setStockGameController:(JusikStockGameViewController *)stockGameController {
    [_stockGameController.view removeFromSuperview];
    [stockGameController retain];
    [_stockGameController release];
    
    _stockGameController = stockGameController;
    
    self.stockGameController.market = self.market;
    self.stockGameController.player = self.player;
}

- (void)setActivityGameController:(JusikActivityGameViewController *)activityGameController {
    [_activityGameController.view removeFromSuperview];
    [activityGameController retain];
    [_activityGameController release];
    
    _activityGameController = activityGameController;
    
    self.activityGameController.player = self.player;
}

- (JusikPlayer *)player {
    return _player;
}

- (void)setPlayer:(JusikPlayer *)player {
    [player retain];
    [_player release];
    _player = player;
    
    self.statusBarController.player = player;
    self.piViewController.player = player;
}

- (JusikStockMarket *)market {
    return _market;
}

- (void)setMarket:(JusikStockMarket *)market {
    [market retain];
    [_market release];
    _market = market;
    
    self.statusBarController.market = market;
}

- (NSDate *)date {
    return [[_date copy] autorelease];
}

- (void)setDate:(NSDate *)date {
    if(_date != date) {
        [_date release];
        _date = [date copy];
    }
    self.statusBarController.date = self.date;
    self.stockGameController.date = self.date;
    self.activityGameController.date = self.date;
}

- (JusikGamePlayState)gameState {
    return _gameState;
}

- (void)setGameState:(JusikGamePlayState)gameState {
    if(_gameState == gameState) {
        if(_currentGameController != nil) return;
    }
    if(gameState == JusikGamePlayStateStock) {
        if([self.date isWeekday]) {
            // 주말은 주식시장을 이용할 수 없다.
            // 활동모드로 전환
            self.gameState = JusikGamePlayStateActivity;
            return;
        }
    }
    _gameState = gameState;
    
    // 상태 바 전환
    if(gameState == JusikStatusBarModeStockTime)
        self.statusBarController.mode = JusikStatusBarModeStockTime;
    else if(gameState == JusikStatusBarModeActivity)
        self.statusBarController.mode = JusikStatusBarModeActivity;
    
    // 뷰 전환
    UIViewController<JusikGameController> *gameController = nil;
    if(self.gameState == JusikGamePlayStateStock) {
        gameController = self.stockGameController;
        [(JusikActivityGameViewController *)_currentGameController stop];
    }
    else {
        gameController = self.activityGameController;
        [(JusikStockGameViewController *)_currentGameController stop];
    }
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         _currentGameController.view.alpha = 0;
                     }
                     completion: ^(BOOL completed) {
                         [_currentGameController.view removeFromSuperview];
                         gameController.view.alpha = 0;
                         [self.contentView addSubview: gameController.view];
                         [UIView animateWithDuration: kJusikViewFadeTime
                                               delay: 0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations: ^{
                                              gameController.view.alpha = 1;
                                          }
                                          completion: ^(BOOL completed) {
                                              gameController.view.alpha = 1;
                                              _currentGameController = gameController;
                                          }];
                     }];
}

#pragma mark 메모리 관리
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 액션
- (void)showMenu:(id)sender {
    [UIView animateWithDuration: kJusikViewShowHideTime
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGRect frame = self.statusBarMenuView.frame;
                         if(_showingMenu) {
                             frame.origin.y = -frame.size.height + self.statusBarController.view.frame.size.height;
                             
                             UIImage *buttonImage = [UIImage imageNamed: @"Images/sidebar_button_down.png"];
                             if(buttonImage)
                                 self.statusBarController.statusBarButton.backgroundColor =  [UIColor colorWithPatternImage: buttonImage];
                         }
                         else {
                             frame.origin.y = 0.0;
                             UIImage *buttonImage = [UIImage imageNamed: @"Images/sidebar_button_up.png"];
                             if(buttonImage)
                                 self.statusBarController.statusBarButton.backgroundColor =  [UIColor colorWithPatternImage: buttonImage];
                         }
                         self.statusBarMenuView.frame = frame;                         
                     }
                     completion: ^(BOOL completed) {
                         
                     }];
    
    _showingMenu = !_showingMenu;
    
    switch(self.gameState) {
        case JusikGamePlayStateStock:
            if(_showingMenu)
                [self.stockGameController pause];
            else
                [self.stockGameController resume];
            break;
        case JusikGamePlayStateActivity:
            break;
    }
}

- (void)exitGame:(id)sender {
    [self.viewController exitGame];
}

- (void)play {    
    if(self.gameState == JusikGamePlayStateStock) {
        if([self.date isWeekday] == NO)
            [self.stockGameController play];
        else {
            self.gameState = JusikGamePlayStateActivity;
            [self.activityGameController play];
        }
    }
    else {
        [self.activityGameController play];
    }
}

- (void)pause {
    if(self.gameState == JusikGamePlayStateStock) {
        [self.stockGameController pause];
    }
    else {
        [self.activityGameController pause];
    }
}

- (void)resume {
    if(self.gameState == JusikGamePlayStateStock) {
        [self.stockGameController resume];
    }
    else {
        [self.activityGameController resume];
    }
}

- (void)stop {
    if(self.gameState == JusikGamePlayStateStock) {
        [self.stockGameController stop];
    }
    else {
        [self.activityGameController stop];
    }
}

- (void)nextDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    comp.day = 1;
    
    NSDate *newDate = [gregorian dateByAddingComponents: comp 
                                                 toDate: _date
                                                options: 0];
    [_date release];
    _date = newDate;
    [_date retain];
}

- (void)showTutorial {
    if(self.showsTutorial == NO) return;
    
    [_currentGameController pause];
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0
                        options: UIViewAnimationCurveEaseOut
                     animations: ^{
                         _currentGameController.view.alpha = 0;
                     }
                     completion: ^(BOOL completed){
                         [_currentGameController.view removeFromSuperview];
                     }];
    
    // show attention
    UIImage *attentionImage = [UIImage imageNamed: @"attention.png"];
    UIImageView *attentionView = [[UIImageView alloc] initWithImage: attentionImage];
    attentionView.frame = self.contentView.frame;
    attentionView.alpha = 0;
    [self.contentView addSubview: attentionView];
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: kJusikViewFadeTime
                        options: UIViewAnimationCurveEaseOut
                     animations: ^{
                         attentionView.alpha = 1.0;
                     }
                     completion: nil];
    
    // hide attention
    [UIView animateWithDuration: kJusikViewAttentionTime
                          delay:kJusikViewFadeTime*2
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         attentionView.alpha = 0;
                     }
                     completion: ^(BOOL completed) {
                         // run script
                         
                         //
                         
                         [_currentGameController resume];
                     }];
}

#pragma mark - 노티피케이션
- (void)stockGameDidStart: (NSNotification *)n {
    
}

- (void)stockGamePeriodDidUpdate: (NSNotification *)n {
    
}

- (void)stockGameDidEnd: (NSNotification *)n {
    self.gameState = JusikGamePlayStateActivity;
    [self play];
}

- (void)activityGameDidStart: (NSNotification *)n {
    
}

- (void)activityGameDidEnd: (NSNotification *)n {
    [self nextDay];
    self.gameState = JusikGamePlayStateStock;
    [self play];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initStatusBar];
    [self.view addSubview: self.statusBarMenuView];
    [self.statusBarMenuView addSubview: self.menuView];
    UIImage *menuImage = [UIImage imageNamed: @"Images/sidebar_sidebar.png"];
    if(menuImage)
        self.statusBarMenuView.backgroundColor = [UIColor colorWithPatternImage: menuImage];
    UIImage *buttonImage = [UIImage imageNamed: @"Images/sidebar_button_down.png"];
    if(buttonImage)
        self.statusBarController.statusBarButton.backgroundColor = [UIColor colorWithPatternImage: buttonImage];
    
    
    JusikPlayerInfoViewController *pi = [[JusikPlayerInfoViewController alloc] initWithNibName:@"JusikPlayerInfoViewController" bundle: nil];
    self.piViewController = pi;
    [pi release];
    
    [self _layoutViews];
    
    self.gameState = JusikGamePlayStateStock;
    
    [self nextDay];
    [self play];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.statusBarMenuView = nil;
    self.menuView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 비공개 메서드
- (void)_initStatusBar {
    JusikStatusBarController *bar = [[JusikStatusBarController alloc] initWithNibName: @"JusikStatusBarController" bundle: nil];
    self.statusBarController = bar;
    [bar release];
    
    [self.statusBarMenuView addSubview: bar.view];
    
    self.statusBarController.player = self.player;
    self.statusBarController.market = self.market;
}

- (void)_layoutViews {
    CGRect menuViewFrame;
    CGRect statViewFrame;
    CGRect statusBarFrame;
    CGRect barMenuViewFrame;
    
    menuViewFrame = self.menuView.frame;
    statViewFrame = self.piViewController.view.frame;
    statusBarFrame = self.statusBarController.view.frame;
    barMenuViewFrame = self.statusBarMenuView.frame;
    
    // BarMenuView
    if(_showingMenu) {
        barMenuViewFrame.origin.y = 0;
    }
    else {
        barMenuViewFrame.origin.y = -barMenuViewFrame.size.height + statusBarFrame.size.height;
    }
    
    self.statusBarMenuView.frame = barMenuViewFrame;
    
    // Menu View
    menuViewFrame.size.width = barMenuViewFrame.size.width / 3;
    menuViewFrame.size.height = barMenuViewFrame.size.height - statusBarFrame.size.height;
    menuViewFrame.origin.x = barMenuViewFrame.size.width - menuViewFrame.size.width;
    menuViewFrame.origin.y = 0;
    self.menuView.frame = menuViewFrame;
    
    // Stat View
    statViewFrame.size.width = barMenuViewFrame.size.width / 3 * 2;
    statViewFrame.size.height = barMenuViewFrame.size.height - statusBarFrame.size.height;
    statViewFrame.origin.x = 0;
    statViewFrame.origin.y = 0;
    self.piViewController.view.frame = statViewFrame;
    
    // Status Bar
    statusBarFrame.origin.x = 0;
    statusBarFrame.origin.y = barMenuViewFrame.size.height - statusBarFrame.size.height;
    self.statusBarController.view.frame = statusBarFrame;
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_market release];
    [_player release];
    [_date release];
    
    self.statusBarController = nil;
    self.piViewController = nil;
    self.stockGameController = nil;
    self.activityGameController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super dealloc];
}

@end

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
#import "JusikScript.h"
#import "JusikScriptViewController.h"
#import "JusikDBManager.h"
#import "JusikCore.h"

@interface JusikGameViewController (Private)
- (void)_setupNotifications;
- (void)_initStatusBar;
- (void)_initStatusBarMenuView;
- (void)_initConfirmViews;
- (void)_layoutViews;
@end

@implementation JusikGameViewController {
    BOOL _showingMenu;
    BOOL _showingConfirmView;
    UIViewController<JusikGameController> *_currentGameController;
}

@synthesize market = _market;
@synthesize player = _player;

@synthesize gameState = _gameState;
@synthesize date = _date;
@synthesize turn = _turn;

@synthesize showsTutorial = _showsTutorial;
@synthesize tutorialScript = _tutorialScript;
@synthesize scriptViewController = _scriptViewController;

@synthesize db = _db;

@synthesize statusBarController = _statusBarController;
@synthesize viewController = _viewController;
@synthesize piViewController = _piViewController;

@synthesize stockGameController = _stockGameController;
@synthesize activityGameController = _activityGameController;

@synthesize contentView = _contentView;
@synthesize statusBarMenuView = _statusBarMenuView;
@synthesize menuView = _menuView;

@synthesize exitConfirmView = _exitConfirmView;

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
        
        // Stock Game View
        JusikStockGameViewController *stockGame = [[JusikStockGameViewController alloc] initWithNibName: @"JusikStockGameViewController" bundle: nil];
        self.stockGameController = stockGame;
        [stockGame release];
        
        // Activity Game View
        JusikActivityGameViewController *activityGame = [[JusikActivityGameViewController alloc] initWithNibName: @"JusikActivityGameViewController" bundle: nil];
        self.activityGameController = activityGame;
        [activityGame release];
        
        // Status Bar
        JusikStatusBarController *bar = [[JusikStatusBarController alloc] initWithNibName: @"JusikStatusBarController" bundle: nil];
        self.statusBarController = bar;
        [bar release];
        
        // Player Info
        JusikPlayerInfoViewController *pi = [[JusikPlayerInfoViewController alloc] initWithNibName:@"JusikPlayerInfoViewController" bundle: nil];
        self.piViewController = pi;
        [pi release];
        
        // set default game state
        self.gameState = JusikGamePlayStateNone;
        _showsTutorial = YES;
        
        // Setup Notifications
        [self _setupNotifications];
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

- (JusikScriptViewController *)scriptViewController {
    return _scriptViewController;
}

- (void)setScriptViewController:(JusikScriptViewController *)scriptViewController {
    [scriptViewController retain];
    [_scriptViewController release];
    _scriptViewController = scriptViewController;
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
    self.stockGameController.player = player;
}

- (JusikStockMarket *)market {
    return _market;
}

- (void)setMarket:(JusikStockMarket *)market {
    [market retain];
    [_market release];
    _market = market;
    
    self.statusBarController.market = market;
    self.stockGameController.market = market;
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
    if(gameState == JusikGamePlayStateStock)
        self.statusBarController.mode = JusikStatusBarModeStockTime;
    else if(gameState == JusikGamePlayStateActivity)
        self.statusBarController.mode = JusikStatusBarModeActivity;
    
    // 뷰 전환
    UIViewController<JusikGameController> *gameController = nil;
    if(self.gameState == JusikGamePlayStateStock) {
        gameController = self.stockGameController;
    }
    else if(self.gameState == JusikGamePlayStateActivity) {
        gameController = self.activityGameController;
    }
    else {
        gameController = nil;
    }
    [_currentGameController stop];
    
    double delay = 0;
    if(_currentGameController) {
        UIViewController<JusikGameController> *vc = _currentGameController;
        [UIView animateWithDuration: kJusikViewFadeTime
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             vc.view.alpha = 0;
                         }
                         completion: ^(BOOL completed) {
                             [vc.view removeFromSuperview];
                         }];

        delay = kJusikViewFadeTime;
    }
    
    if(gameController) {
        gameController.view.alpha = 0;
        [self.contentView addSubview: gameController.view];
        [UIView animateWithDuration: kJusikViewFadeTime
                              delay: delay
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             gameController.view.alpha = 1;
                         }
                         completion: ^(BOOL completed) {
                             _currentGameController = gameController;
                         }];
    }
}

- (JusikDBManager *)db {
    return _db;
}

- (void)setDb:(JusikDBManager *)db {
    [db retain];
    [_db release];
    _db = db;
    
    self.stockGameController.db = _db;
    self.activityGameController.db = _db;
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
            if(_showingMenu)
                [self.activityGameController pause];
            else
                [self.activityGameController resume];
            break;
        default:
            break;
    }
}

- (void)exitGame:(id)sender {
    _showingConfirmView = NO;
    [self.viewController exitGame];
}

- (IBAction)showExitConfirmView:(id)sender {
    _showingConfirmView = YES;
    [self.view addSubview: self.exitConfirmView];
    CGRect frame = self.exitConfirmView.frame;
    CGRect viewFrame = self.view.frame;
    frame.origin.x = (viewFrame.size.width - frame.size.width) * 0.5;
    frame.origin.y = (viewFrame.size.height - frame.size.height) * 0.5;
    self.exitConfirmView.frame = frame;
}

- (IBAction)cancelExit:(id)sender {
    _showingConfirmView = NO;
    [self.exitConfirmView removeFromSuperview];
}

- (void)play {
    if(self.showsTutorial && self.tutorialScript) {
        [self showTutorial];
        return;
    }
    
    [self nextDay];
    
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
    
    self.gameState = JusikGamePlayStateNone;
    
    // show attention
    UIImage *attentionImage = [UIImage imageNamed: @"Images/attention.png"];
    UIImageView *attentionView = [[UIImageView alloc] initWithImage: attentionImage];
    attentionView.frame = self.view.frame;
    [self.view addSubview: attentionView];
    attentionView.alpha = 0;
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0
                        options: UIViewAnimationCurveEaseOut
                     animations: ^{
                         attentionView.alpha = 1.0;
                     }
                     completion: nil];
    
    // hide attention
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay:kJusikViewFadeTime*2+kJusikViewAttentionTime
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         attentionView.alpha = 0;
                     }
                     completion: ^(BOOL completed) {
                         // run script
                         JusikScriptViewController *vc = [[JusikScriptViewController alloc] initWithNibName: @"JusikScriptViewController" bundle: nil];
                         self.scriptViewController = vc;
                         [vc release];
                         [self.contentView addSubview: vc.view];
                         
                         [[NSNotificationCenter defaultCenter] addObserver: self
                                                                  selector: @selector(tutorialDidEnd:)
                                                                      name: JusikScriptViewScriptDidEndNotification
                                                                    object: vc];
                         [self.scriptViewController runScript: self.tutorialScript defaultBackground: nil];
                     }];
}

- (void)tutorialDidEnd: (NSNotification *)n {
    [self.scriptViewController.view removeFromSuperview];
    self.scriptViewController = nil;
    self.showsTutorial = NO;
    self.gameState = JusikGamePlayStateStock;
    [self play];
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
    
    // for testing
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components: NSDayCalendarUnit
                                          fromDate: self.date];
    if(comp.day >= 25) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Jusikwang"
                                                            message: @"테스트는 여기까지입니다. 앞으로 더 멋지게 나올 주식왕을 기대해주세요!" 
                                                           delegate: nil
                                                  cancelButtonTitle: nil
                                                  otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        [self exitGame: self];
    }
    
    self.gameState = JusikGamePlayStateStock;
    [self play];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initStatusBarMenuView];
    [self _initStatusBar];
    [self _initConfirmViews];
    
    [self _layoutViews];
    
    self.gameState = JusikGamePlayStateNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.contentView = nil;
    self.statusBarMenuView = nil;
    self.menuView = nil;
    self.exitConfirmView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 비공개 메서드
- (void)_setupNotifications {
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

- (void)_initStatusBar {
    [self.statusBarMenuView addSubview: self.statusBarController.view];
        
    self.statusBarController.player = self.player;
    self.statusBarController.market = self.market;
    
    UIImage *buttonImage = [UIImage imageNamed: @"Images/sidebar_button_down.png"];
    if(buttonImage)
        self.statusBarController.statusBarButton.backgroundColor = [UIColor colorWithPatternImage: buttonImage];

}

- (void)_initStatusBarMenuView {
    [self.view addSubview: self.statusBarMenuView];
    [self.statusBarMenuView addSubview: self.menuView];
    [self.statusBarMenuView addSubview: self.piViewController.view];
    UIImage *menuImage = [UIImage imageNamed: @"Images/sidebar_sidebar.png"];
    if(menuImage)
        self.statusBarMenuView.backgroundColor = [UIColor colorWithPatternImage: menuImage];
}

- (void)_initConfirmViews {
    UIImage *img = [UIImage imageNamed: @"Images/confirm.png"];
    if(img) {
        self.exitConfirmView.backgroundColor = [UIColor colorWithPatternImage: img];
    }
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
    [_db release];
    
    self.statusBarController = nil;
    self.piViewController = nil;
    self.stockGameController = nil;
    self.activityGameController = nil;
    self.scriptViewController = nil;
    self.tutorialScript = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super dealloc];
}

@end

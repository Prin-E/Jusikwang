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

#import "JusikCore.h"

@interface JusikGameViewController (Private)
- (void)_initStatusBar;
- (void)_layoutViews;
@end

@implementation JusikGameViewController {
    BOOL _showingMenu;
}

@synthesize market = _market;
@synthesize player = _player;

@synthesize statusBarController = _statusBarController;
@synthesize viewController = _viewController;
@synthesize piViewController = _piViewController;
@synthesize stockGameController = _stockGameController;

@synthesize contentView = _contentView;
@synthesize statusBarMenuView = _statusBarMenuView;
@synthesize menuView = _menuView;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
}

- (JusikPlayer *)player {
    return _player;
}

- (void)setPlayer:(JusikPlayer *)player {
    [player retain];
    [_player release];
    _player = player;
    
    self.statusBarController.player = player;
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

#pragma mark 메모리 관리
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 액션
- (void)showMenu:(id)sender {
    [UIView beginAnimations: @"JusikGameViewShowMenu" context: nil];
    [UIView setAnimationDuration: kJusikViewFadeTime];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
    
    CGRect frame = self.statusBarMenuView.frame;
    if(_showingMenu) {
        frame.origin.y = -frame.size.height + self.statusBarController.view.frame.size.height;
    }
    else {
        frame.origin.y = 0.0;
    }
    self.statusBarMenuView.frame = frame;
    
    [UIView commitAnimations];
    
    _showingMenu = !_showingMenu;
}

- (void)exitGame:(id)sender {
    [self.viewController exitGame];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initStatusBar];
    [self.view addSubview: self.statusBarMenuView];
    [self.statusBarMenuView addSubview: self.menuView];
    
    JusikPlayerInfoViewController *pi = [[JusikPlayerInfoViewController alloc] initWithNibName:@"JusikPlayerInfoViewController" bundle: nil];
    self.piViewController = pi;
    [pi release];
    
    [self _layoutViews];
    
    JusikPlayer *player = [[JusikPlayer alloc] initWithName: @"test"
                                               initialMoney: 5000000
                                               intelligence: 50
                                               fatigability: 50
                                                reliability: 50];
    self.player = player;
    [player release];
    
    JusikStockMarket *market = [[JusikStockMarket alloc] initWithInitialDateWithYear: 2011
                                                                               month: 11
                                                                                 day: 10];
    self.market = market;
    [market release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 비공개 메서드
- (void)_initStatusBar {
    JusikStatusBarController *bar = [[JusikStatusBarController alloc] initWithNibName: @"JusikStatusBarController" bundle: nil];
    self.statusBarController = bar;
    [bar release];
    
    [self.statusBarMenuView addSubview: bar.view];
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
    
    self.statusBarController = nil;
    self.piViewController = nil;
    
    [super dealloc];
}

@end

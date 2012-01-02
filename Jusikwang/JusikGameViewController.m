//
//  JusikGameViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 2..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikGameViewController.h"
#import "JusikStatusBarController.h"
#import "JusikUIDataTypes.h"

#import "JusikCore.h"

@implementation JusikGameViewController
@synthesize market = _market;
@synthesize player = _player;

@synthesize statusBarController = _statusBarController;
@synthesize contentView = _contentView;
@synthesize statusBarMenuView = _statusBarMenuView;

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
    
    CGRect frame = self.statusBarController.view.frame;
    frame.origin.y = self.statusBarMenuView.frame.size.height - frame.size.height;
    self.statusBarController.view.frame = frame;
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

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    JusikStatusBarController *bar = [[JusikStatusBarController alloc] initWithNibName: @"JusikStatusBarController" bundle: nil];
    self.statusBarController = bar;
    [bar release];
    
    [self.view addSubview: self.statusBarMenuView];
    CGRect frame = self.statusBarMenuView.frame;
    frame.origin.y = -frame.size.height + self.statusBarController.view.frame.size.height;
    self.statusBarMenuView.frame = frame;
    
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
    
    self.statusBarController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 메모리 해제
- (void)dealloc {
    [_market release];
    [_player release];
    
    self.statusBarController = nil;
    [super dealloc];
}

@end

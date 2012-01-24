//
//  JusikViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 24..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikViewController.h"
#import "JusikLogoViewController.h"
#import "JusikMainMenuViewController.h"
#import "JusikGameViewController.h"
#import "JusikUIDataTypes.h"
#import "JusikLoadingViewController.h"
#import "JusikBGMPlayer.h"

@implementation JusikViewController {
@private
    UIViewController *_currentViewController;
}

@synthesize logoViewController = _logoViewController;
@synthesize mainMenuViewController = _mainMenuViewController;
@synthesize gameViewController = _gameViewController;
@synthesize loadingViewController = _loadingViewController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUserDefaults];
    [self setupBGMVolume];
    [self showLogoView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.logoViewController = nil;
    self.mainMenuViewController = nil;
    self.gameViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark BGM
- (void)setupUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity: 2];
    [d setObject: [NSNumber numberWithDouble: 0.5] forKey: @"volume_bgm"];
    [d setObject: [NSNumber numberWithDouble: 0.5] forKey: @"volume_sound"];
    [defaults registerDefaults: d];
}

- (void)setupBGMVolume {
    JusikBGMPlayer *player = [JusikBGMPlayer sharedPlayer];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *volume = [defaults objectForKey: @"volume_bgm"];
    if(volume) {
        player.volume = [volume doubleValue];
    }
}

#pragma mark 게임 시작
- (void)startNewGame:(id)sender {
    [self hideMainMenuView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * kJusikViewFadeTime), dispatch_get_current_queue(), ^ {
        
        JusikLoadingViewController *vc = [[JusikLoadingViewController alloc] initWithNibName: @"JusikLoadingViewController" 
                                                                                      bundle: nil];
        self.loadingViewController = vc;
        [vc release];
        
        [self.view addSubview: vc.view];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(gameLoadDidComplete:)
                                                     name: JusikLoadingViewLoadDidCompleteNotification
                                                   object: vc];
        
        // 임시 땜빵
        // 왜 UIViewController asynchronous 로딩이 제대로 안되냐...
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_current_queue(), ^(void){
            [vc loadWithDBName: @"game.db"];
        });
    });
}

- (void)startGame:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Jusikwang", @"Jusikwang")
                                                    message: NSLocalizedString(@"com.jusikwang.main_menu.not_support_start_game", @"com.jusikwang.main_menu.not_support_start_game")
                                                   delegate: nil
                                          cancelButtonTitle: NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)gameLoadDidComplete: (NSNotification *)n {
    [UIView animateWithDuration: kJusikViewFadeTime
                     animations: ^{
                         self.loadingViewController.view.alpha = 0;
                     }
                     completion: ^(BOOL completed) {
                         self.gameViewController = self.loadingViewController.gameViewController;
                         self.loadingViewController = nil;
                         self.gameViewController.viewController = self;
                         self.gameViewController.view.alpha = 0;
                         [self.view addSubview: self.gameViewController.view];
                         [UIView animateWithDuration: kJusikViewFadeTime
                                          animations: ^{
                                              self.gameViewController.view.alpha = 1;
                                          }
                                          completion: ^(BOOL completed) {
                                              self.gameViewController.view.alpha = 1;
                                              [self.gameViewController play];
                                          }];
                         
                     }];
    
}

- (void)exitGame {
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.gameViewController.view.alpha = 0;
                     }
                     completion: ^(BOOL complete) {
                         self.gameViewController = nil;
                         [self showMainMenuView];
                     }];
}

#pragma mark 메인 뷰 보이기
- (void)showMainMenuView {
    if(self.mainMenuViewController == nil) {
        JusikMainMenuViewController *vc = [[JusikMainMenuViewController alloc] initWithNibName: @"JusikMainMenuViewController"
                                                                                        bundle: nil];
        self.mainMenuViewController = vc;
        [vc release];
        
    }
    self.mainMenuViewController.view.alpha = 0;
    [self.view addSubview: self.mainMenuViewController.view];
    
    [self.mainMenuViewController.startNewGameButton addTarget: self
                                                       action: @selector(startNewGame:)
                                             forControlEvents: UIControlEventTouchUpInside];
    [self.mainMenuViewController.startGameButton addTarget: self
                                                    action: @selector(startGame:)
                                          forControlEvents: UIControlEventTouchUpInside];
    
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.mainMenuViewController.view.alpha = 1.0;
                     }
                     completion: ^(BOOL complete) {
                         _currentViewController = self.mainMenuViewController;
                     }];
    [self.mainMenuViewController showMainMenuAnimation];
    
    [[JusikBGMPlayer sharedPlayer] playMusic: JusikBGMMusicMainMenu];
}

- (void)hideMainMenuView {
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.mainMenuViewController.view.alpha = 0.0;
                     }
                     completion: ^(BOOL complete) {
                         _currentViewController = nil;
                         [self.mainMenuViewController.view removeFromSuperview];
                     }];
}

#pragma mark 로고 뷰 보이기/숨기기
- (void)showLogoView {
    JusikLogoViewController *logoViewController = [[JusikLogoViewController alloc] initWithNibName:@"JusikLogoViewController" bundle: nil];
    self.logoViewController = logoViewController;
    [logoViewController release];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self 
           selector: @selector(logoAnimationDidEnd:)
               name: JusikLogoViewAnimationDidEndNotification
             object: self.logoViewController];
    
    self.logoViewController.view.alpha = 0.0;
    [self.view addSubview: logoViewController.view];
    
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.logoViewController.view.alpha = 1.0;
                     }
                     completion: ^(BOOL complete) {
                         _currentViewController = self.logoViewController;
                         [self.logoViewController performSelector: @selector(showLogos) 
                                                       withObject: nil];
                     }];
    
}

- (void)hideLogoView {
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.logoViewController.view.alpha = 0.0;
                     }
                     completion: ^(BOOL complete) {
                         _currentViewController = nil;
                         [self.logoViewController.view removeFromSuperview];
                         self.logoViewController = nil;
                         [self performSelector: @selector(showMainMenuView) 
                                    withObject: nil];
                     }];
}

#pragma mark - 노티피케이션
- (void)logoAnimationDidEnd:(NSNotification *)n {
    [self hideLogoView];
}

@end

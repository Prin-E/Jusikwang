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

@implementation JusikViewController {
@private
    UIViewController *_currentViewController;
}

@synthesize logoViewController = _logoViewController;
@synthesize mainMenuViewController = _mainMenuViewController;
@synthesize gameViewController = _gameViewController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark 게임 시작
- (void)startNewGame:(id)sender {
    [self hideMainMenuView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * kJusikViewFadeTime), dispatch_get_current_queue(), ^ {
        JusikGameViewController *vc = [[JusikGameViewController alloc] initWithNibName: @"JusikGameViewController" bundle: nil];
        self.gameViewController = vc;
        [vc release];
        
        self.gameViewController.viewController = self;
        
        [self.view addSubview: vc.view];
    });
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
    
    [UIView animateWithDuration: kJusikViewFadeTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.mainMenuViewController.view.alpha = 1.0;
                     }
                     completion: ^(BOOL complete) {
                         _currentViewController = self.mainMenuViewController;
                     }];
    [self.mainMenuViewController showAnimation];
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

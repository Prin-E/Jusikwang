//
//  JusikMainMenuViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 29..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikMainMenuViewController.h"
#import "JusikUIDataTypes.h"

@interface JusikMainMenuViewController (Private)
- (void)_translateCurrentViewToView: (UIView *)view2;
@end

@implementation JusikMainMenuViewController {
    IBOutlet UIImageView *logoImageView;
    UIView *_currentView;
}
@synthesize startGameButton = _startGameButton;
@synthesize startNewGameButton = _startNewGameButton;
@synthesize mainMenuView = _mainMenuView;
@synthesize preferenceView = _preferenceView;
@synthesize creditView = _creditView;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview: self.mainMenuView];
    _currentView = self.mainMenuView;
    
    UIImage *optionImage = [UIImage imageNamed: @"Images/option_option.png"];
    if(optionImage)
        _preferenceView.backgroundColor = [UIColor colorWithPatternImage: optionImage];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.startNewGameButton = nil;
    self.mainMenuView = nil;
    self.preferenceView = nil;
    self.creditView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 뷰간 전환
- (void)changeToMainMenuView {
    [self _translateCurrentViewToView: _mainMenuView];
}

- (void)showPreferences:(id)sender {
    [self _translateCurrentViewToView: _preferenceView];
}

- (void)showCredit:(id)sender {
    [self _translateCurrentViewToView: _creditView];
}

- (void)backToMainMenu:(id)sender {
    [self changeToMainMenuView];
    [self showMainMenuAnimation];
}

- (void)_translateCurrentViewToView: (UIView *)view2 {
    UIView *prevView = _currentView;
    view2.alpha = 0;
    [self.view addSubview: view2];
    [UIView animateWithDuration: kJusikViewFadeTime
                     animations: ^{
                         prevView.alpha = 0;
                     }
                     completion: ^(BOOL finished) {
                         [prevView removeFromSuperview];
                     }];
    [UIView animateWithDuration: kJusikViewFadeTime
                     animations: ^{
                         view2.alpha = 1;
                     }
                     completion: ^(BOOL completed) {
                         _currentView = view2;
                     }];
}

#pragma mark - 애니메이션
- (void)showMainMenuAnimation {
    logoImageView.alpha = 0.0;
    CGRect toFrame = logoImageView.frame;
    CGRect fromFrame = toFrame;
    fromFrame.origin.y -= fromFrame.size.height * 0.25;
    logoImageView.frame = fromFrame;
    
    [UIView animateWithDuration: 0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         logoImageView.alpha = 1.0;
                         logoImageView.frame = toFrame;
                     }
                     completion: ^(BOOL completed) {
                         if(completed == NO)
                             logoImageView.frame = toFrame;
                     }];
}

@end

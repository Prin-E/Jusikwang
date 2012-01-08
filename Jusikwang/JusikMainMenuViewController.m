//
//  JusikMainMenuViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 29..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikMainMenuViewController.h"
#import "JusikUIDataTypes.h"

@implementation JusikMainMenuViewController {
    IBOutlet UIImageView *logoImageView;
    UIView *_currentView;
}
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)changeToMainMenuView {
    [UIView transitionFromView: _currentView
                        toView: _mainMenuView
                      duration: kJusikViewFadeTime
                       options: UIViewAnimationOptionCurveEaseOut
                    completion: ^(BOOL completed) {
                        
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

//
//  JusikLogoViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 28..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikLogoViewController.h"
#import "JusikUIDataTypes.h"

NSString *JusikLogoViewAnimationDidEndNotification = @"JusikLogoViewAnimationDidEndNotification";

@implementation JusikLogoViewController
@synthesize logoImageView = _logoImageView;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark 메모리 관리
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.logoImageView = nil;
}

#pragma mark - 로고 애니메이션
- (void)showLogos {
    [self show3DsLogo];
    
}
- (void)show3DsLogo {
    self.logoImageView.alpha = 0.0;
    
    UIImage *image = [UIImage imageNamed: @"Images/team3Ds.png"];
    [self.logoImageView setImage: image];
    
    [self performSelector: @selector(fadeIn:) withObject: nil];
}

- (void)fadeIn:(id)object {
    [UIView animateWithDuration: kJusikViewFadeInTime
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         self.logoImageView.alpha = 1.0;
                     }
                     completion: ^(BOOL finished) {
                         [self performSelector: @selector(receiveTouch:) 
                                    withObject: nil];
                         
                         [self performSelector: @selector(fadeOut:) 
                                    withObject: nil
                                    afterDelay: kJusikLogoViewIdleTime];
                     }];
}

- (void)receiveTouch: (id)object {
    _canReceiveTouch = YES;
}

- (void)fadeOut:(id)object {
    [UIView animateWithDuration: kJusikViewFadeOutTime 
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^ {
                         self.logoImageView.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         [self postEndNotification: self];
                     }];
}

- (void)postEndNotification:(id)object {
    if(_isPosted == NO) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotification: [NSNotification notificationWithName: JusikLogoViewAnimationDidEndNotification
                                                        object: self]];
        _isPosted = YES;
    }
}

#pragma mark - 터치 이벤트
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_canReceiveTouch) {
        [self fadeOut: nil];
        NSLog(@"touches!");
    }
}

@end

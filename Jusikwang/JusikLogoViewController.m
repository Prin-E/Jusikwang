//
//  JusikLogoViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 28..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikLogoViewController.h"

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
    
    [self show3DsLogo];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.logoImageView = nil;
}

#pragma mark - 로고 애니메이션
- (void)show3DsLogo {
    self.logoImageView.alpha = 0.0;
    
    UIImage *image = [UIImage imageNamed: @"Images/team3Ds.png"];
    [self.logoImageView setImage: image];
    
    NSTimer *fadeOutTimer = [NSTimer timerWithTimeInterval: 1.0
                                                    target: self
                                                  selector: @selector(fadeIn:)
                                                  userInfo: nil
                                                   repeats: NO];
    [[NSRunLoop currentRunLoop] addTimer: fadeOutTimer forMode: NSDefaultRunLoopMode];
}

- (void)fadeIn:(id)object {
    [UIView beginAnimations: @"JusikLogoViewAnimationTeam3Ds" context: nil];
    [UIView setAnimationDuration: 1.0f];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    
    self.logoImageView.alpha = 1.0f;
    
    [UIView commitAnimations];
    
    NSTimer *fadeOutTimer = [NSTimer timerWithTimeInterval: 3.0
                                                    target: self
                                                  selector: @selector(fadeOut:)
                                                  userInfo: nil
                                                   repeats: NO];
    [[NSRunLoop currentRunLoop] addTimer: fadeOutTimer forMode: NSDefaultRunLoopMode];
    
}

- (void)fadeOut:(id)object {
    [UIView beginAnimations: @"JusikLogoViewAnimationTeam3Ds" context: nil];
    [UIView setAnimationDuration: 1.0f];
    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
    
    self.logoImageView.alpha = 0.0f;
    
    [UIView commitAnimations];
    
    NSTimer *fadeOutTimer = [NSTimer timerWithTimeInterval: 1.0
                                                    target: self
                                                  selector: @selector(postEndNotification:)
                                                  userInfo: nil
                                                   repeats: NO];
    [[NSRunLoop currentRunLoop] addTimer: fadeOutTimer forMode: NSDefaultRunLoopMode];
}

- (void)postEndNotification:(id)object {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotification: [NSNotification notificationWithName: JusikLogoViewAnimationDidEndNotification
                                                        object: self]];
}

@end

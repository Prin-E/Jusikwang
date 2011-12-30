//
//  JusikViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 11. 12. 24..
//  Copyright (c) 2011 서울시립대학교. All rights reserved.
//

#import "JusikViewController.h"
#import "JusikLogoViewController.h"

@implementation JusikViewController
@synthesize logoViewController = _logoViewController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [UIView beginAnimations: @"JusikViewLogoAnimationBegin" context: nil];
    [UIView setAnimationDuration: 0.5];
    self.logoViewController.view.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.logoViewController = nil;
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

#pragma mark - 노티피케이션
- (void)logoAnimationDidEnd:(NSNotification *)n {
    [UIView beginAnimations: @"JusikViewLogoAnimationBegin" context: nil];
    [UIView setAnimationDuration: 0.5];
    [self.logoViewController.view removeFromSuperview];
    self.logoViewController = nil;
    [UIView commitAnimations];
    
    
}

@end

//
//  JusikPlayerInfoViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikPlayerInfoViewController.h"
#import "SlidingTabsControl.h"
#import "JusikPlayer.h"

@implementation JusikPlayerInfoViewController
@synthesize tab = _tab;
@synthesize player = _player;

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - SlidingTabsControl

- (UILabel*) labelFor:(SlidingTabsControl*)slidingTabsControl atIndex:(NSUInteger)tabIndex {
    UILabel *label = [[[UILabel alloc] init] autorelease];
    switch(tabIndex) {
        case 0:
            label.text = @"Stat";
            break;
        case 1:
            label.text = @"News";
            break;
    }
    return label;
}

- (void) touchUpInsideTabIndex:(NSUInteger)tabIndex {
    
}

- (void) touchDownAtTabIndex:(NSUInteger)tabIndex {
    
}

@end

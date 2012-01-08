//
//  JusikActivityGameViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikActivityGameViewController.h"
#import "JusikBGMPlayer.h"

NSString *const JusikActivityGameViewGameDidStartNotification = @"JusikActivityGameViewGameDidStartNotification";
NSString *const JusikActivityGameViewGameDidStopNotification = @"JusikActivityGameViewGameDidStopNotification";

@implementation JusikActivityGameViewController
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

#pragma mark - 게임
- (void)play {
    [[JusikBGMPlayer sharedPlayer] playMusic: JusikBGMMusicActivity];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStartNotification object: nil];
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStopNotification object: nil];
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end

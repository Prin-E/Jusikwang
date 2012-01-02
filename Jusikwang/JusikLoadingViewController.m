//
//  JusikLoadingViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 3..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikLoadingViewController.h"
#import "JusikStockMarket.h"
#import "JusikPlayer.h"

@implementation JusikLoadingViewController {
    JusikStockMarket *_market;
    JusikPlayer *_player;
    
    BOOL _isLoading;
    
    NSUInteger _loadedElements;
    NSUInteger _allElements;
}
@synthesize market = _market;
@synthesize player = _player;

@synthesize progressView = _progressView;
@synthesize imageView = _imageView;

#pragma mark - 초기화 메서드
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

- (BOOL)load {
    if(_isLoading) return NO;
    
    _allElements = 3;
    _loadedElements = 0;
    
    
    return YES;
}

@end

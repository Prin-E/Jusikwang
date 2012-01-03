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
@synthesize contentView = _contentView;

@synthesize statView = _statView;
@synthesize statPlayerName = _statPlayerName;
@synthesize statAssetText = _statAssetText;
@synthesize statIntelligenceText = _statIntelligenceText;
@synthesize statReliabilityText = _statReliabilityText;
@synthesize statFatigabilityText = _statFatigabilityText;
@synthesize newsHistoryView = _newsHistoryView;
@synthesize player = _player;

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

#pragma mark - 프로퍼티 메서드
- (JusikPlayer *)player {
    return _player;
}

- (void)setPlayer:(JusikPlayer *)player {
    if(_player == player) return;
    
    [_player removeObserver: self
                 forKeyPath: @"money"];
    [_player removeObserver: self
                 forKeyPath: @"intelligence"];
    [_player removeObserver: self
                 forKeyPath: @"reliability"];
    [_player removeObserver: self
                 forKeyPath: @"fatigability"];
    
    [player retain];
    [_player release];
    _player = player;
    
    [_player addObserver: self
              forKeyPath: @"money"
                 options: NSKeyValueObservingOptionNew
                 context: nil];
    [_player addObserver: self
              forKeyPath: @"intelligence"
                 options: NSKeyValueObservingOptionNew
                 context: nil];
    [_player addObserver: self
              forKeyPath: @"reliability"
                 options: NSKeyValueObservingOptionNew
                 context: nil];
    [_player addObserver: self
              forKeyPath: @"fatigability"
                 options: NSKeyValueObservingOptionNew
                 context: nil];
    
    [self updateStat];
    
}

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (id)object 
                        change: (NSDictionary *)change 
                       context: (void *)context {
    if(object == self.player) {
        NSNumber *val = [change objectForKey: NSKeyValueChangeNewKey];
        NSUInteger number = [val unsignedIntegerValue];
        if([keyPath isEqualToString: @"money"]) {
            self.statAssetText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Asset", @"Asset"), number];
        }
        else if([keyPath isEqualToString: @"intelligence"]) {
            self.statIntelligenceText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Intelligence", @"Intelligence"), number];
        }
        else if([keyPath isEqualToString: @"reliability"]) {
            self.statReliabilityText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Reliability", @"Reliability"), number];
        }
        else if([keyPath isEqualToString: @"fatigability"]) {
            self.statFatigabilityText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Fatigability", @"Fatigability"), number];
        }
    }
}

- (void)updateStat {
    self.statAssetText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Asset", @"Asset"), self.player.money];
    self.statIntelligenceText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Intelligence", @"Intelligence"), self.player.intelligence];
    self.statReliabilityText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Reliability", @"Reliability"), self.player.reliability];
    self.statFatigabilityText.text = [NSString stringWithFormat: @"%@ : %d", NSLocalizedString(@"Fatigability", @"Fatigability"), self.player.fatigability];

}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tab.tabCount = 2;
    self.tab.delegate = self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.tab = nil;
    self.statView = nil;
    self.newsHistoryView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_player release];
    
    [super dealloc];
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
    switch(tabIndex) {
        case 0:
            [self.newsHistoryView removeFromSuperview];
            [self.contentView addSubview: self.statView];
            break;
        case 1:
            [self.statView removeFromSuperview];
            [self.contentView addSubview: self.newsHistoryView];
            break;
    }
}

- (void) touchDownAtTabIndex:(NSUInteger)tabIndex {
    
}

@end

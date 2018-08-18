//
//  JusikStatusBarController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 1..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikStatusBarController.h"
#import "JusikStockMarket.h"
#import "JusikPlayer.h"
#import "JusikUIDataTypes.h"

@interface JusikStatusBarController (Private)
- (void)_showMessageView;
- (void)_hideMessageView;
- (void)_setupMessageViewTimer;
- (void)_clearMessageViewTimer;
@end

@implementation JusikStatusBarController {
    BOOL _showingMessage;
    double _messageTime;
    
    NSTimer *_messageViewTimer;
}

#pragma mark - 프로퍼티
@synthesize mode = _mode;

@synthesize market = _market;
@synthesize player = _player;

@synthesize date = _date;

@synthesize statusContainerView = _statusContainerView;
@synthesize statusBarButton = _statusBarButton;

@synthesize currentStatusView = _currentStatusView;

@synthesize stockTimeStatusView = _stockTimeStatusView;
@synthesize activityTimeStatusView = _activityTimeStatusView;

@synthesize stockTimeMoneyText = _stockTimeMoneyText;
@synthesize stockTimeKospiText = _stockTimeKospiText;
@synthesize stockTimeDowText = _stockTimeDowText;
@synthesize stockTimeExchangeText = _stockTimeExchangeText;
@synthesize stockTimeDateText = _stockTimeDateText;

@synthesize activityTimeMoneyText = _activityTimeMoneyText;
@synthesize activityTimeIntelligenceText = _activityTimeIntelligenceText;
@synthesize activityTimeReliabilityText = _activityTimeReliabilityText;
@synthesize activityTimeFatigabilityText = _activityTimeFatigabilityText;
@synthesize activityTimeDateText = _activityTimeDateText;

@synthesize messageStatusView = _messageStatusView;
@synthesize messageText = _messageText;

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
- (JusikStockMarket *)market {
    return _market;
}

- (void)setMarket:(JusikStockMarket *)market {
    if(_market != market) {
        [_market removeObserver: self forKeyPath: @"combinedPrice"];
        [_market removeObserver: self forKeyPath: @"exchangeRate"];
        [_market removeObserver: self forKeyPath: @"USStockPrice"];
        
        [market addObserver: self
                 forKeyPath: @"combinedPrice"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [market addObserver: self
                 forKeyPath: @"exchangeRate"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [market addObserver: self
                 forKeyPath: @"USStockPrice"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
    }
    
    [market retain];
    [_market release];
    _market = market;
    
    [self updateStatus];
}

- (JusikPlayer *)player {
    return _player;
}

- (void)setPlayer:(JusikPlayer *)player {
    if(_player != player) {
        
        [_player removeObserver: self forKeyPath: @"money"];
        [_player removeObserver: self forKeyPath: @"intelligence"];
        [_player removeObserver: self forKeyPath: @"reliability"];
        [_player removeObserver: self forKeyPath: @"fatigability"];
        
        [player addObserver: self
                 forKeyPath: @"money"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"intelligence"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"reliability"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
        [player addObserver: self
                 forKeyPath: @"fatigability"
                    options: NSKeyValueObservingOptionNew
                    context: nil];
    }
    
    [player retain];
    [_player release];
    _player = player;
    
    [self updateStatus];
}

- (JusikStatusBarMode)mode {
    return _mode;
}

- (void)setMode:(JusikStatusBarMode)mode {
    UIView *newView = nil;
    UIView *currentView = self.currentStatusView;
    
    if(mode == JusikStatusBarModeStockTime) {
        newView = self.stockTimeStatusView;
    }
    else if(mode == JusikStatusBarModeActivity) {
        newView = self.activityTimeStatusView;
    }
    else {
        if(_showingMessage)
            newView = self.messageStatusView;
        else
            return;
    }
    
    _mode = mode;
    
    if(self.currentStatusView && self.currentStatusView != newView) {
        __block CGRect currentViewFrame = currentView.frame;
        __block CGRect newViewFrame = newView.frame;
        
        currentViewFrame.origin.y = 0;
        newViewFrame.origin.y = newViewFrame.size.height;
        
        currentView.frame = currentViewFrame;
        newView.frame = newViewFrame;
        
        [self.statusContainerView addSubview: newView];
        newView.alpha = 0;
        currentView.alpha = 1;

        [UIView animateWithDuration: kJusikViewShowHideTime
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             currentView.alpha = 0;
                             newView.alpha = 1;
                             
                             currentViewFrame.origin.y = -currentViewFrame.size.height;
                             newViewFrame.origin.y = 0;
                             
                             currentView.frame = currentViewFrame;
                             newView.frame = newViewFrame;
                         }
                         completion: ^(BOOL completed) {
                             [currentView removeFromSuperview];
                         }];
    }
    else {
        [self.statusContainerView addSubview: newView];
    }
    self.currentStatusView = newView;
    
    [self updateStatus];
}

- (NSDate *)date {
    return [[_date copy] autorelease];
}

- (void)setDate:(NSDate *)date {
    if(_date != date) {
        [_date release];
        _date = [date copy];
        
        [self updateDate];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.statusContainerView.clipsToBounds = YES;
    self.mode = JusikStatusBarModeStockTime;
    
    UIImage *containerImage = [UIImage imageNamed: @"Images/sidebar_minibar.png"];
    if(containerImage) {
        self.statusContainerView.backgroundColor = [UIColor colorWithPatternImage: containerImage];
        self.messageStatusView.backgroundColor = [UIColor colorWithPatternImage: containerImage];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.statusContainerView = nil;
    self.statusBarButton = nil;
    
    self.stockTimeStatusView = nil;
    self.activityTimeStatusView = nil;
    
    self.stockTimeMoneyText = nil;
    self.stockTimeKospiText = nil;
    self.stockTimeDowText = nil;
    self.stockTimeExchangeText = nil;
    self.stockTimeDateText = nil;
    
    self.activityTimeMoneyText = nil;
    self.activityTimeIntelligenceText = nil;
    self.activityTimeReliabilityText = nil;
    self.activityTimeFatigabilityText = nil;
    self.activityTimeDateText = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 상태 업데이트
- (void)updateStatus {
    if(_mode == JusikStatusBarModeStockTime) {
        if(self.player) {
            self.stockTimeMoneyText.text = [NSString stringWithFormat: @"%.0f", self.player.money];
        }
        else {
            self.stockTimeMoneyText.text = @"?";
        }
        
        if(self.market) {
            self.stockTimeKospiText.text = [NSString stringWithFormat: @"%.0f", self.market.combinedPrice];
            self.stockTimeDowText.text = [NSString stringWithFormat: @"%.0f", self.market.USStockPrice];
            self.stockTimeExchangeText.text = [NSString stringWithFormat: @"%.0f", self.market.exchangeRate];
        }
        else {
            self.stockTimeKospiText.text = @"?";
            self.stockTimeDowText.text = @"?";
            self.stockTimeExchangeText.text = @"?";
        }
    }
    else if(_mode == JusikStatusBarModeActivity) {
        if(self.player) {
            self.activityTimeMoneyText.text = [NSString stringWithFormat: @"%.0f", self.player.money];
            self.activityTimeIntelligenceText.text = [NSString stringWithFormat: @"%.0f", self.player.intelligence];
            self.activityTimeReliabilityText.text = [NSString stringWithFormat: @"%.0f", self.player.reliability];
            self.activityTimeFatigabilityText.text = [NSString stringWithFormat: @"%.0f", self.player.fatigability];
        }
        else {
            self.activityTimeMoneyText.text = @"?";
            self.activityTimeIntelligenceText.text = @"?";
            self.activityTimeReliabilityText.text = @"?";
            self.activityTimeFatigabilityText.text = @"?";
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    [self updateStatus];
}

- (void)updateDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd EEE"];
    self.stockTimeDateText.text = [formatter stringFromDate: _date];
    self.activityTimeDateText.text = [formatter stringFromDate: _date];
    [formatter release];
}

#pragma mark - 메시지 출력
- (void)showMessage: (NSString *)string seconds: (double)seconds {        
    self.messageText.text = string;
    
    if(seconds < 5.0)
        seconds = 5.0;
    
    _messageTime = seconds;
    [self _showMessageView];
    [self _setupMessageViewTimer];
}

#pragma mark - 비공개 메서드
- (void)_showMessageView {
    if(_showingMessage) return;
    _showingMessage = YES;
    
    __block CGRect containerViewFrame = self.statusContainerView.frame;
    __block CGRect messageViewFrame = self.messageStatusView.frame;
    
    messageViewFrame.origin.x = 0;
    messageViewFrame.origin.y = messageViewFrame.size.height;
    self.messageStatusView.frame = messageViewFrame;
    [self.view addSubview: self.messageStatusView];
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         containerViewFrame.origin.y = -containerViewFrame.size.height;
                         messageViewFrame.origin.y = 0;
                         self.statusContainerView.frame = containerViewFrame;
                         self.messageStatusView.frame = messageViewFrame;
                     }
                     completion: ^(BOOL finished) {
                     }];
}

- (void)_hideMessageView {
    if(_showingMessage == NO) return;
    _showingMessage = NO;
    
    __block CGRect containerViewFrame = self.statusContainerView.frame;
    __block CGRect messageViewFrame = self.messageStatusView.frame;
    
    [UIView animateWithDuration: kJusikViewShowHideTime
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         containerViewFrame.origin.y = 0;
                         messageViewFrame.origin.y = messageViewFrame.size.height;
                         self.statusContainerView.frame = containerViewFrame;
                         self.messageStatusView.frame = messageViewFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.messageStatusView removeFromSuperview];
                     }];
}

- (void)_setupMessageViewTimer {
    [self _clearMessageViewTimer];
    
    _messageViewTimer = [NSTimer scheduledTimerWithTimeInterval: _messageTime
                                                         target: self
                                                       selector: @selector(_hideMessageView)
                                                       userInfo: nil
                                                        repeats: NO];
    [_messageViewTimer retain];
}

- (void)_clearMessageViewTimer {
    if(_messageViewTimer) {
        [_messageViewTimer invalidate];
        [_messageViewTimer release];
        _messageViewTimer = nil;
    }
}

#pragma mark - 메모리 해제
- (void)dealloc {
    self.market = nil;
    self.player = nil;
    self.date = nil;
    
    [super dealloc];
}

@end

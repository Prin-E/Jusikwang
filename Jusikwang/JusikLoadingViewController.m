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
#import "JusikDBManager.h"
#import "JusikCompanyInfo.h"
#import "JusikStock.h"
#import "JusikGameViewController.h"
#import "JusikBGMPlayer.h"
#import "JusikScript.h"

NSString *const JusikLoadingViewLoadDidCompleteNotification = @"JusikLoadingViewLoadDidCompleteNotification";

@implementation JusikLoadingViewController {
    JusikStockMarket *_market;
    JusikPlayer *_player;
    
    BOOL _isLoading;
    
    NSUInteger _countOfObjects;
    NSUInteger _loadedObjects;
}
@synthesize market = _market;
@synthesize player = _player;
@synthesize gameViewController = _gameViewController;

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
    
    self.progressView = nil;
    self.imageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)updateProgress {
    _loadedObjects++;
    [self.progressView setProgress: (double)_loadedObjects / (double)_countOfObjects];
}

- (BOOL)loadWithDBName:(NSString *)dbName {
    if(_isLoading) return NO;
    
    JusikDBManager *db = [[JusikDBManager alloc] initWithDBNamed: dbName];
    
    // 어떠한 객체를 로딩할 것인지 결정한다.
    // 대표적으로 읽어야 될 것은 플레이어 상태, 기업, 레코드, 게임 뷰 컨트롤러, 음악 등 있다.
    _countOfObjects += [db numberOfRowsOfTable: @"business_type"];
    _countOfObjects += [db numberOfRowsOfTable: @"company"];
    
    // Stock Market
    _countOfObjects++; // JusikStockMarket
    _countOfObjects += [db numberOfRowsOfTable: @"dow_flow"];
    
    // Player
    _countOfObjects++; // JusikPlayer
    _countOfObjects++; // GameViewController
    
    _countOfObjects += [[JusikBGMPlayer sharedPlayer] musics].count; // 음악
    _countOfObjects++; // Tutorial script
    
    // 프로그레스를 0으로 설정
    [self.progressView setProgress: 0];
    _loadedObjects = 0;
    
    
    // 로딩 시작!
    
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    
    // JusikStockMarket
    _market = [[JusikStockMarket alloc] init];
    [self updateProgress];
    
    // DOW 흐름 불러오기
    [db query: @"select e.uid as uid, e.name as name, value, type, s.name as target, start_turn, persist_turn, change_start, change_end, change_way from dow_flow as d, event as e, event_target as t, stock_market as s where d.uid = e.uid and e.target_id = t.uid and s.uid = t.target"];
    NSMutableArray *dowEvents = [NSMutableArray new];
    while([db nextRow]) {
        NSDictionary *d = [db rowData];
        JusikEvent *e = [[JusikEvent alloc] init];
        e.name = [d objectForKey: @"name"];
        e.value = [d objectForKey: @"value"];
        e.type = (JusikEventType)[[d objectForKey: @"type"] unsignedIntegerValue];
        e.targets = [NSMutableArray arrayWithObject: [d objectForKey: @"target"]];
        e.startTurn = [[d objectForKey: @"start_turn"] unsignedIntegerValue];
        e.persistTurn = [[d objectForKey: @"persist_turn"] unsignedIntegerValue];
        
        double change_start = [[d objectForKey: @"change_start"] doubleValue];
        double change_end = [[d objectForKey: @"change_end"] doubleValue];
        JusikRange change = JusikRangeMake(change_start, change_end);
        e.change = change;
        
        e.changeWay = (JusikEventChangeWay)[[d objectForKey: @"change_way"] unsignedIntegerValue];
        [dowEvents addObject: e];
        [e release];
        
        [self updateProgress];
    }
    [_market processJusikEvents: dowEvents];
    [dowEvents release];
    
    // JusikPlayer
    NSUInteger playerStateRow = [db numberOfRowsOfTable: @"player_state"];
    if(playerStateRow) {
        [db selectTable: @"player_state"];
        [db nextRow];
        double money = [db doubleColumnOfCurrentRowAtIndex: 0];
        double intelligence = [db doubleColumnOfCurrentRowAtIndex: 1];
        double reliability = [db doubleColumnOfCurrentRowAtIndex: 2];
        double fatigability = [db doubleColumnOfCurrentRowAtIndex: 3];
        
        _player = [[JusikPlayer alloc] initWithName: @"com.jusikwang.player.yuri"
                                       initialMoney: money
                                       intelligence: intelligence
                                       fatigability: fatigability
                                        reliability: reliability];
        
    }
    else {
        _player = [[JusikPlayer alloc] initWithName: @"com.jusikwang.player.yuri"
                                       initialMoney: 5000000
                                       intelligence: 50
                                       fatigability: 50 
                                        reliability: 50];
    }
    [self updateProgress];
    
    
    /* ----------------------------
     Business Type
     --------------------------- */
    NSMutableDictionary *businessTypes = [NSMutableDictionary dictionary];
    
    [db selectTable: @"business_type"];
    while([db nextRow]) {
        NSUInteger uid = [db integerColumnOfCurrentRowAtIndex: 0];
        NSString *name = [db stringColumnOfCurrentRowAtIndex: 1];
        double PER = [db doubleColumnOfCurrentRowAtIndex: 2];
        double exchangeRateEffect = [db doubleColumnOfCurrentRowAtIndex: 3];
        
        JusikBusinessType *type = [[JusikBusinessType alloc] initWithIdentifier: uid
                                                                           name: name
                                                                            PER: PER
                                                             exchangeRateEffect: exchangeRateEffect];
        [businessTypes setObject: type forKey: name];
        [type release];
        
        [self updateProgress];
    }
    
    
    /* ----------------------------
     Company
     --------------------------- */
    [db query: @"select c.uid as uid, c.name as name, capital_stock, b.name as business_type, c.detailed_business_type as detailed_business_type, c.initial_price as initial_price, c.EPS as EPS, ROE_range_start, ROE_range_end, BPS, sensitive_to_exchange_rate, sensitive_to_business_scale, sensitive_to_PBR \n"
     @"from company as c, business_type as b \n"
     @"where c.business_type = b.uid"];
    
    while([db nextRow]) {
        NSUInteger uid = [db integerColumnOfCurrentRowAtIndex: 0];
        NSString *name = [db stringColumnOfCurrentRowAtIndex: 1];
        JusikCapitalStock capitalStock = (JusikCapitalStock)[db integerColumnOfCurrentRowAtIndex: 2];
        JusikBusinessType *type = [businessTypes objectForKey: [db stringColumnOfCurrentRowAtIndex: 3]];
        NSString *detailedType = [db stringColumnOfCurrentRowAtIndex: 4];
        double initialPrice = [db doubleColumnOfCurrentRowAtIndex: 5];
        double EPS = [db doubleColumnOfCurrentRowAtIndex: 6];
        double ROE_s = [db doubleColumnOfCurrentRowAtIndex: 7];
        double ROE_e = [db doubleColumnOfCurrentRowAtIndex: 8];
        JusikRange ROE = JusikRangeMake(ROE_s, ROE_e);
        double BPS = [db doubleColumnOfCurrentRowAtIndex: 9];
        JusikSensitiveValue s_e = [db integerColumnOfCurrentRowAtIndex: 10];
        JusikSensitiveValue s_b = [db integerColumnOfCurrentRowAtIndex: 11];
        JusikSensitiveValue s_p = [db integerColumnOfCurrentRowAtIndex: 12];
        
        JusikCompanyInfo *info = [[JusikCompanyInfo alloc] initWithIdentifier: uid
                                                                         name: name
                                                                 capitalStock: capitalStock
                                                                 businessType: type
                                                                 detailedType: detailedType
                                                                          EPS: EPS
                                                                          ROE: ROE
                                                                          BPS: BPS
                                                      sensitiveToExchangeRate: s_e
                                                     sensitiveToBusinessScale: s_b
                                                               sensitiveToPBR: s_p];
        
        [_market addCompany: info initialPrice: initialPrice];
        [info release];
        [self updateProgress];
        //usleep(10000);
        //로딩 화면 잘 나오는지 확인하는 용도. 마음대로 주석 풀면 안됩니당.
    }
    
    /* ----------------------------
     Game View Controller
     --------------------------- */        
    _gameViewController = [[JusikGameViewController alloc] initWithNibName: @"JusikGameViewController" bundle: nil];
    _gameViewController.market = _market;
    _gameViewController.player = _player;
    _gameViewController.db = db;
    
    // 저장된 게임 상태를 로드하여 적용시킨다.
    [db selectTable: @"game_saved_state"];
    if([db nextRow]) {
        NSDictionary *d = [db rowData];
        
        // state
        NSNumber *n = [d objectForKey: @"state"];
        if(n) {
            JusikGamePlayState state = (JusikGamePlayState)[n unsignedIntegerValue];
            _gameViewController.gameState = state;
        }
        
        // turn
        n = [d objectForKey: @"turn"];
        if(n) {
            _gameViewController.turn = [n unsignedIntegerValue];
        }
        
        // date
        NSString *s = [d objectForKey: @"date"];
        if(s) {
            NSDateFormatter *f = [NSDateFormatter new];
            [f setDateFormat: @"yyyy-MM-dd"];
            NSDate *date = [f dateFromString: s];
            if(date) {
                _gameViewController.date = date;
            }
            [f release];
        }
    }
    else {
        // 없을 때는 기본 값 적용
        _gameViewController.gameState = JusikGamePlayStateStock;
    }
    
    [self updateProgress];
    
    
    /* ----------------------------
     소리 불러오기
     --------------------------- */
    for(NSString *musicName in [[JusikBGMPlayer sharedPlayer] musics]) {
        [[JusikBGMPlayer sharedPlayer] loadMusic: musicName];
        [self updateProgress];
    }
    
    /* ----------------------------
     Scripts
     --------------------------- */
    [db selectTable: @"script_tutorial_intro"];
    [db nextRow];
    NSUInteger uid = [db integerColumnOfCurrentRowAtIndex: 0];
    [db query: [NSString stringWithFormat: @"select * from script_speech where uid=%d order by speech_num asc", uid]];
    JusikScript *tutorialScript = [[JusikScript alloc] init];
    NSMutableArray *speeches = [NSMutableArray array];
    while([db nextRow]) {
        JusikSpeech *speech = [[JusikSpeech alloc] init];
        NSDictionary *d = [db rowData];
        
        speech.who = [d objectForKey: @"who"];
        speech.speech = [d objectForKey: @"speech"];
        speech.standingImageName = [d objectForKey: @"standing_image_name"];
        
        id obj = [d objectForKey: @"position"];
        if([obj isKindOfClass: [NSNumber class]])
            speech.position = (JusikStandingCutPosition)[obj unsignedIntegerValue];
        else
            speech.position = JusikStandingCutPositionNone;
        
        speech.musicName = [d objectForKey: @"music_name"];
        speech.soundEffectName = [d objectForKey: @"sound_effect_name"];
        speech.backgroundImageName = [d objectForKey: @"background_image_name"];
        [speeches addObject: speech];
        [speech release];
    }
    tutorialScript.speeches = speeches;
    _gameViewController.showsTutorial = YES;
    _gameViewController.tutorialScript = tutorialScript;
    [tutorialScript release];
    [self updateProgress];
    
    [db release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName: JusikLoadingViewLoadDidCompleteNotification
                                                            object: self];
    });
    
    return YES;
}

- (void)dealloc {
    [_market release];
    [_player release];
    [_gameViewController release];
    
    [super dealloc];
}

@end

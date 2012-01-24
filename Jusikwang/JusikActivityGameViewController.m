//
//  JusikActivityGameViewController.m
//  Jusikwang
//
//  Created by 이 현우 on 12. 1. 8..
//  Copyright (c) 2012 서울시립대학교. All rights reserved.
//

#import "JusikActivityGameViewController.h"
#import "JusikBGMPlayer.h"
#import <QuartzCore/QuartzCore.h>
#import "JusikScriptViewController.h"
#import "JusikScript.h"
#import "JusikUIDataTypes.h"
#import "NSDate+Extension.h"
#import "JusikDBManager.h"
#import "JusikDBManager+Extension.h"
#import "JusikActivityObject.h"
#import "JusikPlayer.h"

NSString *const JusikActivityGameViewGameDidStartNotification = @"JusikActivityGameViewGameDidStartNotification";
NSString *const JusikActivityGameViewGameDidStopNotification = @"JusikActivityGameViewGameDidStopNotification";

@interface JusikActivityGameViewController (Private) 
- (void)_initLayers;

- (void)_initHomeLayer;
- (void)_initOuterLayer;

- (void)_initHomeObjects;
- (void)_initOuterObjects;

- (void)_layoutHomeObjects;
- (void)_layoutOuterObjects;

- (void)_backToHome;
- (void)_goOuter;

- (JusikActivityObject *)_objectAtPosition: (CGPoint)pos;
- (void)_processAfterVisitingObject;

- (void)_zoomAtPosition: (CGPoint)pos rate: (double)rate;

- (NSUInteger)_activityCountOfDay;
- (void)_initVisitState;

@end

@implementation JusikActivityGameViewController {
    BOOL _playing;
    
    // 레이어
    CALayer *_backgroundLayer;
    CALayer *_touchAreaLayer;
    CALayer *_descriptionLayer;
    CALayer *_messageLayer;
    
    CALayer *_homeLayer;
    CALayer *_outerLayer;
    CALayer *_currentPositionLayer;
    
    // 집 내 물체들
    NSMutableArray *_homeObjects;
    
    // 집 밖 물체들
    NSMutableArray *_outerObjects;
    
    // 활동 수
    NSInteger _activityCount;
    BOOL _isNight;
    
    // 이미 방문했는지 확인하는 논리 변수
    NSMutableArray *_visitedObjects;
    
    // 터치 중/방문 중인 물체
    JusikActivityObject *_touchingObject;
    JusikActivityObject *_visitingObject;
    
    // 방문 이후 처리하는데 사용할 정보
    BOOL _visitingSucceeded;
    NSInteger _willObtainingIntelligence;
    NSInteger _willObtainingReliability;
    NSInteger _willObtainingFatigability;
    NSString *_willObtainingSkill;
    
    // 애니메이션 확인용
    BOOL _isAnimating;
    
    // 스크립트 컨트롤러
    JusikScriptViewController *_scriptViewController;
    
    // 영역 검사용
    CGRect doorArea;
    CGRect chartArea;
    CGRect computerArea;
    CGRect bookArea;
    CGRect bed1Area;
    CGRect bed2Area;
    
    CGRect homeArea;
    CGRect policeArea;
    CGRect heeseungArea;
    CGRect kiwoomArea;
    CGRect streetArea;
    CGRect shopArea;
}

@synthesize player = _player;
@synthesize activityCount = _activityCount;
@synthesize date = _date;
@synthesize db = _db;

@synthesize visitBedCount = _visitBedCount;
@synthesize visitComputerCount = _visitComputerCount;
@synthesize visitChartCount = _visitChartCount;
@synthesize visitBookCount = _visitBookCount;
@synthesize visitDoorCount = _visitDoorCount;

@synthesize visitParkCount = _visitParkCount;
@synthesize visitShopCount = _visitShopCount;
@synthesize visitPoliceCount = _visitPoliceCount;
@synthesize visitStreetCount = _visitStreetCount;
@synthesize visitHeeseungCount = _visitHeeseungCount;

#pragma mark - 초기화 메서드
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        /*
        doorArea = CGRectMake(270, 0, 98, 200);
        chartArea = CGRectMake(94, 134, 42, 38);
        computerArea = CGRectMake(0, 80, 60, 140);
        bookArea = CGRectMake(68, 12, 100, 66);
        bed1Area = CGRectMake(260, 245, 220, 55);
        bed2Area = CGRectMake(375, 185, 105, 115);
        */
        
        homeArea = CGRectMake(410, 230, 66, 60);
        policeArea = CGRectMake(308, 50, 76, 76);
        heeseungArea = CGRectMake(20, 230, 70, 60);
        kiwoomArea = CGRectMake(196, 0, 41, 135);
        streetArea = CGRectMake(0, 14, 170, 114);
        shopArea = CGRectMake(306, 165, 80, 100);
        
        _homeObjects = [NSMutableArray new];
        _outerObjects = [NSMutableArray new];
        
        _visitedObjects = [NSMutableArray new];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver: self
               selector: @selector(scriptDidEnd:)
                   name: JusikScriptViewScriptDidEndNotification
                 object: _scriptViewController];
        
        _scriptViewController = [[JusikScriptViewController alloc] initWithNibName: @"JusikScriptViewController" bundle: nil];
    }
    return self;
}

#pragma mark 메모리 워닝
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - 프로퍼티 메서드
- (JusikDBManager *)db {
    return _db;
}

- (void)setDb:(JusikDBManager *)db {
    [db retain];
    [_db release];
    _db = db;
    
    [self _initHomeObjects];
    [self _initOuterObjects];
}

#pragma mark - 게임
- (void)play {
    if(_playing) return;
    _playing = YES;
    
    [[JusikBGMPlayer sharedPlayer] playMusic: JusikBGMMusicActivity];
    [self _backToHome];
    
    _activityCount = [self _activityCountOfDay];
    _isNight = NO;
    
    [self _initVisitState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStartNotification object: nil];
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    if(_playing == NO) return;
    _playing = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStopNotification object: nil];
}

#pragma mark - 터치 이벤트
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_isAnimating) return;
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView: self.view];
    
    // 터치 판정
    if(_currentPositionLayer == _homeLayer) {
        JusikActivityObject *o = [self _objectAtPosition: p];
        if(o != _touchingObject) {
            [_touchingObject.layer removeFromSuperlayer];
            _touchingObject = o;
            [o showPressedState];
            [_touchAreaLayer addSublayer: o.layer];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesBegan: touches withEvent: event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_isAnimating) return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_isAnimating) return;
    
    _isAnimating = YES;
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView: self.view];
    
    // 터치 판정
    if(_currentPositionLayer == _homeLayer) {
        // 오버된 레이어 숨기기
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0];
        [_touchingObject.layer removeFromSuperlayer];
        [CATransaction commit];
        
        // 터치한 물체 찾기
        JusikActivityObject *o = [self _objectAtPosition: p];
        _touchingObject = o;
        _visitingObject = o;
        
        // 홈 레이어 숨기기
        // --------------------
        if(_touchingObject != nil) {
            // Zoom
            [self _zoomAtPosition: p rate: kJusikViewZoomRate];
            
            // 홈레이어 숨기기
            [CATransaction begin];
            [CATransaction setAnimationDuration: kJusikViewZoomTime];
            
            _homeLayer.opacity = 0;
            
            [CATransaction commit];
        }        
        // --------------------
        
        // 문 판정
        if([_touchingObject.name isEqualToString: @"com.jusikwang.activity.home.object.door"]) {
            // 마을 레이어 보이기
            _outerLayer.opacity = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [CATransaction begin];
                [CATransaction setAnimationDuration: kJusikViewFadeTime];
                
                _outerLayer.opacity = 1;
                [self _goOuter];
                
                [CATransaction commit];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewFadeTime * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    _isAnimating = NO;
                });
            });
            
            _visitingObject = nil;
        }
        // 컴퓨터 판정
        else if([_touchingObject.name isEqualToString: @"com.jusikwang.activity.home.object.computer"]) {
            JusikScript *script;
            // 피로도가 30이면 습득 실패한다.
            if(self.player.fatigability >= 30) {
                [self.db selectTable: kJusikTableNameScriptHomeAnalysisCompanyFailed];
                [self.db nextRow];
                
                NSUInteger uid = [self.db integerColumnOfCurrentRowAtIndex: 0];
                script = [self.db scriptWithID: uid];
                
                _willObtainingSkill = nil;
                _visitingSucceeded = NO;
            }
            else {
                NSString *query = [NSString stringWithFormat: @"select * from %@ where step=%d", kJusikTableNameScriptHomeAnalysisCompanyStudy, self.visitComputerCount+1];
                [self.db query: query];
                if([self.db nextRow]) {
                    NSDictionary *rowData = [self.db rowData];
                    NSUInteger uid = [[rowData objectForKey: @"uid"] unsignedIntegerValue];
                    script = [self.db scriptWithID: uid];
                    
                    _willObtainingSkill = [[rowData objectForKey: @"obtained_skill"] copy];
                    _visitingSucceeded = YES;
                }
                else {
                    [self.db selectTable: kJusikTableNameScriptHomeAnalysisCompanyMore];
                    [self.db nextRow];
                    
                    NSUInteger uid = [self.db integerColumnOfCurrentRowAtIndex: 0];
                    script = [self.db scriptWithID: uid];
                    _visitingSucceeded = NO;
                }
                _willObtainingFatigability += 3;
            }
            
            // 스크립트 재생
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.view addSubview: _scriptViewController.view];
                [_scriptViewController runScript: script defaultBackground: nil];
            });
        }
        // 침대 판정
        // 침대는 사각형이 아니니 체크 영역이 2개 필요하다 제길.
        else if([_touchingObject.name isEqualToString: @"com.jusikwang.activity.home.object.bed1"] ||
                [_touchingObject.name isEqualToString: @"com.jusikwang.activity.home.object.bed2"]) 
        {
            // ID 얻기
            [self.db selectTable: @"script_home_bed"];
            [self.db nextRow];
            NSUInteger uid = [self.db integerColumnOfCurrentRowAtIndex: 0];
            
            // 스크립트 얻기
            JusikScript *script = [self.db scriptWithID: uid];
            
            // 스크립트 후 처리 변수 설정
            _willObtainingFatigability = -15;
            
            // 스크립트 재생
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.view addSubview: _scriptViewController.view];
                [_scriptViewController runScript: script defaultBackground: [UIImage imageNamed: @"Images/activity_home.png"]];
            });
        }
        else {
            _isAnimating = NO;
        }
    }
    else if(_currentPositionLayer == _outerLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0];
        
        [CATransaction commit];
        
        // 집 판정
        if(p.x >= CGRectGetMinX(homeArea) && p.x <= CGRectGetMaxX(homeArea) &&
           p.y >= CGRectGetMinY(homeArea) && p.y <= CGRectGetMaxY(homeArea)) {
            // Zoom
            [self _zoomAtPosition: p rate: kJusikViewZoomRate];
            
            // 홈레이어 숨기기
            [CATransaction begin];
            [CATransaction setAnimationDuration: kJusikViewZoomTime];
            
            _outerLayer.opacity = 0;
            
            [CATransaction commit];
            
            // 마을 레이어 보이기
            _homeLayer.opacity = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [CATransaction begin];
                [CATransaction setAnimationDuration: kJusikViewFadeTime];
                
                _homeLayer.opacity = 1;
                [self _backToHome];
                
                [CATransaction commit];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewFadeTime * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    _isAnimating = NO;
                });
            });
        }
        // 희승
        else if(p.x >= CGRectGetMinX(heeseungArea) && p.x <= CGRectGetMaxX(heeseungArea) &&
                p.y >= CGRectGetMinY(heeseungArea) && p.y <= CGRectGetMaxY(heeseungArea)) {
            _isAnimating = NO;
        }
        else {
            _isAnimating = NO;
        }
    }
    else {
        _isAnimating = NO;
    }
    _touchingObject = nil;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _initLayers];
    [self _backToHome];
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - 노티피케이션
- (void)scriptDidEnd: (NSNotification *)notification {
    [_scriptViewController.view removeFromSuperview];
    
    _isAnimating = NO;
    _currentPositionLayer.opacity = 1;
    
    [self _processAfterVisitingObject];
    
    _activityCount -= 1;
    if(_activityCount < 2)
        _isNight = YES;
    if(_activityCount < 1)
        [self stop];
}

#pragma mark - 비공개 메서드
- (void)_initLayers {
    CGRect bounds = self.view.layer.bounds;
    
    // 레이어
    if(!_backgroundLayer) {
        _backgroundLayer = [[CALayer alloc] init];
        _backgroundLayer.bounds = bounds;
        _backgroundLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _backgroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(!_touchAreaLayer) {
        _touchAreaLayer = [[CALayer alloc] init];
        _touchAreaLayer.bounds = bounds;
        _touchAreaLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _touchAreaLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(!_descriptionLayer) {
        _descriptionLayer = [[CALayer alloc] init];
        _descriptionLayer.bounds = bounds;
        _descriptionLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _descriptionLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    if(!_messageLayer) {
        _messageLayer = [[CALayer alloc] init];
        _messageLayer.bounds = bounds;
        _messageLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _messageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    }
    
    [self.view.layer addSublayer: _backgroundLayer];
    [self.view.layer addSublayer: _touchAreaLayer];
    [self.view.layer addSublayer: _messageLayer];
    
    [self _initHomeLayer];
    [self _initOuterLayer];
}

- (void)_initHomeLayer {
    CGRect bounds = self.view.layer.bounds;
    
    // 집
    if(!_homeLayer) {
        _homeLayer = [[CALayer alloc] init];
        _homeLayer.bounds = bounds;
        _homeLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _homeLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _homeLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home.png"] CGImage];
    }
    [self _initHomeObjects];
}

- (void)_initOuterLayer {
    CGRect bounds = self.view.layer.bounds;
    
    // 바깥
    if(!_outerLayer) {
        _outerLayer = [[CALayer alloc] init];
        _outerLayer.bounds = bounds;
        _outerLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        _outerLayer.anchorPoint = CGPointMake(0.5, 0.5);
        _outerLayer.contents = (id)[[UIImage imageNamed: @"Images/map_village.png"] CGImage];
    }
    [self _layoutOuterObjects];
}

- (void)_initHomeObjects {
    for(JusikActivityObject *o in _homeObjects) {
        [o.layer removeFromSuperlayer];
    }
    [_homeObjects removeAllObjects];
    
    if(_db) {
        NSArray *a = [_db activityHomeObjects];
        [_homeObjects addObjectsFromArray: a];
    }
    
    [self _layoutHomeObjects];
}

- (void)_initOuterObjects {
    
}

- (void)_layoutHomeObjects {
    CGRect bounds = _homeLayer.bounds;
    for(JusikActivityObject *o in _homeObjects) {
        CALayer *layer = o.layer;
        layer.bounds = bounds;
        layer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
        layer.anchorPoint = CGPointMake(0.5, 0.5);
    }
}

- (void)_layoutOuterObjects {
    
}

- (void)_backToHome {
    if(_currentPositionLayer == _homeLayer) return;
    
    [_currentPositionLayer removeFromSuperlayer];
    [_backgroundLayer addSublayer: _homeLayer];
    _currentPositionLayer = _homeLayer;
}

- (void)_goOuter {
    if(_currentPositionLayer == _outerLayer) return;
    [_currentPositionLayer removeFromSuperlayer];
    [_backgroundLayer addSublayer: _outerLayer];
    _currentPositionLayer = _outerLayer;
}

- (JusikActivityObject *)_objectAtPosition: (CGPoint)pos {
    if(_currentPositionLayer == _homeLayer) {
        for(JusikActivityObject *o in _homeObjects) {
            if(pos.x >= CGRectGetMinX(o.area) && pos.x <= CGRectGetMaxX(o.area) &&
               pos.y >= CGRectGetMinY(o.area) && pos.y <= CGRectGetMaxY(o.area))
                return o;
        }
    }
    return nil;
}

- (void)_processAfterVisitingObject {
    if(_visitingObject == nil) return;
    
    if([_visitingObject.name isEqualToString: @"com.jusikwang.activity.home.object.computer"]) {
        if(_visitingSucceeded)
            self.visitComputerCount++;
    }
    // 침대
    else if([_visitingObject.name isEqualToString: @"com.jusikwang.activity.home.object.bed1"] ||
       [_visitingObject.name isEqualToString: @"com.jusikwang.activity.home.object.bed2"]) {
    }
    
    _visitingSucceeded = NO;
    
    [_visitedObjects addObject: _visitingObject];
    _visitingObject = nil;
    
    self.player.intelligence += _willObtainingIntelligence;
    self.player.reliability += _willObtainingReliability;
    self.player.fatigability += _willObtainingFatigability;
    if(_willObtainingSkill) {
        [self.player addSkill: _willObtainingSkill];
        [_willObtainingSkill release];
        _willObtainingSkill = nil;
    }
    
    _willObtainingIntelligence = 0;
    _willObtainingReliability = 0;
    _willObtainingFatigability = 0;
}

- (void)_zoomAtPosition:(CGPoint)pos rate:(double)rate {
    CGPoint center = _currentPositionLayer.position;
    CGPoint newCenter = CGPointMake(center.x + (center.x-pos.x)*(rate-1.0), center.y+(center.y-pos.y)*(rate-1.0));
    
    CGRect bounds = _currentPositionLayer.bounds;
    bounds.size.width *= rate;
    bounds.size.height *= rate;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kJusikViewZoomTime;
    
    CABasicAnimation *a1 = [CABasicAnimation animation];
    a1.keyPath = @"position";
    a1.fromValue = [NSValue valueWithCGPoint: _currentPositionLayer.position];
    a1.toValue = [NSValue valueWithCGPoint: newCenter];
    a1.duration = kJusikViewZoomTime;
    a1.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];

    CABasicAnimation *a2 = [CABasicAnimation animation];
    a2.keyPath = @"bounds";
    a2.fromValue = [NSValue valueWithCGRect: _currentPositionLayer.bounds];
    a2.toValue = [NSValue valueWithCGRect: bounds];
    a2.duration = kJusikViewZoomTime;
    a2.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    
    group.animations = [NSArray arrayWithObjects:a1, a2, nil];
    [_currentPositionLayer addAnimation: group forKey: @"zoomAnimation"];
}

- (NSUInteger)_activityCountOfDay {
    NSLog(@"activity: %@", _date);
    if([self.date isWeekday]) {
        return 2;
    }
    else
        return 1;
}

- (void)_initVisitState {
    [_visitedObjects removeAllObjects];
}


#pragma mark - 메모리 해제
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [_backgroundLayer release];
    [_touchAreaLayer release];
    [_messageLayer release];
    
    [_homeLayer release];
    [_outerLayer release];
    
    [_homeObjects release];
    [_outerObjects release];
    [_visitedObjects release];
    
    [_player release];
    [_date release];
    [_db release];
    
    [_scriptViewController release];
    
    [super dealloc];
}

@end

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

NSString *const JusikActivityGameViewGameDidStartNotification = @"JusikActivityGameViewGameDidStartNotification";
NSString *const JusikActivityGameViewGameDidStopNotification = @"JusikActivityGameViewGameDidStopNotification";

@interface JusikActivityGameViewController (Private) 
- (void)initLayers;
- (void)initHomeLayers;
- (void)initOuterLayers;
- (void)backToHome;
- (void)goOuter;

- (void)zoomAtPosition: (CGPoint)pos rate: (double)rate;

- (NSUInteger)activityCountOfDay;
- (void)initVisitState;
@end

@implementation JusikActivityGameViewController {
    CALayer *backgroundLayer;
    CALayer *touchAreaLayer;
    CALayer *messageLayer;
    
    CALayer *homeLayer;
    CALayer *outerLayer;
    CALayer *currentPosition;
    
    // 집 내 물체들
    CALayer *homeDoorLayer;
    CALayer *homeComputerLayer;
    CALayer *homeChartLayer;
    CALayer *homeBookLayer;
    CALayer *homeBedLayer;
    
    // 활동 수
    NSUInteger _activityCount;
    BOOL _isNight;
    
    // 이미 방문했는지 확인하는 논리 변수
    BOOL _visitsStockAnalysis, _visitsCompanyAlalysis, _visitsStudy, _visitsRest;
    BOOL _visitsStreet, _visitsKiwoom, _visitsPolice, _visitsHeeseung, _visitsShop, _visitsPark;
    
    BOOL _isAnimating;
    
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
        doorArea = CGRectMake(270, 0, 98, 200);
        chartArea = CGRectMake(94, 134, 42, 38);
        computerArea = CGRectMake(0, 80, 60, 140);
        bookArea = CGRectMake(68, 12, 100, 66);
        bed1Area = CGRectMake(260, 245, 220, 55);
        bed2Area = CGRectMake(375, 185, 105, 115);
        
        homeArea = CGRectMake(410, 230, 66, 60);
        policeArea = CGRectMake(308, 50, 76, 76);
        heeseungArea = CGRectMake(20, 230, 70, 60);
        kiwoomArea = CGRectMake(196, 0, 41, 135);
        streetArea = CGRectMake(0, 14, 170, 114);
        shopArea = CGRectMake(306, 165, 80, 100);
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

#pragma mark - 게임
- (void)play {
    [[JusikBGMPlayer sharedPlayer] playMusic: JusikBGMMusicActivity];
    [self backToHome];
    _activityCount = [self activityCountOfDay];
    _isNight = NO;
    [self initVisitState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStartNotification object: nil];
}

- (void)pause {
    
}

- (void)resume {
    
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] postNotificationName: JusikActivityGameViewGameDidStopNotification object: nil];
}

- (void)setActivityCountOfDay {
    
}

#pragma mark - 터치 이벤트
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_isAnimating) return;
    
    UITouch *touch = touches.anyObject;
    CGPoint p = [touch locationInView: self.view];
    
    // 터치 판정
    if(currentPosition == homeLayer) {
        // 문 판정
        if(p.x >= CGRectGetMinX(doorArea) && p.x <= CGRectGetMaxX(doorArea) &&
           p.y >= CGRectGetMinY(doorArea) && p.y <= CGRectGetMaxY(doorArea)) {
            [touchAreaLayer addSublayer: homeDoorLayer];
        }
        else {
            [homeDoorLayer removeFromSuperlayer];
        }
        // 컴퓨터 판정
        if(p.x >= CGRectGetMinX(computerArea) && p.x <= CGRectGetMaxX(computerArea) &&
           p.y >= CGRectGetMinY(computerArea) && p.y <= CGRectGetMaxY(computerArea)) {
            [touchAreaLayer addSublayer: homeComputerLayer];
        }
        else {
            [homeComputerLayer removeFromSuperlayer];
        }
        // 차트 판정
        if(p.x >= CGRectGetMinX(chartArea) && p.x <= CGRectGetMaxX(chartArea) &&
           p.y >= CGRectGetMinY(chartArea) && p.y <= CGRectGetMaxY(chartArea)) {
            [touchAreaLayer addSublayer: homeChartLayer];
        }
        else {
            [homeChartLayer removeFromSuperlayer];
        }
        // 책 판정
        if(p.x >= CGRectGetMinX(bookArea) && p.x <= CGRectGetMaxX(bookArea) &&
           p.y >= CGRectGetMinY(bookArea) && p.y <= CGRectGetMaxY(bookArea)) {
            [touchAreaLayer addSublayer: homeBookLayer];
        }
        else {
            [homeBookLayer removeFromSuperlayer];
        }
        // 침대 판정
        // 침대는 사각형이 아니니 체크 영역이 2개 필요하다 제길.
        if((p.x >= CGRectGetMinX(bed1Area) && p.x <= CGRectGetMaxX(bed1Area) &&
           p.y >= CGRectGetMinY(bed1Area) && p.y <= CGRectGetMaxY(bed1Area)) ||
           (p.x >= CGRectGetMinX(bed2Area) && p.x <= CGRectGetMaxX(bed2Area) &&
            p.y >= CGRectGetMinY(bed2Area) && p.y <= CGRectGetMaxY(bed2Area))) {
            [touchAreaLayer addSublayer: homeBedLayer];
        }
        else {
            [homeBedLayer removeFromSuperlayer];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_isAnimating) return;
    
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
    if(currentPosition == homeLayer) {       
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0];
        [homeDoorLayer removeFromSuperlayer];
        [homeChartLayer removeFromSuperlayer];
        [homeComputerLayer removeFromSuperlayer];
        [homeBedLayer removeFromSuperlayer];
        [homeBookLayer removeFromSuperlayer];
        [CATransaction commit];
        
        // 문 판정
        if(p.x >= CGRectGetMinX(doorArea) && p.x <= CGRectGetMaxX(doorArea) &&
           p.y >= CGRectGetMinY(doorArea) && p.y <= CGRectGetMaxY(doorArea)) {
            // Zoom
            [self zoomAtPosition: p rate: kJusikViewZoomRate];
            
            // 홈레이어 숨기기
            [CATransaction begin];
            [CATransaction setAnimationDuration: kJusikViewZoomTime];

            homeLayer.opacity = 0;
            
            [CATransaction commit];
            
            // 마을 레이어 보이기
            outerLayer.opacity = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [CATransaction begin];
                [CATransaction setAnimationDuration: kJusikViewFadeTime];
                
                outerLayer.opacity = 1;
                [self goOuter];
                
                [CATransaction commit];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewFadeTime * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    _isAnimating = NO;
                });
            });
        }
        // 컴퓨터(기업분석) 판정
        
        else {
            _isAnimating = NO;
        }
    }
    else if(currentPosition == outerLayer) {
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0];
        
        [CATransaction commit];
        
        // 집 판정
        if(p.x >= CGRectGetMinX(homeArea) && p.x <= CGRectGetMaxX(homeArea) &&
           p.y >= CGRectGetMinY(homeArea) && p.y <= CGRectGetMaxY(homeArea)) {
            // Zoom
            [self zoomAtPosition: p rate: kJusikViewZoomRate];
            
            // 홈레이어 숨기기
            [CATransaction begin];
            [CATransaction setAnimationDuration: kJusikViewZoomTime];
            
            outerLayer.opacity = 0;
            
            [CATransaction commit];
            
            // 마을 레이어 보이기
            homeLayer.opacity = 0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kJusikViewZoomTime * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [CATransaction begin];
                [CATransaction setAnimationDuration: kJusikViewFadeTime];
                
                homeLayer.opacity = 1;
                [self backToHome];
                
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
            
        }
        else {
            _isAnimating = NO;
        }
    }
    else {
        _isAnimating = NO;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLayers];
    [self backToHome];
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

#pragma mark - 비공개 메서드
- (void)initLayers {
    CGRect bounds = self.view.layer.bounds;
    
    // 레이어
    backgroundLayer = [[CALayer alloc] init];
    backgroundLayer.bounds = bounds;
    backgroundLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    backgroundLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    touchAreaLayer = [[CALayer alloc] init];
    touchAreaLayer.bounds = bounds;
    touchAreaLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    touchAreaLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    messageLayer = [[CALayer alloc] init];
    messageLayer.bounds = bounds;
    messageLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    messageLayer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [self.view.layer addSublayer: backgroundLayer];
    [self.view.layer addSublayer: touchAreaLayer];
    [self.view.layer addSublayer: messageLayer];
    
    [self initHomeLayers];
    [self initOuterLayers];
}

- (void)initHomeLayers {
    CGRect bounds = self.view.layer.bounds;
    
    // 집
    homeLayer = [[CALayer alloc] init];
    homeLayer.bounds = bounds;
    homeLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home.png"] CGImage];
    
    // 문
    homeDoorLayer = [[CALayer alloc] init];
    homeDoorLayer.bounds = bounds;
    homeDoorLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeDoorLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeDoorLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home_door.png"] CGImage];
    
    // 컴퓨터
    homeComputerLayer = [[CALayer alloc] init];
    homeComputerLayer.bounds = bounds;
    homeComputerLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeComputerLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeComputerLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home_computer.png"] CGImage];
    
    // 차트
    homeChartLayer = [[CALayer alloc] init];
    homeChartLayer.bounds = bounds;
    homeChartLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeChartLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeChartLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home_chart.png"] CGImage];
    
    // 책
    homeBookLayer = [[CALayer alloc] init];
    homeBookLayer.bounds = bounds;
    homeBookLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeBookLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeBookLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home_book.png"] CGImage];
    
    // 침대
    homeBedLayer = [[CALayer alloc] init];
    homeBedLayer.bounds = bounds;
    homeBedLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    homeBedLayer.anchorPoint = CGPointMake(0.5, 0.5);
    homeBedLayer.contents = (id)[[UIImage imageNamed: @"Images/activity_home_bed.png"] CGImage];
}

- (void)initOuterLayers {
    CGRect bounds = self.view.layer.bounds;
    
    // 바깥
    outerLayer = [[CALayer alloc] init];
    outerLayer.bounds = bounds;
    outerLayer.position = CGPointMake(bounds.size.width * 0.5, bounds.size.height * 0.5);
    outerLayer.anchorPoint = CGPointMake(0.5, 0.5);
    outerLayer.contents = (id)[[UIImage imageNamed: @"Images/map_village.png"] CGImage];

}

- (void)backToHome {
    if(currentPosition == homeLayer) return;
    
    [currentPosition removeFromSuperlayer];
    [backgroundLayer addSublayer: homeLayer];
    currentPosition = homeLayer;
}

- (void)goOuter {
    if(currentPosition == outerLayer) return;
    [currentPosition removeFromSuperlayer];
    [backgroundLayer addSublayer: outerLayer];
    currentPosition = outerLayer;
}

- (void)zoomAtPosition:(CGPoint)pos rate:(double)rate {
    CGPoint center = currentPosition.position;
    CGPoint newCenter = CGPointMake(center.x + (center.x-pos.x)*(rate-1.0), center.y+(center.y-pos.y)*(rate-1.0));
    
    CGRect bounds = currentPosition.bounds;
    bounds.size.width *= rate;
    bounds.size.height *= rate;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kJusikViewZoomTime;
    
    CABasicAnimation *a1 = [CABasicAnimation animation];
    a1.keyPath = @"position";
    a1.fromValue = [NSValue valueWithCGPoint: currentPosition.position];
    a1.toValue = [NSValue valueWithCGPoint: newCenter];
    a1.duration = kJusikViewZoomTime;
    a1.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];

    CABasicAnimation *a2 = [CABasicAnimation animation];
    a2.keyPath = @"bounds";
    a2.fromValue = [NSValue valueWithCGRect: currentPosition.bounds];
    a2.toValue = [NSValue valueWithCGRect: bounds];
    a2.duration = kJusikViewZoomTime;
    a2.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseIn];
    
    group.animations = [NSArray arrayWithObjects:a1, a2, nil];
    [currentPosition addAnimation: group forKey: @"zoomAnimation"];
}

- (NSUInteger)activityCountOfDay {
    if([self.date isWeekday]) {
        return 2;
    }
    else
        return 1;
}

- (void)initVisitState {
    _visitsCompanyAlalysis = _visitsStockAnalysis = _visitsStudy = _visitsRest = NO;
    _visitsStreet = _visitsKiwoom = _visitsHeeseung = _visitsPark = _visitsShop = _visitsPolice = NO;
}


#pragma mark - 메모리 해제
- (void)dealloc {
    [backgroundLayer release];
    [touchAreaLayer release];
    [messageLayer release];
    
    [homeLayer release];
    [outerLayer release];
    
    [homeDoorLayer release];
    
    [_player release];
    
    [super dealloc];
}

@end
